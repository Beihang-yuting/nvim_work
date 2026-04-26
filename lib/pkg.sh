#!/usr/bin/env bash
pkg_install() {
  local distro
  distro="$(detect_distro)"
  case "$distro" in
    ubuntu|debian)
      sudo apt-get update -qq
      sudo apt-get install -y "$@"
      ;;
    rhel|fedora)
      sudo dnf install -y "$@"
      ;;
    arch)
      sudo pacman -S --needed --noconfirm "$@"
      ;;
    *)
      log_warn "未识别的发行版 $distro，跳过：$*"
      return 0
      ;;
  esac
}

pkg_install_core() {
  local distro
  distro="$(detect_distro)"
  case "$distro" in
    ubuntu|debian)
      pkg_install git curl unzip build-essential ripgrep fd-find nodejs npm python3 python3-pip cargo make
      local fdfind_path
      fdfind_path="$(command -v fdfind 2>/dev/null || true)"
      if [ -n "$fdfind_path" ] && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$fdfind_path" /usr/local/bin/fd 2>/dev/null || true
      fi
      ;;
    rhel|fedora)
      sudo dnf groupinstall -y "Development Tools" || log_warn "Development Tools group install failed"
      pkg_install git curl unzip ripgrep fd-find nodejs npm python3 python3-pip cargo make
      ;;
    arch)
      pkg_install git curl unzip base-devel ripgrep fd nodejs npm python python-pip rust make
      ;;
  esac
  install_nvim_if_needed
}

install_nvim_if_needed() {
  local cur_ver
  cur_ver="$(detect_nvim_version)"
  local major minor
  major=$(echo "$cur_ver" | cut -d. -f1)
  minor=$(echo "$cur_ver" | cut -d. -f2)
  local patch
  patch=$(echo "$cur_ver" | cut -d. -f3)
  # LazyVim 要求 >= 0.11.2
  if [ "${major:-0}" -ge 1 ] || { [ "${major:-0}" -eq 0 ] && [ "${minor:-0}" -gt 11 ]; } \
     || { [ "${major:-0}" -eq 0 ] && [ "${minor:-0}" -eq 11 ] && [ "${patch:-0}" -ge 2 ]; }; then
    log_ok "Neovim $cur_ver 已满足 >= 0.11.2"; return 0
  fi
  log_info "系统 Neovim ($cur_ver) 版本过低 (需要 >= 0.11.2)，从 GitHub 安装 ..."

  local arch
  arch="$(uname -m)"
  local dest="$HOME/.local/bin"
  mkdir -p "$dest"

  # 检测系统 glibc 版本
  local glibc_ver
  glibc_ver=$(ldd --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+$' || echo "0.0")
  local glibc_minor
  glibc_minor=$(echo "$glibc_ver" | cut -d. -f2)
  log_info "检测到 glibc $glibc_ver"

  # glibc >= 2.32: 用最新 tar.gz; 否则用 v0.10.4 AppImage
  if [ "${glibc_minor:-0}" -ge 32 ]; then
    install_nvim_tarball "$arch" "$dest"
  else
    install_nvim_appimage "$arch" "$dest"
  fi
}

install_nvim_tarball() {
  local arch="$1" dest_dir="$2"
  local dl_arch
  case "$arch" in
    x86_64)  dl_arch="x86_64" ;;
    aarch64) dl_arch="arm64" ;;
    *) log_err "不支持的架构: $arch"; return 1 ;;
  esac
  local dest_base
  dest_base="$(dirname "$dest_dir")"
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${dl_arch}.tar.gz"
  local tmpfile
  tmpfile="$(mktemp /tmp/nvim-XXXXXX.tar.gz)"
  if curl -fL --retry 3 --connect-timeout 30 "$url" -o "$tmpfile"; then
    tar -xzf "$tmpfile" -C "$dest_base" --strip-components=1
    rm -f "$tmpfile"
    nvim_ensure_path "$dest_dir"
  else
    rm -f "$tmpfile"
    log_err "Neovim tar.gz 下载失败"; return 1
  fi
}

install_nvim_appimage() {
  local arch="$1" dest_dir="$2"

  # snap 完全自包含，不依赖系统 glibc，优先使用
  if command -v snap >/dev/null 2>&1; then
    log_info "glibc 版本较低，使用 snap 安装 Neovim (完全自包含) ..."
    if sudo snap install nvim --classic; then
      local snap_nvim="/snap/bin/nvim"
      if [ -x "$snap_nvim" ] && "$snap_nvim" --version >/dev/null 2>&1; then
        log_ok "Neovim (snap) 已安装: $("$snap_nvim" --version | head -1)"
        if ! echo "$PATH" | grep -q "/snap/bin"; then
          export PATH="/snap/bin:$PATH"
          log_info "已临时添加 /snap/bin 到 PATH"
          log_info "建议在 ~/.bashrc 中添加: export PATH=\"/snap/bin:\$PATH\""
        fi
        return 0
      fi
    fi
    log_warn "snap 安装失败，尝试 AppImage ..."
  fi

  # snap 不可用时尝试 AppImage
  if [ "$arch" != "x86_64" ]; then
    log_err "AppImage 仅支持 x86_64，当前架构: $arch"; return 1
  fi
  local url="https://github.com/neovim/neovim/releases/download/v0.11.7/nvim-linux-x86_64.appimage"
  local dest="$dest_dir/nvim"
  log_info "尝试 Neovim v0.11.7 AppImage ..."
  if curl -fL --retry 3 --connect-timeout 30 "$url" -o "$dest"; then
    chmod +x "$dest"
    if "$dest" --version >/dev/null 2>&1; then
      nvim_ensure_path "$dest_dir"
      return 0
    else
      rm -f "$dest"
      log_warn "AppImage 与当前系统不兼容"
    fi
  fi

  log_err "Neovim 安装失败。请手动安装 >= 0.11.2: sudo snap install nvim --classic"
  return 1
}

nvim_ensure_path() {
  local dest_dir="$1"
  if [ -x "$dest_dir/nvim" ]; then
    local ver
    ver=$("$dest_dir/nvim" --version 2>/dev/null | head -1 || echo "unknown")
    log_ok "Neovim 已安装: $ver -> $dest_dir/nvim"
    if ! echo "$PATH" | grep -q "$dest_dir"; then
      export PATH="$dest_dir:$PATH"
      log_info "已临时添加 $dest_dir 到 PATH"
      log_info "建议在 ~/.bashrc 中添加: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
  else
    log_err "未找到 $dest_dir/nvim"; return 1
  fi
}

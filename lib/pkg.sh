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
  if [ "${major:-0}" -ge 1 ] || { [ "${major:-0}" -eq 0 ] && [ "${minor:-0}" -ge 10 ]; }; then
    log_ok "Neovim $cur_ver 已满足 >= 0.10"; return 0
  fi
  log_info "系统 Neovim ($cur_ver) 版本过低，从 GitHub 安装最新版 ..."
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="arm64" ;;
    *) log_err "不支持的架构: $arch"; return 1 ;;
  esac
  local dest="$HOME/.local"
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz"
  mkdir -p "$dest"
  local tmpfile
  tmpfile="$(mktemp /tmp/nvim-XXXXXX.tar.gz)"
  if curl -fL --retry 3 --connect-timeout 30 "$url" -o "$tmpfile"; then
    tar -xzf "$tmpfile" -C "$dest" --strip-components=1
    rm -f "$tmpfile"
    if [ -x "$dest/bin/nvim" ]; then
      log_ok "Neovim 已安装到 $dest/bin/nvim"
      if ! echo "$PATH" | grep -q "$dest/bin"; then
        export PATH="$dest/bin:$PATH"
        log_info "已临时添加 $dest/bin 到 PATH，建议在 ~/.bashrc 中添加: export PATH=\"\$HOME/.local/bin:\$PATH\""
      fi
    else
      log_err "解压后未找到 $dest/bin/nvim"; return 1
    fi
  else
    rm -f "$tmpfile"
    log_err "Neovim 下载失败，请手动安装 >= 0.10 版本"; return 1
  fi
}

#!/usr/bin/env bash
install_neovide() {
  if command -v neovide >/dev/null 2>&1; then
    log_ok "Neovide 已存在"; return 0
  fi
  log_info "尝试下载 Neovide AppImage ..."
  install_neovide_appimage || install_neovide_cargo
}

install_neovide_cargo() {
  if ! command -v cargo >/dev/null 2>&1; then
    log_err "cargo 不可用，无法从源码编译 Neovide"; return 1
  fi
  local cargo_ver
  cargo_ver=$(cargo --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
  local major minor
  major=${cargo_ver%%.*}; minor=${cargo_ver#*.}
  if [ "${major:-0}" -lt 1 ] || { [ "${major:-0}" -eq 1 ] && [ "${minor:-0}" -lt 85 ]; }; then
    log_err "Cargo $cargo_ver 版本过低 (需要 >= 1.85)，请升级 Rust 工具链或手动安装 Neovide"
    return 1
  fi
  log_info "尝试通过 cargo 编译 Neovide ..."
  cargo install neovide
}

install_neovide_appimage() {
  local url="https://github.com/neovide/neovide/releases/latest/download/neovide.AppImage"
  local dest="$HOME/.local/bin/neovide"
  mkdir -p "$(dirname "$dest")"
  local retry
  for retry in 1 2 3; do
    if curl -fL --retry 3 --retry-delay 5 --connect-timeout 30 "$url" -o "$dest"; then
      chmod +x "$dest"
      log_ok "Neovide AppImage 已安装到 $dest"
      return 0
    fi
    log_warn "下载失败，第 $retry 次重试 ..."
    sleep 5
  done
  log_err "Neovide AppImage 下载失败，请检查网络或手动下载"
  return 1
}

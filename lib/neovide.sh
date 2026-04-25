#!/usr/bin/env bash
install_neovide() {
  if command -v neovide >/dev/null 2>&1; then
    log_ok "Neovide 已存在"; return 0
  fi
  log_info "尝试通过 cargo 安装 Neovide ..."
  if command -v cargo >/dev/null 2>&1; then
    cargo install --locked neovide || install_neovide_appimage
  else
    install_neovide_appimage
  fi
}

install_neovide_appimage() {
  local url="https://github.com/neovide/neovide/releases/latest/download/neovide-linux-x86_64.AppImage"
  local dest="$HOME/.local/bin/neovide"
  mkdir -p "$(dirname "$dest")"
  curl -fL "$url" -o "$dest" && chmod +x "$dest" && log_ok "Neovide AppImage 已安装到 $dest"
}

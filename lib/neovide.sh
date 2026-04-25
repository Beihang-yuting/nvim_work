#!/usr/bin/env bash
install_neovide() {
  if command -v neovide >/dev/null 2>&1; then
    log_ok "Neovide 已存在"; return 0
  fi
  log_info "尝试通过 cargo 安装 Neovide ..."
  if command -v cargo >/dev/null 2>&1; then
    cargo install neovide || install_neovide_appimage
  else
    install_neovide_appimage
  fi
}

install_neovide_appimage() {
  local url="https://github.com/neovide/neovide/releases/latest/download/neovide-linux-x86_64.AppImage"
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

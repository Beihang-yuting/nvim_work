#!/usr/bin/env bash
install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts"
  local marker="$font_dir/.jb-mono-nf-installed"
  if [ -f "$marker" ]; then
    log_ok "Nerd Font 已安装"; return 0
  fi
  mkdir -p "$font_dir"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  local tmp; tmp=$(mktemp -d); trap "rm -rf $tmp" RETURN
  log_info "下载 JetBrainsMono Nerd Font ..."
  if ! curl -fL "$url" -o "$tmp/jb.zip"; then
    log_warn "无法下载 Nerd Font（无网？），跳过"
    return 0
  fi
  unzip -oq "$tmp/jb.zip" -d "$font_dir/JetBrainsMonoNF"
  fc-cache -f "$font_dir" >/dev/null
  touch "$marker"
  log_ok "Nerd Font 安装完成"
}

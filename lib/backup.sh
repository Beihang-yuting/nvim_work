#!/usr/bin/env bash
backup_nvim_config() {
  local src="$HOME/.config/nvim"
  [ -d "$src" ] || { log_info "无现有 nvim 配置，跳过备份"; return 0; }
  local stamp; stamp=$(date +%Y%m%d-%H%M%S)
  local dst="$HOME/.config/nvim.bak.$stamp"
  mv "$src" "$dst"
  log_ok "已备份旧配置到 $dst"
}

restore_nvim_config() {
  local stamp="$1"
  local pattern="$HOME/.config/nvim.bak.${stamp}*"
  local dst; dst=$(ls -d $pattern 2>/dev/null | head -1)
  [ -n "$dst" ] || { log_err "找不到备份 $pattern"; return 1; }
  rm -rf "$HOME/.config/nvim"
  cp -a "$dst" "$HOME/.config/nvim"
  log_ok "已从 $dst 恢复"
}

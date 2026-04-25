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

uninstall_all() {
  log_step "一键卸载 Neovim / Neovide 环境"

  local dirs=(
    "$HOME/.config/nvim"
    "$HOME/.local/share/nvim"
    "$HOME/.local/state/nvim"
    "$HOME/.cache/nvim"
  )
  local bins=(
    "$HOME/.local/bin/nvim"
    "$HOME/.local/bin/neovide"
  )

  echo
  echo "即将删除以下内容："
  echo
  echo "  配置目录："
  for d in "${dirs[@]}"; do [ -d "$d" ] && echo "    $d"; done
  echo "  二进制文件："
  for b in "${bins[@]}"; do [ -f "$b" ] && echo "    $b"; done
  echo "  备份目录："
  local backups
  backups=$(ls -d "$HOME/.config/nvim.bak."* 2>/dev/null || true)
  if [ -n "$backups" ]; then
    echo "$backups" | while read -r bk; do echo "    $bk"; done
  else
    echo "    (无)"
  fi
  echo

  printf "确认卸载? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS]) ;;
    *) log_info "已取消"; return 0 ;;
  esac

  for d in "${dirs[@]}"; do
    if [ -d "$d" ]; then
      rm -rf "$d"
      log_ok "已删除 $d"
    fi
  done

  for b in "${bins[@]}"; do
    if [ -f "$b" ]; then
      rm -f "$b"
      log_ok "已删除 $b"
    fi
  done

  if [ -n "$backups" ]; then
    printf "同时删除所有备份? [y/N] "
    read -r answer2
    case "$answer2" in
      [yY]|[yY][eE][sS])
        echo "$backups" | while read -r bk; do
          rm -rf "$bk"
          log_ok "已删除 $bk"
        done
        ;;
      *) log_info "保留备份目录" ;;
    esac
  fi

  log_ok "卸载完成。系统包 (ripgrep/fd/nodejs 等) 未删除，如需清理请手动 apt remove"
}

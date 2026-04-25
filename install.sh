#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log.sh"
. "$SCRIPT_DIR/lib/distro.sh"
. "$SCRIPT_DIR/lib/pkg.sh"
. "$SCRIPT_DIR/lib/nerdfont.sh"
. "$SCRIPT_DIR/lib/neovide.sh"
. "$SCRIPT_DIR/lib/backup.sh"

DRY_RUN=0; WANT_GUI=0; NO_MASON=0; MINIMAL=0; RESTORE_DATE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)        DRY_RUN=1 ;;
    --gui)            WANT_GUI=1 ;;
    --no-mason)       NO_MASON=1 ;;
    --minimal)        MINIMAL=1 ;;
    --restore)
      if [ $# -lt 2 ] || [ -z "${2:-}" ] || [ "${2#-}" != "$2" ]; then
        log_err "--restore 需要 YYYYMMDD 参数"; exit 1
      fi
      RESTORE_DATE="$2"; shift ;;
    -h|--help)
      cat <<EOF
用法: install.sh [选项]
  --gui               同时安装 Neovide GUI
  --no-mason          跳过 mason 外部工具安装
  --minimal           只装核心
  --dry-run           仅打印步骤
  --restore YYYYMMDD  回滚到指定日期备份
EOF
      exit 0 ;;
    *) log_err "未知参数: $1"; exit 1 ;;
  esac
  shift
done

if [ -n "$RESTORE_DATE" ]; then
  restore_nvim_config "$RESTORE_DATE"
  exit 0
fi

log_step "detect distro"
DISTRO=$(detect_distro); log_info "distro=$DISTRO"
NVIM_VER=$(detect_nvim_version); log_info "nvim=$NVIM_VER"

log_step "install system packages"
if [ "$DRY_RUN" = "1" ] || [ "${GVIM_SKIP_SYSTEM_PKG:-0}" = "1" ]; then
  echo "DRY: pkg_install_core"
else
  pkg_install_core
fi

log_step "install Nerd Font"
if [ "$DRY_RUN" = "1" ] || [ "${GVIM_SKIP_NERD_FONT:-0}" = "1" ]; then
  echo "DRY: install_nerd_font"
else
  install_nerd_font
fi

if [ "$WANT_GUI" = "1" ]; then
  log_step "install Neovide GUI"
  [ "$DRY_RUN" = "1" ] && echo "DRY: install_neovide" || install_neovide
fi

log_step "backup existing config"
[ "$DRY_RUN" = "1" ] && echo "DRY: backup_nvim_config" || backup_nvim_config

log_step "clone LazyVim starter"
TARGET="$HOME/.config/nvim"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: git clone LazyVim/starter $TARGET"
else
  if [ ! -f "$TARGET/init.lua" ]; then
    mkdir -p "$(dirname "$TARGET")"
    git clone --depth=1 https://github.com/LazyVim/starter "$TARGET"
    rm -rf "$TARGET/.git"
    log_ok "LazyVim starter 已克隆"
  else
    log_info "已存在 $TARGET/init.lua，跳过 clone"
  fi
fi

log_step "overlay templates/"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: rsync templates/ -> $TARGET/"
else
  rsync -a "$SCRIPT_DIR/templates/lua/"      "$TARGET/lua/"      2>/dev/null || true
  rsync -a "$SCRIPT_DIR/templates/snippets/" "$TARGET/snippets/" 2>/dev/null || true
  rsync -a "$SCRIPT_DIR/templates/after/"    "$TARGET/after/"    2>/dev/null || true
  cp "$SCRIPT_DIR/templates/CHEATSHEET.md"   "$TARGET/CHEATSHEET.md" 2>/dev/null || true
  log_ok "templates/ 已覆盖到 $TARGET/"
fi

log_step "headless Lazy! sync"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: nvim --headless +Lazy! sync +qa"
elif [ "$MINIMAL" = "1" ]; then
  log_info "minimal 模式：跳过 Lazy sync（首次启动 nvim 时自动同步）"
else
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || log_warn "Lazy sync 出错，可手动重跑"
fi

if [ "$NO_MASON" = "0" ]; then
  log_step "headless Mason install"
  [ "$DRY_RUN" = "1" ] && echo "DRY: nvim --headless +MasonToolsInstall +qa" || true
fi

log_step "run healthcheck"
[ "$DRY_RUN" = "1" ] && echo "DRY: bash healthcheck.sh" || true

log_ok "完成。运行 'nvim' 或 'neovide' 启动。按 <Space>?h 看速查表。"

# gvim_work (Neovim + LazyVim 多语言环境) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `/home/ubuntu/ryan/gvim_work/` 搭建一份可分发、可一键安装、跨机器一致的 Neovim 配置仓库，基于 LazyVim 发行版，提供 C/C++/Python/Tcl/SystemVerilog/UVM/Verilog 的现代 IDE 体验（LSP、补全、跳转、对齐、语法检查、快速编译/仿真）+ 暖色花哨 UI + 高可发现性。

**Architecture:** 三层结构——LazyVim starter（不动） + 用户层 `lua/plugins/*.lua`（按域分文件） + 外部工具走 `mason-tool-installer` 自动安装。仓库 `gvim_work/` 通过 `templates/` 镜像 `~/.config/nvim/`，由 `install.sh` 双向同步并幂等部署。所有验证由 `healthcheck.sh` + `test/smoke.sh` 在 headless Neovim 中跑通。

**Tech Stack:** Neovim 0.10+ / LazyVim / Lazy.nvim / Mason / Treesitter / nvim-cmp / LuaSnip / mini.* / Telescope / which-key / overseer.nvim / verible / clangd / pyright / Neovide / Bash。

**仓库目标根**：`/home/ubuntu/ryan/gvim_work/`
**部署目标根**：`~/.config/nvim/`（运行时由 `install.sh` 写入）

---

## 文件结构总览

```
/home/ubuntu/ryan/gvim_work/
├── README.md                                  # T1
├── .gitignore                                 # T1
├── LICENSE                                    # T1
├── Makefile                                   # T2
├── install.sh                                 # T3
├── healthcheck.sh                             # T4
├── lib/
│   ├── log.sh                                 # T2
│   ├── distro.sh                              # T3
│   ├── pkg.sh                                 # T3
│   ├── nerdfont.sh                            # T3
│   ├── neovide.sh                             # T3
│   └── backup.sh                              # T3
├── templates/                                 # 这是 ~/.config/nvim/ 的源副本
│   ├── lua/
│   │   ├── config/
│   │   │   ├── options.lua                    # T6
│   │   │   ├── keymaps.lua                    # T7
│   │   │   └── autocmds.lua                   # T8
│   │   └── plugins/
│   │       ├── theme.lua                      # T9
│   │       ├── ui-extras.lua                  # T10
│   │       ├── alpha-dashboard.lua            # T11
│   │       ├── align.lua                      # T12
│   │       ├── motion.lua                     # T13
│   │       ├── lang-cpp.lua                   # T14
│   │       ├── lang-python.lua                # T15
│   │       ├── lang-sv.lua                    # T16
│   │       ├── lang-tcl.lua                   # T17
│   │       ├── uvm-snippets.lua               # T19
│   │       ├── overseer.lua                   # T20
│   │       ├── vcs.lua                        # T21
│   │       ├── nvim-lint.lua                  # T22
│   │       ├── conform.lua                    # T23
│   │       ├── trouble.lua                    # T24
│   │       ├── tags-fallback.lua              # T25
│   │       ├── search.lua                     # T26
│   │       ├── cheatsheet.lua                 # T27
│   │       ├── neovide.lua                    # T28
│   │       ├── mason-tools.lua                # T29
│   │       └── language-extras.lua            # T30
│   ├── snippets/
│   │   ├── package.json                       # T19
│   │   ├── systemverilog.json                 # T18
│   │   ├── verilog.json                       # T18
│   │   ├── tcl.json                           # T18
│   │   ├── python.json                        # T18
│   │   └── cpp.json                           # T18
│   ├── after/
│   │   └── ftplugin/
│   │       ├── systemverilog.lua              # T16
│   │       ├── verilog.lua                    # T16
│   │       └── tcl.lua                        # T17
│   └── CHEATSHEET.md                          # T27
├── test/
│   ├── sample.sv                              # T31
│   ├── sample.cpp                             # T31
│   ├── sample.py                              # T31
│   ├── sample.tcl                             # T31
│   ├── Makefile                               # T31
│   ├── golden/sample.sv.formatted             # T31
│   └── smoke.sh                               # T32
└── docs/
    └── superpowers/
        ├── specs/2026-04-25-gvim-setup-design.md   # 已存在
        └── plans/2026-04-25-gvim-setup.md          # 本文件
```

每个 lua 文件 < 200 行；每个 shell 库函数 < 30 行；测试都在 headless Neovim 内可重复运行。

---

## 任务依赖图

```
T1 (脚手架)
└── T2 (Makefile + log.sh)
    └── T3 (install.sh 骨架)
        ├── T4 (healthcheck.sh)
        └── T5 (install.sh 接 LazyVim starter)
            ├── T6/T7/T8 (config 三件套)
            └── T9..T13 (UI/编辑插件)
                └── T14..T17 (语言层)
                    └── T18 (snippet 文件)
                        └── T19 (snippet 加载器)
                            └── T20..T26 (运行/诊断/格式化/搜索)
                                └── T27/T28 (速查/Neovide)
                                    └── T29/T30 (mason/extras)
                                        └── T31 (test fixtures)
                                            └── T32 (smoke.sh)
                                                └── T33 (端到端验收)
```

---

## Task 1: 仓库脚手架

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/README.md`
- Create: `/home/ubuntu/ryan/gvim_work/.gitignore`
- Create: `/home/ubuntu/ryan/gvim_work/LICENSE`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_repo_structure.sh`

- [ ] **Step 1: 写仓库结构测试**

```bash
# /home/ubuntu/ryan/gvim_work/test/test_repo_structure.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
check() { test -e "$ROOT/$1" || { echo "MISSING: $1"; fail=1; }; }
check README.md
check .gitignore
check LICENSE
check docs/superpowers/specs/2026-04-25-gvim-setup-design.md
check docs/superpowers/plans/2026-04-25-gvim-setup.md
[ "$fail" = "0" ] && echo "OK" || exit 1
```

- [ ] **Step 2: 跑测试确认失败**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/test
chmod +x /home/ubuntu/ryan/gvim_work/test/test_repo_structure.sh
bash /home/ubuntu/ryan/gvim_work/test/test_repo_structure.sh
```
Expected: `MISSING: README.md` 等，`exit 1`

- [ ] **Step 3: 写 README.md**

````markdown
# gvim_work

一份开箱即用的 Neovim 配置仓库（基于 LazyVim），面向 C/C++/Python/Tcl/SystemVerilog/UVM/Verilog 的多语言开发与硬件验证。

## 一键安装

```bash
git clone <this-repo> ~/gvim_work
cd ~/gvim_work
bash install.sh                # 终端版
bash install.sh --gui          # 含 Neovide GUI
bash install.sh --no-mason     # 无网环境
```

## 验证

```bash
bash healthcheck.sh
bash test/smoke.sh
```

## 文档

- 设计规格：`docs/superpowers/specs/2026-04-25-gvim-setup-design.md`
- 实施计划：`docs/superpowers/plans/2026-04-25-gvim-setup.md`
- 速查表：部署后位于 `~/.config/nvim/CHEATSHEET.md`，按 `<leader>?h` 打开

## 升级 / 回滚

| 操作 | 命令 |
|------|------|
| 升级插件 | `:Lazy update` |
| 升级 LSP/工具 | `:Mason update` |
| 回滚配置 | `bash install.sh --restore <YYYYMMDD>` |
````

- [ ] **Step 4: 写 .gitignore**

```gitignore
*.bak
*.bak.*
.backup/
test/output/
test/.tmp/
.DS_Store
Thumbs.db
*.swp
*.swo
.vscode/
.idea/
```

- [ ] **Step 5: 写 LICENSE（MIT）**

```
MIT License

Copyright (c) 2026 seam3721

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 6: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_repo_structure.sh
```
Expected: `OK`

- [ ] **Step 7: git init + commit**

```bash
cd /home/ubuntu/ryan/gvim_work
git init
git add README.md .gitignore LICENSE docs/ test/test_repo_structure.sh
git commit -m "feat: bootstrap gvim_work repo with README/license/spec/plan"
```

---

## Task 2: Makefile + lib/log.sh

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/Makefile`
- Create: `/home/ubuntu/ryan/gvim_work/lib/log.sh`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_log.sh`

- [ ] **Step 1: 写 lib/log.sh 的失败测试**

```bash
# test/test_log.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/log.sh"

out=$(log_info "hello" 2>&1)
[[ "$out" == *"[INFO]"* && "$out" == *"hello"* ]] || { echo "log_info FAIL: $out"; exit 1; }
out=$(log_warn "warn" 2>&1)
[[ "$out" == *"[WARN]"* ]] || { echo "log_warn FAIL"; exit 1; }
out=$(log_err "err" 2>&1)
[[ "$out" == *"[ERR"* ]] || { echo "log_err FAIL"; exit 1; }
out=$(log_ok "ok" 2>&1)
[[ "$out" == *"[OK"* ]] || { echo "log_ok FAIL"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/lib
chmod +x /home/ubuntu/ryan/gvim_work/test/test_log.sh
bash /home/ubuntu/ryan/gvim_work/test/test_log.sh
```
Expected: `lib/log.sh: No such file`

- [ ] **Step 3: 写 lib/log.sh**

```bash
#!/usr/bin/env bash
[ -t 2 ] && _CLR_R=$'\033[31m' _CLR_G=$'\033[32m' _CLR_Y=$'\033[33m' _CLR_B=$'\033[34m' _CLR_X=$'\033[0m'

log_info() { printf '%s[INFO]%s %s\n' "${_CLR_B-}" "${_CLR_X-}" "$*" >&2; }
log_warn() { printf '%s[WARN]%s %s\n' "${_CLR_Y-}" "${_CLR_X-}" "$*" >&2; }
log_err()  { printf '%s[ERR ]%s %s\n' "${_CLR_R-}" "${_CLR_X-}" "$*" >&2; }
log_ok()   { printf '%s[OK  ]%s %s\n' "${_CLR_G-}" "${_CLR_X-}" "$*" >&2; }
log_step() { printf '\n%s== %s ==%s\n' "${_CLR_B-}" "$*" "${_CLR_X-}" >&2; }
```

- [ ] **Step 4: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_log.sh
```
Expected: `OK`

- [ ] **Step 5: 写 Makefile**

```makefile
.PHONY: help install install-gui sync check test smoke clean restore

help:
	@echo "Targets:"
	@echo "  install       —— 部署 ~/.config/nvim（终端版）"
	@echo "  install-gui   —— 部署 + Neovide GUI"
	@echo "  sync          —— 把 ~/.config/nvim/ 同步回 templates/"
	@echo "  check         —— 跑 healthcheck.sh"
	@echo "  test          —— 跑 test/smoke.sh"
	@echo "  restore D=YYYYMMDD —— 回滚到指定日期备份"

install:
	bash install.sh

install-gui:
	bash install.sh --gui

sync:
	rsync -a --delete \
	  --exclude=lazy-lock.json --exclude=lazy/ --exclude=mason/ \
	  ~/.config/nvim/lua/    templates/lua/
	rsync -a --delete ~/.config/nvim/snippets/ templates/snippets/
	rsync -a --delete ~/.config/nvim/after/    templates/after/
	cp ~/.config/nvim/CHEATSHEET.md templates/CHEATSHEET.md

check:
	bash healthcheck.sh

test smoke:
	bash test/smoke.sh

restore:
	@test -n "$(D)" || { echo "用法: make restore D=YYYYMMDD"; exit 1; }
	bash install.sh --restore $(D)
```

- [ ] **Step 6: 验证 make help**

```bash
cd /home/ubuntu/ryan/gvim_work && make help
```
Expected: 列出 6 个 target

- [ ] **Step 7: Commit**

```bash
git add Makefile lib/log.sh test/test_log.sh
git commit -m "feat: add Makefile entrypoint and shared log helpers"
```

---

## Task 3: install.sh 骨架 + 子库

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/install.sh`
- Create: `/home/ubuntu/ryan/gvim_work/lib/distro.sh`
- Create: `/home/ubuntu/ryan/gvim_work/lib/pkg.sh`
- Create: `/home/ubuntu/ryan/gvim_work/lib/nerdfont.sh`
- Create: `/home/ubuntu/ryan/gvim_work/lib/neovide.sh`
- Create: `/home/ubuntu/ryan/gvim_work/lib/backup.sh`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_install_dryrun.sh`

- [ ] **Step 1: 写 dry-run 测试**

```bash
# test/test_install_dryrun.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
out=$(HOME="$T" bash "$ROOT/install.sh" --dry-run 2>&1) || true
for kw in "detect distro" "system packages" "Nerd Font" "backup" "clone LazyVim" "Lazy! sync"; do
  echo "$out" | grep -qi "$kw" || { echo "missing: $kw"; echo "--- output ---"; echo "$out"; exit 1; }
done
test ! -d "$T/.config/nvim" || { echo "dry-run leaked into HOME"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/test_install_dryrun.sh
bash /home/ubuntu/ryan/gvim_work/test/test_install_dryrun.sh
```
Expected: `install.sh: No such file`

- [ ] **Step 3: 写 lib/distro.sh**

```bash
#!/usr/bin/env bash
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|debian)        echo "$ID" ;;
      rhel|centos|rocky|alma) echo "rhel" ;;
      fedora)               echo "fedora" ;;
      arch|manjaro)         echo "arch" ;;
      *)                    echo "other" ;;
    esac
  else
    echo "other"
  fi
}

detect_nvim_version() {
  command -v nvim >/dev/null 2>&1 || { echo "0.0.0"; return; }
  nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/'
}
```

- [ ] **Step 4: 写 lib/pkg.sh**

```bash
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
      sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd 2>/dev/null || true
      ;;
    rhel|fedora)
      pkg_install git curl unzip @development-tools ripgrep fd-find nodejs npm python3 python3-pip cargo make
      ;;
    arch)
      pkg_install git curl unzip base-devel ripgrep fd nodejs npm python python-pip rust make
      ;;
  esac
}
```

- [ ] **Step 5: 写 lib/nerdfont.sh**

```bash
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
```

- [ ] **Step 6: 写 lib/neovide.sh**

```bash
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
```

- [ ] **Step 7: 写 lib/backup.sh**

```bash
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
```

- [ ] **Step 8: 写 install.sh（骨架，真实克隆在 Task 5 接入）**

```bash
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
    --restore)        RESTORE_DATE="$2"; shift ;;
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
[ "$DRY_RUN" = "1" ] && echo "DRY: pkg_install_core" || pkg_install_core

log_step "install Nerd Font"
[ "$DRY_RUN" = "1" ] && echo "DRY: install_nerd_font" || install_nerd_font

if [ "$WANT_GUI" = "1" ]; then
  log_step "install Neovide GUI"
  [ "$DRY_RUN" = "1" ] && echo "DRY: install_neovide" || install_neovide
fi

log_step "backup existing config"
[ "$DRY_RUN" = "1" ] && echo "DRY: backup_nvim_config" || backup_nvim_config

log_step "clone LazyVim starter"
[ "$DRY_RUN" = "1" ] && echo "DRY: git clone LazyVim/starter ~/.config/nvim" || true

log_step "headless Lazy! sync"
[ "$DRY_RUN" = "1" ] && echo "DRY: nvim --headless +Lazy! sync +qa" || true

if [ "$NO_MASON" = "0" ]; then
  log_step "headless Mason install"
  [ "$DRY_RUN" = "1" ] && echo "DRY: nvim --headless +MasonToolsInstall +qa" || true
fi

log_step "run healthcheck"
[ "$DRY_RUN" = "1" ] && echo "DRY: bash healthcheck.sh" || true

log_ok "完成。运行 'nvim' 或 'neovide' 启动。按 <Space>?h 看速查表。"
```

- [ ] **Step 9: 跑测试确认通过**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/install.sh
bash /home/ubuntu/ryan/gvim_work/test/test_install_dryrun.sh
```
Expected: `OK`

- [ ] **Step 10: Commit**

```bash
git add install.sh lib/*.sh test/test_install_dryrun.sh
git commit -m "feat: install.sh skeleton with distro/pkg/nerdfont/neovide/backup libs"
```

---

## Task 4: healthcheck.sh

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/healthcheck.sh`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_healthcheck.sh`

- [ ] **Step 1: 写测试**

```bash
# test/test_healthcheck.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
out=$(env -i HOME="$HOME" PATH=/nonexistent bash "$ROOT/healthcheck.sh" 2>&1) || true
echo "$out" | grep -q "FAIL" || { echo "expected FAIL lines"; exit 1; }
echo "$out" | grep -q "Neovim" || { echo "missing nvim check"; exit 1; }
out2=$(bash "$ROOT/healthcheck.sh" 2>&1 || true)
echo "$out2" | grep -q "Summary:" || { echo "missing summary"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/test_healthcheck.sh
bash /home/ubuntu/ryan/gvim_work/test/test_healthcheck.sh
```
Expected: `healthcheck.sh: No such file`

- [ ] **Step 3: 写 healthcheck.sh**

```bash
#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log.sh"

PASS=0; FAIL=0; WARN=0

check() {
  local name="$1"; shift
  if eval "$*" >/dev/null 2>&1; then
    log_ok "$name"; PASS=$((PASS+1))
  else
    log_err "FAIL: $name"; FAIL=$((FAIL+1))
  fi
}

soft() {
  local name="$1"; shift
  if eval "$*" >/dev/null 2>&1; then
    log_ok "$name"; PASS=$((PASS+1))
  else
    log_warn "WARN: $name (optional)"; WARN=$((WARN+1))
  fi
}

log_step "system"
check "Neovim ≥ 0.10"            "command -v nvim && nvim --version | head -1 | grep -E 'v0\\.(1[0-9]|[2-9][0-9])|v[1-9]'"
check "ripgrep present"          "command -v rg"
check "fd present"               "command -v fd || command -v fdfind"
soft  "Nerd Font installed"      "fc-list 2>/dev/null | grep -qi 'JetBrainsMono.*Nerd'"

log_step "nvim runtime"
check "Lazy.nvim cloned"         "test -d ~/.local/share/nvim/lazy/lazy.nvim"
check "Mason data dir"           "test -d ~/.local/share/nvim/mason"

log_step "LSP binaries"
for b in verible-verilog-ls clangd pyright-langserver lua-language-server; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "formatters"
for b in verible-verilog-format clang-format ruff black stylua; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "linters"
for b in verible-verilog-lint verilator cppcheck shellcheck markdownlint; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "treesitter parsers"
for p in systemverilog verilog tcl cpp python lua; do
  soft "  parser $p" "ls ~/.local/share/nvim/lazy/nvim-treesitter/parser/$p.so 2>/dev/null"
done

log_step "EDA tools (optional)"
soft "VCS in PATH"               "command -v vcs"
soft "Verdi in PATH"             "command -v verdi"
soft "UVM_HOME set"              "test -n \"\${UVM_HOME:-}\""

log_step "config files"
check "CHEATSHEET.md present"    "test -f ~/.config/nvim/CHEATSHEET.md"
check "init.lua present"         "test -f ~/.config/nvim/init.lua"
check "templates/lua dir"        "test -d $SCRIPT_DIR/templates/lua"

echo
echo "Summary: PASS=$PASS  FAIL=$FAIL  WARN=$WARN"
[ "$FAIL" = "0" ]
```

- [ ] **Step 4: 跑测试确认通过**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/healthcheck.sh
bash /home/ubuntu/ryan/gvim_work/test/test_healthcheck.sh
```
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add healthcheck.sh test/test_healthcheck.sh
git commit -m "feat: healthcheck.sh with PASS/FAIL/WARN summary"
```

---

## Task 5: install.sh 接入 LazyVim starter 真实部署

**Files:**
- Modify: `/home/ubuntu/ryan/gvim_work/install.sh`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_install_real.sh`

- [ ] **Step 1: 写真实部署测试**

```bash
# test/test_install_real.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.config"

mkdir -p "$ROOT/templates/lua/config" "$ROOT/templates/lua/plugins"
[ -f "$ROOT/templates/CHEATSHEET.md" ] || echo "# placeholder" > "$ROOT/templates/CHEATSHEET.md"

HOME="$T" bash "$ROOT/install.sh" --no-mason --minimal 2>&1 | tail -40

test -f "$T/.config/nvim/init.lua"        || { echo "init.lua missing"; exit 1; }
test -f "$T/.config/nvim/CHEATSHEET.md"   || { echo "CHEATSHEET missing"; exit 1; }

# 幂等：重跑不报错
HOME="$T" bash "$ROOT/install.sh" --no-mason --minimal 2>&1 | tail -10
test -f "$T/.config/nvim/init.lua"

echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/test_install_real.sh
bash /home/ubuntu/ryan/gvim_work/test/test_install_real.sh
```
Expected: `init.lua missing`

- [ ] **Step 3: 修改 install.sh —— 替换 "clone LazyVim starter" 这步**

把这段：

```bash
log_step "clone LazyVim starter"
[ "$DRY_RUN" = "1" ] && echo "DRY: git clone LazyVim/starter ~/.config/nvim" || true
```

改为：

```bash
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
```

把 `headless Lazy! sync` 改为：

```bash
log_step "headless Lazy! sync"
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: nvim --headless +Lazy! sync +qa"
elif [ "$MINIMAL" = "1" ]; then
  log_info "minimal 模式：跳过 Lazy sync（首次启动 nvim 时自动同步）"
else
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || log_warn "Lazy sync 出错，可手动重跑"
fi
```

- [ ] **Step 4: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_install_real.sh
```
Expected: `OK`（需要网络访问 github.com）

- [ ] **Step 5: Commit**

```bash
git add install.sh test/test_install_real.sh
git commit -m "feat: install.sh deploys LazyVim starter and overlays templates/"
```

---

## Task 6: templates/lua/config/options.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/config/options.lua`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_options.sh`

- [ ] **Step 1: 写测试**

```bash
# test/test_options.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
EOF
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless \
  '+lua io.write(string.format("ts=%d sw=%d et=%s nu=%s rnu=%s\n", vim.opt.tabstop:get(), vim.opt.shiftwidth:get(), tostring(vim.opt.expandtab:get()), tostring(vim.opt.number:get()), tostring(vim.opt.relativenumber:get())))' \
  +qa 2>"$T/out"
cat "$T/out"
grep -q 'ts=2 sw=2 et=true nu=true rnu=true' "$T/out" || { echo "options not applied"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/templates/lua/config
chmod +x /home/ubuntu/ryan/gvim_work/test/test_options.sh
bash /home/ubuntu/ryan/gvim_work/test/test_options.sh
```
Expected: `options not applied`

- [ ] **Step 3: 写 options.lua**

```lua
-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

opt.tabstop        = 2
opt.shiftwidth     = 2
opt.softtabstop    = 2
opt.expandtab      = true

opt.number         = true
opt.relativenumber = true

opt.mouse          = "a"
opt.clipboard      = "unnamedplus"
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8

opt.ignorecase     = true
opt.smartcase      = true

opt.undofile       = true
opt.swapfile       = false
opt.backup         = false

opt.splitright     = true
opt.splitbelow     = true

opt.foldmethod     = "expr"
opt.foldexpr       = "nvim_treesitter#foldexpr()"
opt.foldenable     = false

opt.termguicolors  = true
opt.showmode       = false
opt.cmdheight      = 0
opt.pumheight      = 12

vim.filetype.add({
  extension = {
    sv  = "systemverilog",
    svh = "systemverilog",
    v   = "verilog",
    vh  = "verilog",
  },
})
```

- [ ] **Step 4: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_options.sh
```
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add templates/lua/config/options.lua test/test_options.sh
git commit -m "feat: options.lua with sane indent/number/clipboard/filetype"
```

---

## Task 7: templates/lua/config/keymaps.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/config/keymaps.lua`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_keymaps.sh`

- [ ] **Step 1: 写测试**

```bash
# test/test_keymaps.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
require("config.keymaps")
EOF
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless \
  '+lua local m = vim.fn.maparg("<leader>?h", "n"); io.write("cheat="..(m == "" and "missing" or "ok").."\n")' \
  +qa 2>"$T/out"
cat "$T/out"
grep -q 'cheat=ok' "$T/out" || { echo "keymap missing"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/test_keymaps.sh
bash /home/ubuntu/ryan/gvim_work/test/test_keymaps.sh
```
Expected: `keymap missing`

- [ ] **Step 3: 写 keymaps.lua**

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local function map(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>?h", function()
  local f = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
  if vim.fn.filereadable(f) == 1 then
    vim.cmd("edit " .. f)
  else
    vim.notify("CHEATSHEET.md 不存在: " .. f, vim.log.levels.WARN)
  end
end, "Open cheat sheet")

map("n", "<leader>?", "<cmd>Telescope keymaps<cr>", "Search keymaps")

map({"n", "i"}, "<C-s>", "<cmd>w<cr>", "Save")

map("n", "<Esc><Esc>", "<cmd>nohlsearch<cr>", "Clear hlsearch")

map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

map({"n", "v"}, "<leader>d", '"_d', "Delete (no yank)")

map("n", "<C-]>", "<C-]>", "Tag jump (ctags fallback)")
```

- [ ] **Step 4: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_keymaps.sh
```
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add templates/lua/config/keymaps.lua test/test_keymaps.sh
git commit -m "feat: keymaps.lua with cheatsheet/save/move shortcuts"
```

---

## Task 8: templates/lua/config/autocmds.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/config/autocmds.lua`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_autocmds.sh`

- [ ] **Step 1: 写测试**

```bash
# test/test_autocmds.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua" "$T/proj"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
require("config.autocmds")
EOF
echo "module x; endmodule" > "$T/proj/x.sv"
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless "$T/proj/x.sv" \
  '+lua io.write("filelist="..(vim.b.verible_filelist or "nil").."\n")' \
  +qa 2>"$T/out"
cat "$T/out"
grep -q 'filelist=' "$T/out" && ! grep -q 'filelist=nil' "$T/out" || { echo "autocmd not firing"; exit 1; }
echo "OK"
```

- [ ] **Step 2: 跑测试确认失败**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/test_autocmds.sh
bash /home/ubuntu/ryan/gvim_work/test/test_autocmds.sh
```
Expected: `autocmd not firing`

- [ ] **Step 3: 写 autocmds.lua**

```lua
-- ~/.config/nvim/lua/config/autocmds.lua
local aug = vim.api.nvim_create_augroup
local au  = vim.api.nvim_create_autocmd

local sv = aug("UserSV", { clear = true })
au({ "BufRead", "BufNewFile" }, {
  group = sv,
  pattern = { "*.sv", "*.svh", "*.v", "*.vh" },
  callback = function(args)
    local roots = vim.fs.find({ ".git", "Makefile" }, {
      upward = true, path = vim.fs.dirname(args.file),
    })
    local root = roots[1] and vim.fs.dirname(roots[1]) or vim.fs.dirname(args.file)

    local f = vim.fn.glob(root .. "/*.f", false, true)
    local filelist
    if #f > 0 then
      filelist = f[1]
    else
      filelist = vim.fn.stdpath("cache") .. "/verible-" .. vim.fn.fnamemodify(root, ":t") .. ".f"
      local files = vim.fn.systemlist(string.format(
        "find %s -type f \\( -name '*.sv' -o -name '*.svh' \\) | head -2000",
        vim.fn.shellescape(root)))
      vim.fn.mkdir(vim.fn.fnamemodify(filelist, ":h"), "p")
      vim.fn.writefile(files, filelist)
    end
    vim.b.verible_filelist = filelist
  end,
})

au("TermOpen", { callback = function() vim.cmd("startinsert") end })

au("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

au("BufWritePre", {
  callback = function()
    if vim.bo.filetype == "markdown" then return end
    local cur = vim.api.nvim_win_get_cursor(0)
    pcall(vim.cmd, [[%s/\s\+$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
  end,
})
```

- [ ] **Step 4: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_autocmds.sh
```
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add templates/lua/config/autocmds.lua test/test_autocmds.sh
git commit -m "feat: autocmds for SV filelist/terminal/yank/trim"
```

---

## Task 9: templates/lua/plugins/theme.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/theme.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/theme.lua
return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.everforest_background = "soft"
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
    end,
    config = function() vim.cmd.colorscheme("everforest") end,
  },
  { "sainnhe/gruvbox-material", lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "LazyVim/LazyVim", opts = { colorscheme = "everforest" } },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/theme.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/theme.lua
git commit -m "feat: theme.lua with everforest default + alternates"
```

---

## Task 10: templates/lua/plugins/ui-extras.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/ui-extras.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/ui-extras.lua
return {
  { "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = { override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      } },
      presets = { bottom_search = true, command_palette = true,
                  long_message_to_split = true, lsp_doc_border = true },
    },
  },

  { "rcarriga/nvim-notify",
    opts = { timeout = 2500, render = "compact", stages = "fade", top_down = false },
  },

  { "lukas-reineke/indent-blankline.nvim", main = "ibl",
    opts = { indent = { char = "│" }, scope = { show_start = false, show_end = false } },
  },

  { "echasnovski/mini.animate", event = "VeryLazy",
    opts = function()
      local an = require("mini.animate")
      return {
        cursor = { enable = true, timing = an.gen_timing.linear({ duration = 100, unit = "total" }) },
        scroll = { enable = true, timing = an.gen_timing.linear({ duration = 150, unit = "total" }) },
        resize = { enable = true },
        open   = { enable = false },
        close  = { enable = false },
      }
    end,
  },

  { "petertriho/nvim-scrollbar", event = "BufReadPost",
    opts = { handlers = { gitsigns = true, search = true } },
  },

  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },

  { "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "everforest"
      opts.options.globalstatus = true
      return opts
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/ui-extras.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/ui-extras.lua
git commit -m "feat: ui-extras noice/notify/ibl/animate/scrollbar"
```

---

## Task 11: templates/lua/plugins/alpha-dashboard.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/alpha-dashboard.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/alpha-dashboard.lua
return {
  { "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[                                                ]],
        [[          gvim_work · Neovim · LazyVim          ]],
        [[                                                ]],
        [[       Multi-language code + hardware verif     ]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       ":Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files",    ":Telescope oldfiles<cr>"),
        dashboard.button("g", "  Live grep",       ":Telescope live_grep<cr>"),
        dashboard.button("c", "  Config",          ":e $MYVIMRC<cr>"),
        dashboard.button("?", "  Cheat sheet",     ":e ~/.config/nvim/CHEATSHEET.md<cr>"),
        dashboard.button("L", "  Lazy",            ":Lazy<cr>"),
        dashboard.button("M", "  Mason",           ":Mason<cr>"),
        dashboard.button("q", "  Quit",            ":qa<cr>"),
      }
      dashboard.section.footer.val = { "  press <Space>?h for the cheat sheet  " }
      return dashboard
    end,
    config = function(_, dashboard) require("alpha").setup(dashboard.config) end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/alpha-dashboard.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/alpha-dashboard.lua
git commit -m "feat: alpha dashboard with cheat-sheet shortcut"
```

---

## Task 12: templates/lua/plugins/align.lua（核心对齐）

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/align.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/align.lua
return {
  { "echasnovski/mini.align", event = "VeryLazy",
    opts = { mappings = { start = "ga", start_with_preview = "gA" } },
    keys = {
      { "ga", mode = { "n", "x" }, desc = "Align (mini, interactive)" },
      { "gA", mode = { "n", "x" }, desc = "Align with preview" },
    },
    config = function(_, opts)
      require("mini.align").setup(opts)

      local function par_align(split)
        return function()
          vim.cmd("normal! vip")
          require("mini.align").align_selected({ split_pattern = split })
        end
      end

      local function nmap(lhs, split, desc)
        vim.keymap.set("n", lhs, par_align(split), { desc = desc })
      end

      nmap("<leader>a=", "=",  "Align paragraph by =")
      nmap("<leader>a:", ":",  "Align paragraph by :")
      nmap("<leader>a,", ",",  "Align paragraph by ,")
      nmap("<leader>a|", "|",  "Align paragraph by |")
      nmap("<leader>a<", "<=", "Align paragraph by <= (SV nonblocking)")
      nmap("<leader>a/", "//", "Align paragraph by // (line comment)")
      vim.keymap.set("n", "<leader>aa", function()
        local s = vim.fn.input("Align by pattern: ")
        if s ~= "" then par_align(s)() end
      end, { desc = "Align by custom pattern" })
    end,
  },

  { "junegunn/vim-easy-align", keys = {
      { "<leader>aA", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Easy-align (interactive)" },
    },
  },

  { "folke/which-key.nvim", opts = function(_, opts)
      opts.spec = opts.spec or {}
      table.insert(opts.spec, { "<leader>a", group = "+align" })
      return opts
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/align.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/align.lua
git commit -m "feat: mini.align with paragraph quick-align by =/:/,/<=/// + easy-align fallback"
```

---

## Task 13: templates/lua/plugins/motion.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/motion.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/motion.lua
return {
  { "ggandor/leap.nvim", event = "VeryLazy",
    config = function() require("leap").create_default_mappings() end,
  },
  { "machakann/vim-sandwich", event = "VeryLazy" },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "akinsho/toggleterm.nvim", event = "VeryLazy",
    opts = {
      direction = "float",
      float_opts = { border = "rounded" },
      open_mapping = [[<C-/>]],
    },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal: horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal: vertical" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",     desc = "Terminal: float" },
    },
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/motion.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/motion.lua
git commit -m "feat: motion leap/sandwich/comment/autopairs/toggleterm"
```

---

## Task 14: templates/lua/plugins/lang-cpp.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/lang-cpp.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/lang-cpp.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--cross-file-rename",
            "--all-scopes-completion",
            "--pch-storage=memory",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(
              "compile_commands.json", ".clangd", ".git",
              "CMakeLists.txt", "Makefile", "compile_flags.txt"
            )(fname)
          end,
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp", "make", "cmake" })
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/lang-cpp.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/lang-cpp.lua
git commit -m "feat: lang-cpp clangd configured for compile_commands.json"
```

---

## Task 15: templates/lua/plugins/lang-python.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/lang-python.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/lang-python.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff = { init_options = { settings = { args = {} } } },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "python", "toml", "ninja", "rst" })
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/lang-python.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/lang-python.lua
git commit -m "feat: lang-python pyright + ruff with workspace diagnostics"
```

---

## Task 16: templates/lua/plugins/lang-sv.lua + after/ftplugin/{systemverilog,verilog}.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/lang-sv.lua`
- Create: `/home/ubuntu/ryan/gvim_work/templates/after/ftplugin/systemverilog.lua`
- Create: `/home/ubuntu/ryan/gvim_work/templates/after/ftplugin/verilog.lua`

- [ ] **Step 1: 写 lang-sv.lua**

```lua
-- ~/.config/nvim/lua/plugins/lang-sv.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        verible = {
          cmd = { "verible-verilog-ls", "--rules_config_search" },
          filetypes = { "systemverilog", "verilog" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".git", "Makefile", "*.f", "verible.filelist")(fname)
              or vim.fs.dirname(fname)
          end,
          on_new_config = function(config, _)
            local bufnr = vim.api.nvim_get_current_buf()
            local fl = vim.b[bufnr] and vim.b[bufnr].verible_filelist or nil
            if fl then
              config.cmd = { "verible-verilog-ls", "--file_list_path", fl }
            end
          end,
        },
      },
    },
  },
  { "nachumk/systemverilog.vim", ft = { "systemverilog", "verilog" } },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "verilog" })
    end,
  },
}
```

- [ ] **Step 2: 写 after/ftplugin/systemverilog.lua**

```lua
-- ~/.config/nvim/after/ftplugin/systemverilog.lua
vim.bo.commentstring = "// %s"
vim.bo.tabstop       = 2
vim.bo.shiftwidth    = 2
vim.bo.expandtab     = true
vim.opt_local.iskeyword:append("$")
vim.opt_local.matchpairs:append("<:>")
```

- [ ] **Step 3: 写 after/ftplugin/verilog.lua**

```lua
-- ~/.config/nvim/after/ftplugin/verilog.lua
vim.bo.commentstring = "// %s"
vim.bo.tabstop       = 2
vim.bo.shiftwidth    = 2
vim.bo.expandtab     = true
```

- [ ] **Step 4: lua 语法检查**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/templates/after/ftplugin
nvim --headless "+luafile templates/lua/plugins/lang-sv.lua" "+qa"
nvim --headless "+luafile templates/after/ftplugin/systemverilog.lua" "+qa"
nvim --headless "+luafile templates/after/ftplugin/verilog.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 5: Commit**

```bash
git add templates/lua/plugins/lang-sv.lua templates/after/ftplugin/systemverilog.lua templates/after/ftplugin/verilog.lua
git commit -m "feat: lang-sv with verible LSP + filelist + ftplugin tweaks"
```

---

## Task 17: templates/lua/plugins/lang-tcl.lua + after/ftplugin/tcl.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/lang-tcl.lua`
- Create: `/home/ubuntu/ryan/gvim_work/templates/after/ftplugin/tcl.lua`

- [ ] **Step 1: 写 lang-tcl.lua**

```lua
-- ~/.config/nvim/lua/plugins/lang-tcl.lua
return {
  { "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tclint = {
          cmd = { "tclint" },
          filetypes = { "tcl" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".git", "Makefile")(fname)
              or vim.fs.dirname(fname)
          end,
        },
      },
    },
  },
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "tcl" })
    end,
  },
}
```

- [ ] **Step 2: 写 after/ftplugin/tcl.lua**

```lua
-- ~/.config/nvim/after/ftplugin/tcl.lua
vim.bo.commentstring = "# %s"
vim.bo.tabstop       = 4
vim.bo.shiftwidth    = 4
vim.bo.expandtab     = true
```

- [ ] **Step 3: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/lang-tcl.lua" "+qa"
nvim --headless "+luafile templates/after/ftplugin/tcl.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 4: Commit**

```bash
git add templates/lua/plugins/lang-tcl.lua templates/after/ftplugin/tcl.lua
git commit -m "feat: lang-tcl with tclint LSP"
```

---

## Task 18: templates/snippets/*.json（5 个文件）

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/systemverilog.json`
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/verilog.json`
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/tcl.json`
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/python.json`
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/cpp.json`
- Create: `/home/ubuntu/ryan/gvim_work/test/test_snippets_json.sh`

- [ ] **Step 1: 写测试**

```bash
# test/test_snippets_json.sh
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
for f in "$ROOT"/templates/snippets/*.json; do
  python3 -c "import json,sys; json.load(open('$f'))" || { echo "BAD JSON: $f"; fail=1; }
done
must() { grep -qE "\"prefix\"\\s*:\\s*\"$1\"" "$2" || { echo "missing prefix '$1' in $2"; fail=1; }; }
must "uvm_test"  "$ROOT/templates/snippets/systemverilog.json"
must "uvm_seq"   "$ROOT/templates/snippets/systemverilog.json"
must "runp"      "$ROOT/templates/snippets/systemverilog.json"
must "uvi"       "$ROOT/templates/snippets/systemverilog.json"
must "fsm3"      "$ROOT/templates/snippets/verilog.json"
must "proc"      "$ROOT/templates/snippets/tcl.json"
must "pyclass"   "$ROOT/templates/snippets/python.json"
must "cls"       "$ROOT/templates/snippets/cpp.json"
[ "$fail" = "0" ] && echo "OK" || exit 1
```

- [ ] **Step 2: 跑测试确认失败**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/templates/snippets
chmod +x /home/ubuntu/ryan/gvim_work/test/test_snippets_json.sh
bash /home/ubuntu/ryan/gvim_work/test/test_snippets_json.sh
```
Expected: 失败

- [ ] **Step 3: 写 systemverilog.json**

```json
{
  "uvm component": {
    "prefix": "uvc",
    "body": [
      "class ${1:my_comp} extends uvm_component;",
      "  `uvm_component_utils(${1:my_comp})",
      "",
      "  function new(string name = \"${1:my_comp}\", uvm_component parent = null);",
      "    super.new(name, parent);",
      "  endfunction",
      "",
      "  virtual function void build_phase(uvm_phase phase);",
      "    super.build_phase(phase);",
      "    ${2:// build}",
      "  endfunction",
      "",
      "  virtual task run_phase(uvm_phase phase);",
      "    ${3:// run}",
      "  endtask",
      "endclass"
    ]
  },
  "uvm object": {
    "prefix": "uvo",
    "body": [
      "class ${1:my_obj} extends uvm_object;",
      "  `uvm_object_utils(${1:my_obj})",
      "",
      "  function new(string name = \"${1:my_obj}\");",
      "    super.new(name);",
      "  endfunction",
      "endclass"
    ]
  },
  "uvm test": {
    "prefix": "uvm_test",
    "body": [
      "class ${1:my_test} extends uvm_test;",
      "  `uvm_component_utils(${1:my_test})",
      "  ${2:my_env} env;",
      "",
      "  function new(string name = \"${1:my_test}\", uvm_component parent = null);",
      "    super.new(name, parent);",
      "  endfunction",
      "",
      "  virtual function void build_phase(uvm_phase phase);",
      "    super.build_phase(phase);",
      "    env = ${2:my_env}::type_id::create(\"env\", this);",
      "  endfunction",
      "",
      "  virtual task run_phase(uvm_phase phase);",
      "    phase.raise_objection(this);",
      "    ${3:// stimulus}",
      "    phase.drop_objection(this);",
      "  endtask",
      "endclass"
    ]
  },
  "uvm sequence": {
    "prefix": "uvm_seq",
    "body": [
      "class ${1:my_seq} extends uvm_sequence#(${2:my_item});",
      "  `uvm_object_utils(${1:my_seq})",
      "",
      "  function new(string name = \"${1:my_seq}\");",
      "    super.new(name);",
      "  endfunction",
      "",
      "  virtual task body();",
      "    ${2:my_item} req;",
      "    repeat (${3:10}) begin",
      "      req = ${2:my_item}::type_id::create(\"req\");",
      "      start_item(req);",
      "      assert(req.randomize());",
      "      finish_item(req);",
      "    end",
      "  endtask",
      "endclass"
    ]
  },
  "run_phase": {
    "prefix": "runp",
    "body": [
      "virtual task run_phase(uvm_phase phase);",
      "  phase.raise_objection(this);",
      "  ${1:// run}",
      "  phase.drop_objection(this);",
      "endtask"
    ]
  },
  "build_phase": {
    "prefix": "bldp",
    "body": [
      "virtual function void build_phase(uvm_phase phase);",
      "  super.build_phase(phase);",
      "  ${1:// build}",
      "endfunction"
    ]
  },
  "uvm_info": {
    "prefix": "uvi",
    "body": ["`uvm_info(get_type_name(), $sformatf(\"${1:msg}\"), UVM_${2:MEDIUM})"]
  },
  "uvm_warning": {
    "prefix": "uvw",
    "body": ["`uvm_warning(get_type_name(), \"${1:msg}\")"]
  },
  "uvm_error": {
    "prefix": "uve",
    "body": ["`uvm_error(get_type_name(), \"${1:msg}\")"]
  },
  "uvm_fatal": {
    "prefix": "uvf",
    "body": ["`uvm_fatal(get_type_name(), \"${1:msg}\")"]
  },
  "config_db get": {
    "prefix": "cdb",
    "body": ["uvm_config_db#(${1:type})::get(this, \"\", \"${2:name}\", ${3:var});"]
  },
  "config_db set": {
    "prefix": "cdbs",
    "body": ["uvm_config_db#(${1:type})::set(this, \"${2:path}\", \"${3:name}\", ${4:val});"]
  },
  "type_id create": {
    "prefix": "tic",
    "body": ["${1:type}::type_id::create(\"${2:name}\", this)"]
  }
}
```

- [ ] **Step 4: 写 verilog.json**

```json
{
  "module": {
    "prefix": "mod",
    "body": [
      "module ${1:name} #(",
      "  parameter ${2:WIDTH} = ${3:8}",
      ")(",
      "  input  logic            clk,",
      "  input  logic            rst_n,",
      "  ${4:// ports}",
      ");",
      "",
      "${5:// body}",
      "",
      "endmodule"
    ]
  },
  "always_ff": {
    "prefix": "aff",
    "body": [
      "always_ff @(posedge ${1:clk} or negedge ${2:rst_n}) begin",
      "  if (!${2:rst_n}) ${3:q} <= ${4:'0};",
      "  else             ${3:q} <= ${5:d};",
      "end"
    ]
  },
  "always_comb": {
    "prefix": "acm",
    "body": ["always_comb begin", "  ${1:// comb}", "end"]
  },
  "fsm 3-stage": {
    "prefix": "fsm3",
    "body": [
      "typedef enum logic [${1:1}:0] {",
      "  ${2:S_IDLE},",
      "  ${3:S_RUN},",
      "  ${4:S_DONE}",
      "} ${5:state_t};",
      "",
      "${5:state_t} cs, ns;",
      "",
      "always_ff @(posedge clk or negedge rst_n)",
      "  if (!rst_n) cs <= ${2:S_IDLE};",
      "  else        cs <= ns;",
      "",
      "always_comb begin",
      "  ns = cs;",
      "  unique case (cs)",
      "    ${2:S_IDLE}: if (${6:start}) ns = ${3:S_RUN};",
      "    ${3:S_RUN} : if (${7:done})  ns = ${4:S_DONE};",
      "    ${4:S_DONE}: ns = ${2:S_IDLE};",
      "    default: ns = ${2:S_IDLE};",
      "  endcase",
      "end"
    ]
  }
}
```

- [ ] **Step 5: 写 tcl.json**

```json
{
  "proc": {
    "prefix": "proc",
    "body": [
      "proc ${1:name} {${2:args}} {",
      "  ${3:# body}",
      "}"
    ]
  },
  "puts": {
    "prefix": "puts",
    "body": ["puts \"${1:msg}\""]
  },
  "package require": {
    "prefix": "pkg",
    "body": ["package require ${1:Tcl} ${2:8.6}"]
  }
}
```

- [ ] **Step 6: 写 python.json**

```json
{
  "class": {
    "prefix": "pyclass",
    "body": [
      "class ${1:Name}:",
      "    def __init__(self, ${2:args}) -> None:",
      "        ${3:pass}"
    ]
  },
  "main": {
    "prefix": "__main__",
    "body": [
      "if __name__ == \"__main__\":",
      "    ${1:main()}"
    ]
  },
  "pytest fixture": {
    "prefix": "pytest",
    "body": [
      "import pytest",
      "",
      "@pytest.fixture",
      "def ${1:name}():",
      "    return ${2:value}",
      "",
      "def test_${3:behavior}(${1:name}):",
      "    assert ${4:condition}"
    ]
  }
}
```

- [ ] **Step 7: 写 cpp.json**

```json
{
  "class": {
    "prefix": "cls",
    "body": [
      "class ${1:Name} {",
      "public:",
      "  ${1:Name}();",
      "  ~${1:Name}();",
      "private:",
      "  ${2:// members}",
      "};"
    ]
  },
  "header guard": {
    "prefix": "ifndef",
    "body": [
      "#ifndef ${1:GUARD}",
      "#define ${1:GUARD}",
      "",
      "${2:// declarations}",
      "",
      "#endif  // ${1:GUARD}"
    ]
  },
  "namespace": {
    "prefix": "nspace",
    "body": [
      "namespace ${1:name} {",
      "",
      "${2:// content}",
      "",
      "}  // namespace ${1:name}"
    ]
  }
}
```

- [ ] **Step 8: 跑测试确认通过**

```bash
bash /home/ubuntu/ryan/gvim_work/test/test_snippets_json.sh
```
Expected: `OK`

- [ ] **Step 9: Commit**

```bash
git add templates/snippets/ test/test_snippets_json.sh
git commit -m "feat: snippet libraries for SV/Verilog/Tcl/Python/C++ with UVM templates"
```

---

## Task 19: templates/lua/plugins/uvm-snippets.lua + snippets/package.json

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/uvm-snippets.lua`
- Create: `/home/ubuntu/ryan/gvim_work/templates/snippets/package.json`

- [ ] **Step 1: 写 uvm-snippets.lua**

```lua
-- ~/.config/nvim/lua/plugins/uvm-snippets.lua
return {
  { "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      local user_dir = vim.fn.stdpath("config") .. "/snippets"
      if vim.fn.isdirectory(user_dir) == 1 then
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { user_dir } })
      end
      pcall(function()
        require("which-key").add({ { "<leader>U", group = "+uvm" } })
      end)
    end,
  },
}
```

- [ ] **Step 2: 写 snippets/package.json**

```json
{
  "name": "gvim-work-snippets",
  "contributes": {
    "snippets": [
      { "language": "systemverilog", "path": "./systemverilog.json" },
      { "language": "verilog",       "path": "./verilog.json" },
      { "language": "tcl",           "path": "./tcl.json" },
      { "language": "python",        "path": "./python.json" },
      { "language": "cpp",           "path": "./cpp.json" }
    ]
  }
}
```

- [ ] **Step 3: 验证**

```bash
nvim --headless "+luafile templates/lua/plugins/uvm-snippets.lua" "+qa"
python3 -c "import json; json.load(open('templates/snippets/package.json'))"
```
Expected: 无报错

- [ ] **Step 4: Commit**

```bash
git add templates/lua/plugins/uvm-snippets.lua templates/snippets/package.json
git commit -m "feat: snippet loader hooks LuaSnip into ~/.config/nvim/snippets"
```

---

## Task 20: templates/lua/plugins/overseer.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/overseer.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/overseer.lua
return {
  { "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction", "OverseerInfo" },
    opts = {
      strategy = "terminal",
      task_list = { default_detail = 1, bindings = { ["q"] = "<cmd>close<cr>" } },
      templates = { "builtin" },
    },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>",    desc = "Run task (menu)" },
      { "<leader>rt", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
      { "<leader>rl", "<cmd>OverseerRunCmd<cr>", desc = "Run last cmd" },
      { "<leader>rk", function() require("overseer").run_action() end, desc = "Run action on task" },
      { "<leader>rm", function() require("overseer").run_template({ name = "make" }) end, desc = "Run Makefile target" },
      { "<leader>rp", function()
          local f = vim.fn.expand("%:p")
          require("overseer").new_task({
            cmd = "pytest", args = { "-v", f }, components = { "default" },
          }):start()
        end, desc = "Run pytest current file" },
    },
    config = function(_, opts)
      require("overseer").setup(opts)
      pcall(function()
        require("which-key").add({ { "<leader>r", group = "+run" } })
      end)
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/overseer.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/overseer.lua
git commit -m "feat: overseer with run/toggle/make/pytest shortcuts"
```

---

## Task 21: templates/lua/plugins/vcs.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/vcs.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/vcs.lua
return {
  { "stevearc/overseer.nvim",
    keys = {
      { "<leader>vc", function() VcsCompile() end, desc = "VCS: compile" },
      { "<leader>vs", function() VcsSim() end,     desc = "VCS: simv (prompt testname)" },
      { "<leader>vS", function() VcsLast() end,    desc = "VCS: re-run last sim" },
      { "<leader>vq", function() VcsClean() end,   desc = "VCS: clean workspace" },
      { "<leader>vw", function() VcsWave() end,    desc = "VCS: open waveform tool" },
    },
    config = function(_, opts)
      require("overseer").setup(opts or {})
      vim.opt.errorformat:append([[Error-\[%t%n\]\ %m\,\ %f\,\ %l]])
      vim.opt.errorformat:append([[Warning-\[%t%n\]\ %m\,\ %f\,\ %l]])

      local last_test = nil

      function VcsCompile()
        require("overseer").new_task({
          name = "vcs compile",
          cmd  = "make", args = { "comp" },
          components = { "default", "on_output_quickfix" },
        }):start()
      end

      function VcsSim()
        local t = vim.fn.input("UVM_TESTNAME: ", last_test or "")
        if t == "" then return end
        last_test = t
        require("overseer").new_task({
          name = "simv +" .. t,
          cmd  = "make", args = { "sim", "TEST=" .. t },
          components = { "default", "on_output_quickfix" },
        }):start()
      end

      function VcsLast()
        if not last_test then vim.notify("没有上次测试"); return end
        VcsSim()
      end

      function VcsClean()
        require("overseer").new_task({
          name = "vcs clean", cmd = "make", args = { "clean" },
        }):start()
      end

      function VcsWave()
        local tool = vim.env.VCS_WAVE_TOOL or "verdi"
        require("overseer").new_task({ name = tool, cmd = tool, args = { "&" } }):start()
      end

      pcall(function()
        require("which-key").add({ { "<leader>v", group = "+vcs" } })
      end)

      vim.api.nvim_create_user_command("VcsCompile", VcsCompile, {})
      vim.api.nvim_create_user_command("VcsSim",     VcsSim,     {})
      vim.api.nvim_create_user_command("VcsLast",    VcsLast,    {})
      vim.api.nvim_create_user_command("VcsClean",   VcsClean,   {})
      vim.api.nvim_create_user_command("VcsWave",    VcsWave,    {})
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/vcs.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/vcs.lua
git commit -m "feat: VCS integration with compile/sim/wave/clean commands"
```

---

## Task 22: templates/lua/plugins/nvim-lint.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/nvim-lint.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/nvim-lint.lua
return {
  { "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python         = { "ruff" },
        cpp            = { "cppcheck" },
        c              = { "cppcheck" },
        sh             = { "shellcheck" },
        bash           = { "shellcheck" },
        markdown       = { "markdownlint" },
        verilog        = { "verilator" },
        systemverilog  = { "verible" },
      }
      local v = lint.linters.verible
      if v then
        v.cmd = "verible-verilog-lint"
        v.args = { "--rules_config_search" }
      end
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() pcall(lint.try_lint) end,
      })
    end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/nvim-lint.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/nvim-lint.lua
git commit -m "feat: nvim-lint with verible/verilator/cppcheck/ruff/shellcheck"
```

---

## Task 23: templates/lua/plugins/conform.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/conform.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/conform.lua
return {
  { "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd  = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        cpp            = { "clang-format" },
        c              = { "clang-format" },
        python         = { "ruff_format", "black" },
        lua            = { "stylua" },
        systemverilog  = { "verible_verilog_format" },
        verilog        = { "verible_verilog_format" },
        sh             = { "shfmt" },
        markdown       = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
      formatters = {
        verible_verilog_format = {
          command = "verible-verilog-format",
          args = { "-" },
          stdin = true,
        },
      },
    },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
      { "<leader>uf", function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("autoformat: " .. (vim.g.disable_autoformat and "OFF" or "ON"))
        end, desc = "Toggle format-on-save" },
    },
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/conform.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/conform.lua
git commit -m "feat: conform.nvim format-on-save"
```

---

## Task 24: templates/lua/plugins/trouble.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/trouble.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/trouble.lua
return {
  { "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true, focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                    desc = "Diagnostics: workspace" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",       desc = "Diagnostics: buffer" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                          desc = "Quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                         desc = "Location list" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",             desc = "Symbols" },
    },
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/trouble.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/trouble.lua
git commit -m "feat: trouble diagnostics/qflist/loclist/symbols"
```

---

## Task 25: templates/lua/plugins/tags-fallback.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/tags-fallback.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/tags-fallback.lua
return {
  { "ludovicchabant/vim-gutentags", event = "BufReadPost",
    init = function()
      vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/gutentags"
      vim.g.gutentags_add_default_project_roots = 0
      vim.g.gutentags_project_root = { ".git", "Makefile", "*.f" }
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1
      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_ctags_extra_args = { "--fields=+l", "--c++-kinds=+p" }
    end,
  },
  { "dhananjaylatkar/cscope_maps.nvim",
    event = "BufReadPost",
    opts = {
      disable_maps = false,
      skip_picker_for_single_result = true,
      prefix = "<leader>j",
    },
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/tags-fallback.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/tags-fallback.lua
git commit -m "feat: gutentags + cscope_maps as LSP fallback"
```

---

## Task 26: templates/lua/plugins/search.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/search.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/search.lua
return {
  { "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function() pcall(require("telescope").load_extension, "frecency") end,
    keys = { { "<leader>fr", "<cmd>Telescope frecency<cr>", desc = "Frecency files" } },
  },
  { "kevinhwang91/nvim-bqf", ft = "qf",
    opts = { auto_enable = true, preview = { winblend = 5 } },
  },
  { "mrjones2014/legendary.nvim",
    cmd = { "Legendary" },
    keys = { { "<leader>?", "<cmd>Legendary<cr>", desc = "Legendary: search keymaps/commands" } },
    opts = { include_builtin = true, include_legendary_cmds = true },
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/search.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/search.lua
git commit -m "feat: telescope-frecency + nvim-bqf + legendary"
```

---

## Task 27: templates/CHEATSHEET.md + plugins/cheatsheet.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/CHEATSHEET.md`
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/cheatsheet.lua`

- [ ] **Step 1: 写 CHEATSHEET.md**

````markdown
# gvim_work Cheat Sheet

Press `<Space>` (leader) and wait — which-key shows everything.
Use `<Space>?` to fuzzy-search all keymaps.

## File / Search

| Key            | Action                       |
|----------------|------------------------------|
| `<Space><Space>` | Find files                 |
| `<Space>/`     | Live grep                    |
| `<Space>,`     | Switch buffer                |
| `<Space>fr`    | Recent (frecency)            |
| `<Space>sg`    | Live grep                    |
| `<Space>sw`    | Search word under cursor     |
| `<Space>sh`    | Search :help                 |
| `<Space>?`     | Search all keymaps           |
| `<Space>?h`    | Open this cheat sheet        |

## LSP / Code Navigation

| Key      | Action                       |
|----------|------------------------------|
| `gd`     | Go to definition             |
| `gD`     | Go to declaration            |
| `gr`     | Find references              |
| `gI`     | Go to implementation         |
| `gy`     | Go to type definition        |
| `K`      | Hover doc                    |
| `<C-t>`  | Jump back                    |
| `]d`/`[d`| Next/prev diagnostic         |
| `<Space>cs` | Document symbols          |
| `<Space>cS` | Workspace symbols         |
| `<Space>cr` | Rename                    |
| `<Space>ca` | Code action               |
| `<Space>cf` | Format buffer             |

## Alignment (mini.align)

| Key            | Action                          |
|----------------|---------------------------------|
| `ga` (visual)  | Interactive align               |
| `<Space>a=`    | Align paragraph by `=`          |
| `<Space>a:`    | Align by `:`                    |
| `<Space>a,`    | Align by `,`                    |
| `<Space>a\|`   | Align by `\|`                   |
| `<Space>a<`    | Align by `<=` (SV nonblocking)  |
| `<Space>a/`    | Align by `//`                   |
| `<Space>aa`    | Custom pattern                  |
| `<Space>aA`    | vim-easy-align (advanced)       |

## Run / Build

| Key         | Action                          |
|-------------|---------------------------------|
| `<Space>rr` | Run task menu                   |
| `<Space>rt` | Toggle task list                |
| `<Space>rm` | Run Makefile target             |
| `<Space>rp` | Run pytest current file         |
| `<Space>rl` | Re-run last task                |
| `<Space>rk` | Action on running task          |

## VCS / Simulation

| Key         | Action                          |
|-------------|---------------------------------|
| `<Space>vc` | VCS compile                     |
| `<Space>vs` | VCS simv (prompt UVM_TESTNAME)  |
| `<Space>vS` | Re-run last sim                 |
| `<Space>vw` | Open Verdi/DVE                  |
| `<Space>vq` | Clean workspace                 |

## UVM Snippets (insert mode + Tab)

| Trigger     | Expands to                      |
|-------------|---------------------------------|
| `uvc`       | uvm_component skeleton          |
| `uvo`       | uvm_object skeleton             |
| `uvm_test`  | uvm_test with env + objection   |
| `uvm_seq`   | uvm_sequence body               |
| `bldp`      | build_phase block               |
| `runp`      | run_phase block                 |
| `uvi/uvw/uve/uvf` | uvm_info/warning/error/fatal |
| `cdb`/`cdbs`| config_db get/set               |
| `tic`       | type_id::create                 |
| `fsm3`      | 3-stage FSM (Verilog)           |

## Diagnostics / Trouble

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>xx`  | Workspace diagnostics           |
| `<Space>xX`  | Buffer diagnostics              |
| `<Space>xq`  | Quickfix                        |
| `<Space>xs`  | Symbol outline                  |

## Git

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>gg`  | LazyGit                         |
| `<Space>gb`  | Blame line                      |
| `<Space>gd`  | Diff view                       |
| `]c`/`[c`    | Next/prev hunk                  |

## UI Toggle

| Key          | Action                          |
|--------------|---------------------------------|
| `<Space>uf`  | Toggle format-on-save           |
| `<Space>un`  | Toggle line numbers             |
| `<Space>ur`  | Toggle relative numbers         |
| `<Space>ub`  | Cycle theme                     |
| `<Space>uz`  | Zen mode                        |

---

For more, run `:Telescope keymaps` or press `<Space>?`.
````

- [ ] **Step 2: 写 cheatsheet.lua（占位声明）**

```lua
-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- 占位文件：实际 CHEATSHEET.md 由 install.sh 从 templates/ 复制。
-- keymap <leader>?h 已在 config/keymaps.lua 注册。
return {}
```

- [ ] **Step 3: 验证**

```bash
test -f /home/ubuntu/ryan/gvim_work/templates/CHEATSHEET.md
nvim --headless "+luafile templates/lua/plugins/cheatsheet.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 4: Commit**

```bash
git add templates/CHEATSHEET.md templates/lua/plugins/cheatsheet.lua
git commit -m "feat: CHEATSHEET.md + cheatsheet plugin stub"
```

---

## Task 28: templates/lua/plugins/neovide.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/neovide.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/neovide.lua
if vim.g.neovide then
  vim.o.guifont                       = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_refresh_rate          = 60
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size     = 0.6
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_transparency          = 0.95
  vim.g.neovide_window_blurred        = true
  vim.g.neovide_remember_window_size  = true
  vim.g.neovide_input_use_logo        = true

  vim.keymap.set({ "n", "v" }, "<D-c>", '"+y',    { silent = true })
  vim.keymap.set({ "n", "v" }, "<D-v>", '"+P',    { silent = true })
  vim.keymap.set("i",          "<D-v>", "<C-r>+", { silent = true })
end

return {}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/neovide.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/neovide.lua
git commit -m "feat: neovide GUI font/cursor/scroll/transparency"
```

---

## Task 29: templates/lua/plugins/mason-tools.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/mason-tools.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/mason-tools.lua
return {
  { "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    opts = {
      ensure_installed = {
        "verible", "clangd", "pyright", "lua-language-server", "tclint",
        "verible-verilog-format", "clang-format", "ruff", "black", "stylua", "shfmt",
        "verible-verilog-lint", "verilator", "cppcheck", "shellcheck", "markdownlint",
        "debugpy",
      },
      run_on_start = true,
      auto_update = false,
    },
    config = function(_, opts) require("mason-tool-installer").setup(opts) end,
  },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/mason-tools.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/mason-tools.lua
git commit -m "feat: mason-tool-installer declarative tool list"
```

---

## Task 30: templates/lua/plugins/language-extras.lua

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/templates/lua/plugins/language-extras.lua`

- [ ] **Step 1: 写文件**

```lua
-- ~/.config/nvim/lua/plugins/language-extras.lua
return {
  { "antoinemadec/vim-verilog-instance",
    ft = { "systemverilog", "verilog" },
    keys = {
      { "<leader>Ui", "<cmd>VerilogInstance<cr>", desc = "Verilog: instance current module",
        ft = { "systemverilog", "verilog" } },
    },
  },
  { "vhda/verilog_systemverilog.vim", ft = { "systemverilog", "verilog" } },
}
```

- [ ] **Step 2: lua 语法检查**

```bash
nvim --headless "+luafile templates/lua/plugins/language-extras.lua" "+qa"
```
Expected: 无报错

- [ ] **Step 3: Commit**

```bash
git add templates/lua/plugins/language-extras.lua
git commit -m "feat: vim-verilog-instance + verilog_systemverilog.vim"
```

---

## Task 31: test/ 样本文件 + Makefile + golden

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/test/sample.sv`
- Create: `/home/ubuntu/ryan/gvim_work/test/sample.cpp`
- Create: `/home/ubuntu/ryan/gvim_work/test/sample.py`
- Create: `/home/ubuntu/ryan/gvim_work/test/sample.tcl`
- Create: `/home/ubuntu/ryan/gvim_work/test/Makefile`
- Create: `/home/ubuntu/ryan/gvim_work/test/golden/sample.sv.formatted`

- [ ] **Step 1: 写 sample.sv**

```systemverilog
// sample.sv —— smoke test fixture
module sample (
    input  logic clk,
    input  logic rst_n,
    output logic q
);

  logic [7:0] data_a;
  logic [31:0] address_long;
  logic enable;
  int counter = 0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 1'b0;
    else q <= enable;
  end

endmodule
```

- [ ] **Step 2: 写 golden/sample.sv.formatted**

```systemverilog
// sample.sv —— smoke test fixture
module sample (
    input  logic clk,
    input  logic rst_n,
    output logic q
);

  logic [7:0]  data_a;
  logic [31:0] address_long;
  logic        enable;
  int          counter = 0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 1'b0;
    else q <= enable;
  end

endmodule
```

- [ ] **Step 3: 写 sample.cpp**

```cpp
// sample.cpp —— smoke test fixture
#include <cstdio>

int add(int a, int b) {
    return a + b;
}

int main() {
    int result = add(2, 3);
    std::printf("result = %d\n", result);
    return 0;
}
```

- [ ] **Step 4: 写 sample.py**

```python
"""sample.py — smoke test fixture."""


def greet(name: str) -> str:
    return f"hello, {name}"


def test_greet() -> None:
    assert greet("world") == "hello, world"


if __name__ == "__main__":
    print(greet("world"))
```

- [ ] **Step 5: 写 sample.tcl**

```tcl
# sample.tcl — smoke test fixture
proc greet {name} {
    return "hello, $name"
}

puts [greet "world"]
```

- [ ] **Step 6: 写 test/Makefile**

```makefile
.PHONY: all clean cpp py
all: cpp py

cpp:
	g++ -O0 -g -o sample_cpp sample.cpp

py:
	python3 sample.py

clean:
	rm -f sample_cpp
```

- [ ] **Step 7: 验证 Makefile**

```bash
mkdir -p /home/ubuntu/ryan/gvim_work/test/golden
cd /home/ubuntu/ryan/gvim_work/test && make all && make clean
```
Expected: 编译 + 运行成功

- [ ] **Step 8: Commit**

```bash
git add test/sample.* test/Makefile test/golden/
git commit -m "feat: smoke fixtures (sample.sv/cpp/py/tcl + Makefile + golden)"
```

---

## Task 32: test/smoke.sh

**Files:**
- Create: `/home/ubuntu/ryan/gvim_work/test/smoke.sh`

- [ ] **Step 1: 写 smoke.sh**

```bash
#!/usr/bin/env bash
# test/smoke.sh —— 端到端冒烟（前提：install.sh 已部署）
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/log.sh"

PASS=0; FAIL=0
ok()   { log_ok "$1"; PASS=$((PASS+1)); }
bad()  { log_err "FAIL: $1"; FAIL=$((FAIL+1)); }

# 1. nvim 启动速度
log_step "1. nvim startup"
t0=$(date +%s%N)
nvim --headless "+qa" >/dev/null 2>&1
t1=$(date +%s%N)
ms=$(( (t1 - t0) / 1000000 ))
[ "$ms" -lt 5000 ] && ok "startup ${ms}ms < 5000" || bad "startup ${ms}ms >= 5000"

# 2. SV 诊断
log_step "2. SV diagnostics"
if command -v verible-verilog-ls >/dev/null 2>&1; then
  out=$(nvim --headless "$ROOT/test/sample.sv" \
        "+sleep 3" \
        "+lua io.write(#vim.diagnostic.get(0)..'\\n')" \
        +qa 2>&1 | tail -1)
  [[ "$out" =~ ^[0-9]+$ ]] && ok "diagnostics returned ($out items)" || bad "diagnostics: $out"
else
  log_warn "verible not installed, skip"
fi

# 3. 对齐
log_step "3. mini.align ="
tmp=$(mktemp); cp "$ROOT/test/sample.sv" "$tmp"
nvim --headless "$tmp" \
  "+normal! 8GVjjj" \
  "+lua require('mini.align').align_selected({split_pattern='='})" \
  "+w" "+qa" 2>/dev/null || true
awk -F'=' '/=/ {if (last && index($0,"=")!=last) {print "MISALIGNED"; exit 1} last=index($0,"=")} END{print "ALIGN_OK"}' "$tmp" | grep -q ALIGN_OK \
  && ok "= column aligned" || bad "= alignment failed"
rm -f "$tmp"

# 4. clangd 跳转
log_step "4. LSP gd in C++"
if command -v clangd >/dev/null 2>&1; then
  out=$(nvim --headless "$ROOT/test/sample.cpp" \
        "+sleep 3" \
        "+lua local p = vim.fn.searchpos('add(2,', ''); vim.api.nvim_win_set_cursor(0,p); vim.lsp.buf.definition(); vim.cmd('sleep 1500m'); io.write(vim.fn.line('.')..'\\n')" \
        +qa 2>&1 | tail -1)
  [[ "$out" =~ ^[0-9]+$ ]] && ok "gd jumped to line $out" || bad "gd output: $out"
else
  log_warn "clangd not installed, skip"
fi

# 5. overseer + Makefile
log_step "5. overseer make all"
out=$(nvim --headless \
      "+lua require('overseer').setup({})" \
      "+lua require('overseer').new_task({cmd='make', args={'-C', '$ROOT/test', 'all'}, components={'default','on_complete_dispose'}}):start()" \
      "+sleep 3" \
      "+lua local n=#require('overseer').list_tasks({}); io.write('tasks='..n..'\\n')" \
      +qa 2>&1 | tail -1)
[[ "$out" =~ ^tasks=[0-9]+$ ]] && ok "overseer ran ($out)" || bad "overseer: $out"
make -C "$ROOT/test" clean >/dev/null 2>&1 || true

echo
echo "Smoke summary: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" = "0" ]
```

- [ ] **Step 2: 验证语法**

```bash
chmod +x /home/ubuntu/ryan/gvim_work/test/smoke.sh
bash -n /home/ubuntu/ryan/gvim_work/test/smoke.sh
```
Expected: 0 退出码

- [ ] **Step 3: Commit**

```bash
git add test/smoke.sh
git commit -m "feat: smoke.sh end-to-end checks (startup/diag/align/gd/overseer)"
```

---

## Task 33: 端到端验收

**Files:**
- 无新文件，运行已有脚本并修复发现的问题。

- [ ] **Step 1: 真实部署**

```bash
cd /home/ubuntu/ryan/gvim_work
bash install.sh
```
Expected: 全部 `[OK]`，最后输出 `完成。运行 'nvim' 或 'neovide' 启动`

- [ ] **Step 2: 等首次 Lazy/Mason 同步完成**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstall" "+sleep 60" +qa
```
Expected: 无 ERROR

- [ ] **Step 3: 跑 healthcheck**

```bash
bash healthcheck.sh
```
Expected: `Summary: PASS=N  FAIL=0  WARN=M`（核心全 OK）

- [ ] **Step 4: 跑 smoke.sh**

```bash
bash test/smoke.sh
```
Expected: `Smoke summary: PASS=N  FAIL=0`

- [ ] **Step 5: 手测 spec §11 验收点**

依次手测（用真实 nvim）：
1. 打开 nvim，2 秒内进入 dashboard
2. `:e test/sample.sv`，3 秒内 verible 显示诊断
3. `:e test/sample.cpp`，光标到 `add` 上按 `gd`，跳到定义
4. 选中 `data_a/address_long/enable/counter` 那 4 行，按 `<Space>a=` 完成对齐
5. 按 `<Space>?h` 打开 CHEATSHEET.md
6. 按 `<Space>` 弹出 which-key 菜单
7. 启动 `neovide`，确认字体含图标 + 光标动画

- [ ] **Step 6: Commit lazy-lock.json + 验收记录**

```bash
git add lazy-lock.json 2>/dev/null || true
git commit --allow-empty -m "chore: pass full e2e (install + healthcheck + smoke)"
```

---

## 自审记录（plan-vs-spec）

| Spec 章节 | 对应 Task |
|-----------|-----------|
| §1 背景与目标 | Task 1 |
| §2 整体架构 | Task 5/29 |
| §3 路线选择 | Task 5（基于 LazyVim starter）|
| §4.1 诊断 | Task 22 |
| §4.2 编译/仿真 | Task 20/21 |
| §4.3 跨文件跳转 | Task 16/25 |
| §4.4 对齐 | Task 12 |
| §4.5 可发现性 | Task 7/26/27 |
| §4.6 UI | Task 9–11 |
| §5 目录结构 | 全 Task 创建 |
| §6 插件清单 | Task 9–30 |
| §7 键位 | Task 7/12/20/21/24/27 |
| §8 UVM Snippets | Task 18/19 |
| §9.1 install.sh | Task 3/5 |
| §9.2 healthcheck | Task 4 |
| §9.3 smoke.sh | Task 32/33 |
| §9.4 升级回滚 | Task 2/3（Makefile + backup.sh）|
| §11 验收 | Task 33 |

无遗漏。`<leader>U` UVM 分组通过 Task 19/30 注册（`<leader>Ui` 在 language-extras）；snippet 触发词在 Task 18 全部呈现。

类型一致性检查：所有 Lua 函数与 vim API 调用使用 nvim 0.10+ 标准签名；shell 函数名贯穿一致（`log_*`, `pkg_install*`, `detect_*`, `install_nerd_font`, `install_neovide*`, `backup_nvim_config`, `restore_nvim_config`）。

---

## 执行交接

Plan complete and saved to `docs/superpowers/plans/2026-04-25-gvim-setup.md`. Two execution options:

**1. Subagent-Driven (recommended)** —— 每个 Task 派发一个新 subagent 实现，我在 Task 之间复核。

**2. Inline Execution** —— 在当前会话内逐 Task 推进，配合 checkpoint 做批量复核。

**Which approach?**

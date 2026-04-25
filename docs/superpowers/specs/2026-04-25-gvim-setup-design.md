# gvim_work 设计规格：Neovim + LazyVim 多语言开发环境

**日期**：2026-04-25
**作者**：seam3721@gmail.com（与 Claude Code 协同）
**项目**：`/home/ubuntu/ryan/gvim_work/`
**状态**：草案（待用户复核）

---

## 1. 背景与目标

### 1.1 用户场景
- 本地 Linux 桌面 + 远程 SSH 服务器混合工作
- 编程语言：C / C++ / Python / Tcl / SystemVerilog / UVM / Verilog
- 写代码 + 写文档 / 笔记，希望一份配置覆盖
- 偏好"功能强大但不需要深度折腾"

### 1.2 设计目标
1. **代码功能优先**：补全、跳转、对齐、语法检查、快速编译
2. **UI 现代柔和**：暖色主题 + 全套装饰插件，长时间盯不累
3. **可发现性好**：不背键位也能用——按 `<leader>` 就能逛功能
4. **多语言一致体验**：每种语言都有 LSP / 格式化 / 诊断 / Snippet
5. **本地 GUI + 远程终端共用一份配置**
6. **跨机器可复制**：一键安装脚本 + 版本锁定 + 健康检查

### 1.3 非目标
- 不追求"最小化配置 / 极客炫技"
- 不在 vim 里跑 IDE 级图形化调试器（DAP 仅作可选）
- 不考虑 Windows 原生（WSL OK）

---

## 2. 整体架构

```
┌──────────────────────────────────────────────────────────┐
│                      Neovide (GUI)                       │
│   光标动画 / 平滑滚动 / Ligature / 真窗口（gvim 替身）   │
└────────────────────────────┬─────────────────────────────┘
                             │ RPC
┌────────────────────────────▼─────────────────────────────┐
│                  Neovim 0.10+（核心）                    │
│                                                          │
│   ┌─ LazyVim 发行版 ─────────────────────────────────┐   │
│   │  Lazy.nvim │ which-key │ Telescope │ nvim-cmp     │   │
│   │  Treesitter│ neo-tree  │ lualine   │ bufferline   │   │
│   │  alpha     │ noice     │ trouble   │ gitsigns     │   │
│   └─────────────────────────────────┬───────────────────┘ │
│                                     │                     │
│   ┌─ 用户层 lua/plugins/ ───────────▼─────────────────┐  │
│   │  theme / ui-extras / align / motion              │  │
│   │  lang-cpp / lang-python / lang-sv / lang-tcl     │  │
│   │  uvm-snippets / vcs / overseer / nvim-lint       │  │
│   │  conform / trouble / cheatsheet / neovide        │  │
│   └──────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │  外部工具（PATH 必备）  │
                │  verible-verilog-ls     │
                │  verible-verilog-format │
                │  clangd / clang-format  │
                │  pyright / ruff / black │
                │  vcs / vlogan / simv    │
                └─────────────────────────┘
```

### 核心原则
- **三层分离**：LazyVim 不动 / 用户配置只加新东西 / 外部工具走 mason 自动装
- **每语言一文件**：`lua/plugins/lang-*.lua`，互不干扰
- **GUI 与终端共用**：本地 Neovide GUI，远程 SSH 直接 nvim 也能跑
- **可发现性内建**：`<leader>` 菜单 + 全键位搜索 + 速查表 + `:help`

---

## 3. 实施路线选择

| 路线 | 描述 | 选用 |
|------|------|------|
| ① 纯 LazyVim + extras | 克隆 starter，启用官方 extras，仅自定义 SV/Tcl/UVM | ✅ **采用** |
| ② Fork LazyVim 深度改造 | 完全可控，失去自动升级 | ❌ |
| ③ 抄 LazyVim 关键插件、自己手写骨架 | 学习深度最高，时间成本最高 | ❌ |

理由：用户需求是"功能强、不折腾"。LazyVim 已配好 80% 通用部分，自定义只需要专注硬件验证 / 多语言专属配置。

---

## 4. 功能模块详细设计

### 4.1 实时语法检查（Diagnostics）

#### LSP 诊断（主力）
| 语言 | LSP | 检查内容 |
|------|-----|---------|
| C/C++ | clangd | 编译错误、未定义符号、include 路径 |
| Python | pyright | 类型错误、未导入、未定义变量 |
| SystemVerilog/Verilog/UVM | verible-verilog-ls | 语法、命名规范、风格 |
| Tcl | tclint-ls | 语法、未定义变量 |

显示形式：左侧 sign（✘/⚠/ⓘ）+ 下划波浪线 + hover 弹窗 + Trouble 面板。

#### 静态检查器（Linter，nvim-lint 调度）
| 语言 | Linter | 时机 |
|------|--------|------|
| Python | ruff（首选）/ flake8 | 输入停顿 + 保存 |
| C/C++ | cppcheck | 保存 |
| SystemVerilog | verible-verilog-lint | 保存 |
| Verilog | verilator --lint-only | 保存 |
| Tcl | nagelfar | 保存 |
| Shell | shellcheck | 输入停顿 |
| Markdown | markdownlint | 保存 |

#### 格式化（conform.nvim 调度，保存时自动）
| 语言 | Formatter |
|------|-----------|
| C/C++ | clang-format |
| Python | ruff format / black |
| SystemVerilog | verible-verilog-format |
| Tcl | tclfmt |
| Lua | stylua |

`<leader>uf` 切换"保存时自动格式化"开关。

### 4.2 快速编译 / 仿真（Build & Run）

#### overseer.nvim 任务运行器
统一入口 `<leader>r`，子菜单：
- `c` 跑当前文件（按文件类型自动选）
- `m` 跑 Makefile target（自动列出）
- `v` VCS quick compile
- `s` VCS simv + 波形
- `u` UVM testcase（带 UVM_TESTNAME 提示）
- `p` pytest 当前文件
- `l` 重跑上一次任务
- `k` 杀掉运行中任务

#### VCS 集成（自定义 `lua/plugins/vcs.lua`）
命令：
- `:VcsCompile` — 调 vlogan + vcs，errorformat 已配好
- `:VcsSim {test}` — 跑 simv +UVM_TESTNAME={test}
- `:VcsClean` — 清理 csrc/simv*/DVEfiles/work/.vcs_*
- `:VcsWave` — verdi 或 dve（环境变量 `$VCS_WAVE_TOOL` 切换，默认 verdi）
- `:VcsLast` — 重跑上次仿真（带 UVM_VERBOSITY=UVM_HIGH）

errorformat 处理 VCS 多行错误格式，确保 `:cn`/`:cp` 直接跳转到 `file.sv:line`。

#### C/C++ 编译
- 使用 `compile_commands.json`（`bear -- make` 或 cmake `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` 生成）
- gcc/clang errorformat 内置，编译错误自动进 quickfix

#### Python
- `<leader>rc` 跑当前文件
- `<leader>rt` 跑 pytest 当前文件
- `<leader>rd` debugpy + nvim-dap（可选）

### 4.3 跨文件代码跳转 / 引用查找

#### 层 1：LSP 跳转（最准）
| 键位 | 功能 |
|------|------|
| `gd` | 跳到定义 |
| `gD` | 跳到声明 |
| `gr` | 找所有引用 |
| `gI` | 跳到实现（虚函数 / pure virtual） |
| `gy` | 跳到类型定义 |
| `K` | hover 文档 |
| `<C-t>` | 跳回 |
| `]d` / `[d` | 下/上一个诊断 |
| `<leader>cs` | 当前文件符号大纲 |
| `<leader>cS` | 工作区符号搜索 |
| `<leader>cr` | 智能重命名 |

**SV 跨文件跳转关键配置**：`lang-sv.lua` 进入 SV 文件时自动找项目根的 `*.f` 文件作为 verible filelist；没有则 `find . -name "*.sv" -o -name "*.svh"` 实时生成；UVM 库目录（`$UVM_HOME/src`）也加入。

#### 层 2：ctags / cscope（兜底）
- `vim-gutentags` 后台自动生成 tags
- `cscope_maps.nvim` 提供 C/C++ caller/callee 查询
- LSP 无结果时 `gd` 自动 fallback 到 `<C-]>`

#### 层 3：Telescope + ripgrep（文本级）
| 键位 | 功能 |
|------|------|
| `<leader>sg` | Live Grep |
| `<leader>sw` | 搜光标下的词 |
| `<leader>sf` | Find Files |
| `<leader>sb` | 当前 buffer 内搜索 |

#### 跳转历史可视化
- `telescope-frecency` 按频次排序最近文件
- `nvim-bqf` 美化 quickfix（预览 + 模糊过滤）

### 4.4 代码对齐（用户核心需求）

主插件：`echasnovski/mini.align`
备用插件：`junegunn/vim-easy-align`

支持任意分隔符：`=`、`:`、`,`、`|`、`//`、`<=`（SV 非阻塞赋值）、`=>`、空格等。

#### 键位
| 键位 | 功能 |
|------|------|
| `ga`（visual） | mini.align 交互式 |
| `gaip` | 对齐当前段落（普通模式） |
| `<leader>a=` | 段落对齐 `=` |
| `<leader>a:` | 段落对齐 `:` |
| `<leader>a,` | 段落对齐 `,` |
| `<leader>a\|` | 段落对齐 `\|` |
| `<leader>a<` | 段落对齐 `<=`（SV 非阻塞赋值） |
| `<leader>a/` | 段落对齐 `//`（行尾注释） |
| `<leader>aa` | 交互模式（任意分隔符） |
| `<leader>aA` | vim-easy-align（更复杂场景） |

### 4.5 可发现性（Discoverability）—— 四层兜底

1. **`which-key.nvim`**：按 `<leader>` 停 0.3 秒弹菜单，分组显示所有键位
2. **`legendary.nvim` / `:Telescope keymaps`**：`<leader>?` 全键位模糊搜索
3. **`CHEATSHEET.md`**：本地 markdown 速查表，`<leader>?h` 一键打开
4. **`:Telescope help_tags`**：`<leader>sh` 模糊搜官方 help

**所有自定义键位强制注册 `desc`**，which-key 自动展示中文/英文说明。前缀字母固定语义：
- `<leader>a` = align
- `<leader>v` = vcs
- `<leader>U` = uvm（大写避免和小 u UI 冲突）
- `<leader>g` = git
- `<leader>r` = run

### 4.6 UI 设计（柔和暖色 + 全套装饰）

#### 主题
- 默认：`sainnhe/everforest`（柔和暖色）
- 备选：`sainnhe/gruvbox-material`、`rose-pine/neovim`
- `<leader>ub` 切换主题（白天/夜晚）

#### 装饰插件（全部启用）
| 插件 | 作用 |
|------|------|
| `lualine.nvim` | 状态栏 |
| `bufferline.nvim` | 顶部 tab 条 |
| `neo-tree.nvim` | 左侧文件树 |
| `alpha-nvim` | 启动 dashboard |
| `noice.nvim` | 命令行 / 消息美化 |
| `nvim-notify` | 飘窗通知 |
| `indent-blankline.nvim` | 缩进彩虹线 |
| `mini.animate` | 窗口/光标动画 |
| `nvim-scrollbar` | 滚动条带诊断标记 |
| `rainbow-delimiters.nvim` | 彩虹括号 |
| `nvim-web-devicons` | 文件类型图标 |

#### Neovide GUI 专属设置（`lua/plugins/neovide.lua`）
仅 `vim.g.neovide` 为真时生效：
- 字体：JetBrainsMono Nerd Font，14pt，Ligature 开
- 光标尾迹动画长度 0.05s
- 平滑滚动 0.2s
- 透明度 0.95
- 启动时全屏

---

## 5. 目录结构 + 文件清单

```
~/.config/nvim/                          # LazyVim starter 克隆而来
├── init.lua                              # LazyVim 入口（不动）
├── lua/
│   ├── config/
│   │   ├── lazy.lua                      # LazyVim 自带，不动
│   │   ├── options.lua                   # tab=2、行号、剪贴板
│   │   ├── keymaps.lua                   # 通用键位增强
│   │   └── autocmds.lua                  # 进入 SV 文件触发 verible 等
│   └── plugins/
│       ├── theme.lua                     # everforest / gruvbox-material / rose-pine
│       ├── ui-extras.lua                 # noice / notify / animate / scrollbar
│       ├── alpha-dashboard.lua           # 启动页定制 ASCII logo
│       ├── align.lua                     # mini.align + vim-easy-align
│       ├── motion.lua                    # leap.nvim + vim-sandwich
│       ├── lang-cpp.lua                  # clangd + clang-format + cppcheck
│       ├── lang-python.lua               # pyright + ruff + debugpy
│       ├── lang-sv.lua                   # verible LSP/lint/format + verilator
│       ├── lang-tcl.lua                  # tcl ts + tclint
│       ├── uvm-snippets.lua              # 加载 UVM snippet 集
│       ├── vcs.lua                       # :VcsCompile/:VcsSim
│       ├── overseer.lua                  # 任务运行器配置 + 模板
│       ├── nvim-lint.lua                 # 各语言 linter 串联
│       ├── conform.lua                   # 各语言 formatter 串联
│       ├── trouble.lua                   # 诊断/quickfix 面板
│       ├── cheatsheet.lua                # <leader>?h 打开速查表
│       └── neovide.lua                   # Neovide GUI 专属
├── snippets/
│   ├── systemverilog.json
│   ├── verilog.json
│   ├── tcl.json
│   ├── python.json
│   └── cpp.json
├── CHEATSHEET.md                         # 速查表（<leader>?h）
├── after/
│   └── ftplugin/
│       ├── systemverilog.lua
│       ├── verilog.lua
│       └── tcl.lua
└── lazy-lock.json                        # 插件版本锁（自动生成）
```

工作仓库 `/home/ubuntu/ryan/gvim_work/` 包含：

```
gvim_work/
├── install.sh                # 安装脚本
├── healthcheck.sh            # 健康检查
├── templates/                # 上面 ~/.config/nvim/ 的源副本（git 跟踪）
│   ├── lua/
│   ├── snippets/
│   ├── after/
│   └── CHEATSHEET.md
├── test/
│   ├── sample.sv
│   ├── sample.cpp
│   ├── sample.py
│   ├── sample.tcl
│   ├── Makefile
│   ├── golden/               # 格式化对比基线
│   └── smoke.sh
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-04-25-gvim-setup-design.md
└── README.md
```

---

## 6. 完整插件清单

### 核心 & 管理（LazyVim 自带）
- `folke/lazy.nvim`
- `LazyVim/LazyVim`

### UI / 主题
- `sainnhe/everforest`（默认）
- `sainnhe/gruvbox-material`
- `rose-pine/neovim`
- `nvim-lualine/lualine.nvim`
- `akinsho/bufferline.nvim`
- `nvim-neo-tree/neo-tree.nvim`
- `goolord/alpha-nvim`
- `folke/noice.nvim`
- `rcarriga/nvim-notify`
- `lukas-reineke/indent-blankline.nvim`
- `echasnovski/mini.animate`
- `petertriho/nvim-scrollbar`
- `HiPhish/rainbow-delimiters.nvim`
- `nvim-tree/nvim-web-devicons`

### 代码智能 / LSP
- `neovim/nvim-lspconfig`
- `williamboman/mason.nvim`
- `williamboman/mason-lspconfig.nvim`
- `WhoIsSethDaniel/mason-tool-installer.nvim`
- `hrsh7th/nvim-cmp` + cmp-nvim-lsp / cmp-buffer / cmp-path / cmp-cmdline
- `L3MON4D3/LuaSnip` + `saadparwaiz1/cmp_luasnip`
- `rafamadriz/friendly-snippets`
- `nvim-treesitter/nvim-treesitter`
- `nvim-treesitter/nvim-treesitter-textobjects`
- `mfussenegger/nvim-lint`
- `stevearc/conform.nvim`
- `folke/trouble.nvim`

### 编辑增强
- `echasnovski/mini.align`（核心对齐）
- `junegunn/vim-easy-align`（备用）
- `ggandor/leap.nvim`
- `machakann/vim-sandwich`
- `numToStr/Comment.nvim`
- `windwp/nvim-autopairs`
- `akinsho/toggleterm.nvim`

### 搜索 / 导航
- `nvim-telescope/telescope.nvim`
- `nvim-telescope/telescope-fzf-native.nvim`
- `nvim-telescope/telescope-frecency.nvim`
- `kevinhwang91/nvim-bqf`（quickfix 美化）
- `folke/which-key.nvim`
- `mrjones2014/legendary.nvim`

### 编译 / 任务 / 调试
- `stevearc/overseer.nvim`
- `mfussenegger/nvim-dap`（可选）
- `rcarriga/nvim-dap-ui`（可选）

### git
- `lewis6991/gitsigns.nvim`
- `tpope/vim-fugitive`
- `sindrets/diffview.nvim`

### 跳转兜底
- `ludovicchabant/vim-gutentags`（ctags）
- `dhananjaylatkar/cscope_maps.nvim`（cscope）

### 语言专属
- `vhda/verilog_systemverilog.vim`（SV/Verilog 老牌 ftplugin）
- `nachumk/systemverilog.vim`（备用）
- `antoinemadec/vim-verilog-instance`（一键 module 例化）

### 外部工具（mason-tool-installer 自动安装）
**LSP**：verible / clangd / pyright / lua-language-server / tclint-ls
**Formatter**：verible-verilog-format / clang-format / ruff / black / stylua
**Linter**：verible-verilog-lint / verilator / ruff / cppcheck / shellcheck / markdownlint
**Debugger**：debugpy / codelldb（可选）

需用户保证 `$PATH` 含：vcs / simv / verdi / dve（公司 EDA 环境）

---

## 7. 键位规划

### 7.1 顶层前缀分组
| 前缀 | 分组 | 用途 |
|------|------|------|
| `<leader>a` | +align | 对齐相关 |
| `<leader>b` | +buffer | buffer 切换/关闭/钉住 |
| `<leader>c` | +code | LSP 动作 |
| `<leader>d` | +debug | DAP 调试 |
| `<leader>f` | +file | 文件查找/最近/新建 |
| `<leader>g` | +git | git 操作 |
| `<leader>l` | +lazy | LazyVim/Lazy 插件管理 |
| `<leader>q` | +quit/session | 退出/会话 |
| `<leader>r` | +run | 编译/仿真/测试 |
| `<leader>s` | +search | 搜索 |
| `<leader>t` | +terminal | 终端 |
| `<leader>u` | +ui | UI 选项切换 |
| `<leader>v` | +vcs | VCS 编译/仿真 |
| `<leader>U` | +uvm | UVM 专用 |
| `<leader>w` | +window | 窗口切割 |
| `<leader>x` | +diagnostics | Trouble 诊断 |
| `<leader>?` | +help | 速查/全键位搜索 |

### 7.2 高频键位
完整列表参见 `CHEATSHEET.md`，关键键位见正文 4.x 节各表。

### 7.3 设计原则
1. 每个键位强制 `desc`
2. 前缀字母固定语义
3. 老 Vim 习惯键位保留（`<C-]>`、`gf` 等）
4. visual 模式键位独立设计

---

## 8. UVM Snippet 清单

### 8.1 顶层组件
触发词 + Tab 展开：`uvc / uvo / uvm_seq_item / uvm_seq / uvm_test / uvm_env / uvm_agent / uvm_driver / uvm_monitor / uvm_sequencer / uvm_scbd / uvm_subscriber / uvm_cfg`

### 8.2 Phase 模板
`bldp / cnnp / eosp / runp / rstp / cfgp / mainp / shutp / extp / chkp / repp`

### 8.3 UVM 宏 / 常用语句
`uvi / uvw / uve / uvf / uvfu / uvfo / uvfc / uvfp / cdb / cdbs / tic / objs`

### 8.4 RTL / Verilog
`mod / aff / acm / alt / ifdef / gen / genfor / intf / clkrst / fsm3 / dpr / inst`

### 8.5 Tcl / Python / C++
- Tcl：`proc / forarr / puts / pkg / tcltb`
- Python：`pyclass / pytest / dataclass / argparse / __main__`
- C++：`cls / tpl / incg / nspace / ifndef`

### 8.6 扩展
- 编辑 `snippets/*.json` 即可热加载
- `<leader>Un` 交互式录制选中代码为 snippet（可选实现）

完整 snippet 内容随实现一起交付。

---

## 9. 安装与验证

### 9.1 安装脚本：`gvim_work/install.sh`
幂等设计，重跑只补缺失。步骤：
1. 探测系统（distro / nvim 版本）
2. 系统包：neovim ≥0.10、ripgrep、fd、nodejs、python3-pip、cargo、build-essential
3. Nerd Font 安装（JetBrainsMono Nerd Font）
4. Neovide GUI（`--gui` 参数控制）
5. 备份旧配置（`~/.config/nvim` → `~/.config/nvim.bak.YYYYMMDD`）
6. 克隆 LazyVim starter 到 `~/.config/nvim`
7. 从 `templates/` 覆盖写入定制
8. headless 启动 Lazy 装插件 + Mason 装外部工具
9. 调用 healthcheck 验证

参数：
- `--gui` 装 Neovide
- `--no-mason` 跳过外部工具安装（无网时）
- `--minimal` 只装核心
- `--dry-run` 仅打印步骤
- `--restore <date>` 回滚到指定日期备份

### 9.2 健康检查：`gvim_work/healthcheck.sh`
逐项 `[OK]/[FAIL]` 输出，覆盖：
- Neovim 版本 ≥0.10
- ripgrep / fd / Nerd Font
- Lazy.nvim / Mason 目录存在
- LazyVim 主体 lua 加载成功
- 关键 LSP 二进制（verible-ls / clangd / pyright）
- Formatter（verible-format / clang-format / ruff）
- Treesitter parser（systemverilog / verilog / tcl / cpp / python）
- VCS / Verdi / UVM_HOME（仅 WARN，不算失败）
- CHEATSHEET.md 与 which-key 注册

期望最终：全部核心检查 OK，EDA 工具仅 WARN。

### 9.3 端到端冒烟测试：`gvim_work/test/smoke.sh`
覆盖关键链路：
1. 打开有意诊断的 sample.sv，断言 `vim.diagnostic.get(0)` 非空
2. conform 自动格式化 sample.sv，diff 对比 golden
3. mini.align 对齐选区，正则验证列已对齐
4. LSP `gd` 跳转 sample.cpp 中函数定义
5. overseer 跑 Makefile target，断言成功

### 9.4 升级 / 回滚
| 操作 | 命令 |
|------|------|
| 升级 LazyVim | `:Lazy update` |
| 升级 LSP/工具 | `:Mason update` |
| 升级 TS parser | `:TSUpdate` |
| 锁定版本 | `:Lazy lock` |
| 回滚配置 | `:Lazy restore` |
| 完全回退 | `mv ~/.config/nvim.bak.YYYYMMDD ~/.config/nvim` |
| 一键回滚 | `install.sh --restore <date>` |

### 9.5 跨机同步
`~/.config/nvim` 与 `gvim_work/templates/` 双向同步策略：
- 主开发：直接改 `~/.config/nvim`，定期 `make sync` 拷回 `templates/`
- 新机器：`git clone gvim_work && bash install.sh`
- `lazy-lock.json` 锁住所有插件版本，确保跨机器一致

---

## 10. 风险与缓解

| 风险 | 影响 | 缓解 |
|------|------|------|
| 公司机器无法访问 GitHub | 安装失败 | `--no-mason` + 离线包；`templates/` 自带核心 |
| Neovim 系统版本 < 0.10 | LazyVim 无法运行 | 安装脚本自动从 GitHub release 下二进制 |
| verible 对老 Verilog 解析失败 | 跨文件跳转弱 | ctags + cscope 兜底 |
| VCS errorformat 各版本不同 | quickfix 跳转失效 | 保留为 lua 函数易调，提供调试模式 |
| Neovide cargo install 失败 | GUI 不可用 | 备选 AppImage / 跳过 GUI 不影响终端使用 |
| 用户在 SSH 服务器上无 mason 网络 | 跳转/补全降级 | LSP 失败时自动 fallback ctags；提供离线 mason 包 |
| 插件升级破坏配置 | 突然不能用 | `lazy-lock.json` 版本锁 + 备份目录 + restore 命令 |

---

## 11. 验收标准

实施完成后，下列**全部为真**视为验收通过：

1. `bash install.sh` 在干净 Ubuntu 上一次运行成功
2. `bash healthcheck.sh` 输出全 OK（除 EDA WARN）
3. `bash test/smoke.sh` 5 个测试全绿
4. 启动 nvim 在 2 秒内进入 dashboard
5. 打开 sample.sv，3 秒内 verible 启动并显示诊断
6. `gd` 在 sample.cpp 的 `main` 函数上能跳转
7. 选中代码段按 `ga=` 能完成对齐
8. `<leader>?h` 能打开 CHEATSHEET.md
9. `<leader>` 停顿弹出 which-key 菜单
10. Neovide 启动后字体含图标、光标有动画

---

## 12. 后续工作（不在本 spec 范围）

- DAP 图形化调试深度集成
- 远程 SSH 上 mason 离线包打包
- AI 补全集成（copilot.lua / codeium / claude-code-nvim）
- 跟其他工具集成（Verdi `:Verdi` 命令、IC Manager 等）
- VSCode keybinding profile 兼容（给同事新人用）

这些项目在 v1 验收通过后单独立项。

---

## 附录 A：参考资源
- LazyVim 文档：https://www.lazyvim.org/
- Lazy.nvim：https://github.com/folke/lazy.nvim
- Mason：https://github.com/williamboman/mason.nvim
- verible：https://github.com/chipsalliance/verible
- mini.align：https://github.com/echasnovski/mini.nvim
- Neovide：https://neovide.dev/

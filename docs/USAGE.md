# gvim_work 使用说明

> 基于 LazyVim 的多语言 Neovim 开发环境，面向 C/C++ / Python / Tcl / SystemVerilog / UVM / Verilog

---

## 目录

1. [系统要求](#1-系统要求)
2. [安装](#2-安装)
3. [启动方式](#3-启动方式)
4. [首次使用：从零开始](#4-首次使用从零开始)
5. [界面介绍](#5-界面介绍)
6. [基础操作](#6-基础操作)
7. [文件与搜索](#7-文件与搜索)
8. [LSP 智能功能](#8-lsp-智能功能)
9. [代码对齐](#9-代码对齐)
10. [编译与仿真](#10-编译与仿真)
11. [VCS / UVM 专用功能](#11-vcs--uvm-专用功能)
12. [代码片段 (Snippets)](#12-代码片段-snippets)
13. [诊断与错误处理](#13-诊断与错误处理)
14. [Git 集成](#14-git-集成)
15. [终端](#15-终端)
16. [主题与 UI 定制](#16-主题与-ui-定制)
17. [Neovide GUI 专属功能](#17-neovide-gui-专属功能)
18. [快速跳转与编辑增强](#18-快速跳转与编辑增强)
19. [插件管理](#19-插件管理)
20. [配置自定义](#20-配置自定义)
21. [升级与回滚](#21-升级与回滚)
22. [跨机器同步](#22-跨机器同步)
23. [离线 / 内网环境](#23-离线--内网环境)
24. [常见问题](#24-常见问题)

---

## 1. 系统要求

| 项目 | 最低要求 |
|------|----------|
| 操作系统 | Ubuntu 20.04+ / CentOS 7+ / RHEL 8+ / Debian 10+ (WSL 也可) |
| Neovim | >= 0.10 (安装脚本会自动检测和提示) |
| Git | >= 2.0 |
| 终端 | 支持 24-bit 真彩色的终端 (xterm-256color / tmux / alacritty / kitty 等) |
| 字体 | Nerd Font (安装脚本自动安装 JetBrainsMono Nerd Font) |
| 网络 | 首次安装需要访问 GitHub (后续可离线使用) |

**可选：**

| 项目 | 用途 |
|------|------|
| Neovide | GUI 客户端，提供光标动画、平滑滚动、字体渲染增强 |
| VCS / Verdi | Synopsys EDA 仿真/波形工具 (公司环境) |
| UVM_HOME | UVM 库路径 (用于 SV 跨文件跳转) |

---

## 2. 安装

### 2.1 克隆仓库

```bash
git clone https://github.com/Beihang-yuting/nvim_work.git ~/gvim_work
cd ~/gvim_work
```

### 2.2 一键安装

```bash
# 基础安装 (终端版)
bash install.sh

# 含 Neovide GUI
bash install.sh --gui

# 无外网环境 (跳过 mason 工具下载)
bash install.sh --no-mason

# 最小安装 (跳过 Lazy sync，首次启动 nvim 时自动同步)
bash install.sh --minimal

# 预览模式 (只打印步骤，不实际执行)
bash install.sh --dry-run
```

安装脚本会自动完成以下步骤：

1. 探测 Linux 发行版和 Neovim 版本
2. 安装系统依赖 (neovim, ripgrep, fd, nodejs, python3-pip 等)
3. 安装 JetBrainsMono Nerd Font
4. 备份已有 `~/.config/nvim` 配置
5. 克隆 LazyVim starter 到 `~/.config/nvim`
6. 覆盖自定义配置模板
7. 后台安装所有插件 (Lazy sync)
8. 通过 Mason 安装 LSP / 格式化 / 静态检查工具

### 2.3 验证安装

```bash
# 健康检查 -- 逐项显示 OK / FAIL / WARN
bash healthcheck.sh

# 端到端冒烟测试
bash test/smoke.sh
```

healthcheck 输出示例：

```
== system ==
[OK] Neovim >= 0.10
[OK] ripgrep present
[OK] fd present
[OK] Nerd Font installed
== nvim runtime ==
[OK] Lazy.nvim cloned
[OK] Mason data dir
== LSP binaries ==
[OK]   verible-verilog-ls
[OK]   clangd
[OK]   pyright-langserver
...
== EDA tools (optional) ==
[WARN] VCS in PATH (optional)
[WARN] Verdi in PATH (optional)

Summary: PASS=18  FAIL=0  WARN=3
```

核心项全部 OK 即可正常使用，EDA 工具为 WARN 不影响功能。

---

## 3. 启动方式

### 3.1 终端模式

```bash
# 启动 nvim，进入 dashboard
nvim

# 直接打开某个文件
nvim path/to/file.sv

# 打开某个目录 (显示文件树)
nvim .

# 打开多个文件
nvim file1.sv file2.cpp file3.py

# 在指定行打开文件
nvim +42 file.sv
```

### 3.2 GUI 模式 (Neovide)

```bash
# 启动 Neovide (自动加载 nvim 配置)
neovide

# 打开文件
neovide path/to/file.sv

# 打开目录
neovide .
```

Neovide 相比终端的额外特性：
- 光标尾迹动画
- 平滑滚动
- 字体 Ligature 支持
- 窗口半透明效果
- `Cmd+C` / `Cmd+V` 复制粘贴 (macOS 风格)

### 3.3 远程 SSH

```bash
# 直接 SSH 到服务器使用
ssh user@remote-server
nvim file.sv

# 或在本地用 neovide 连接远程 (需要远程已安装 nvim)
neovide --server=remote-server
```

配置在本地和远程完全通用，无需额外设置。

---

## 4. 首次使用：从零开始

### 4.1 启动画面

启动 `nvim` 后，你会看到 dashboard 启动页：

```
          gvim_work . Neovim . LazyVim

       Multi-language code + hardware verif

  f    Find file
  r    Recent files
  g    Live grep
  c    Config
  ?    Cheat sheet
  L    Lazy
  M    Mason
  q    Quit

  press <Space>?h for the cheat sheet
```

直接按对应字母即可快速进入功能。

### 4.2 最重要的一件事

**按 `<Space>` 键然后等 0.3 秒** -- which-key 弹窗会列出所有可用操作分组：

```
+align      +buffer     +code       +debug
+file       +git        +lazy       +quit/session
+run        +search     +terminal   +ui
+vcs        +uvm        +window     +diagnostics
+help
```

按对应字母继续展开子菜单。**不需要记忆任何快捷键**，which-key 会引导你。

### 4.3 快速查阅

| 方式 | 操作 | 说明 |
|------|------|------|
| 速查表 | `<Space>?h` | 打开本地 CHEATSHEET.md |
| 搜索键位 | `<Space>?` | 模糊搜索所有快捷键和命令 |
| 帮助文档 | `<Space>sh` | 搜索 Neovim 官方 help |

---

## 5. 界面介绍

```
+---------- bufferline (顶部 tab 条) ----------+
| file1.sv | file2.cpp | file3.py |             |
+----------------------------------------------+
|        |                                      |
| neo-   |            编辑区                    |
| tree   |                                      |
| 文件   |  行号 | 代码内容                     |
| 树     |  sign |                              |
|        |  列   | (诊断标记/git修改标记在此)    |
|        |                                      |
+------+---------------------------------------+
|                lualine (状态栏)               |
| mode | branch | filename | diagnostics | pos |
+----------------------------------------------+
```

### 各区域说明

| 区域 | 说明 | 相关操作 |
|------|------|----------|
| **bufferline** | 顶部标签页，显示已打开的文件 | `<Space>,` 切换 buffer |
| **neo-tree** | 左侧文件树 | `<Space>e` 开关 |
| **编辑区** | 代码编辑主区域 | -- |
| **sign 列** | 左侧标记列，显示诊断图标和 git 变更 | 自动显示 |
| **lualine** | 底部状态栏，显示模式/分支/文件/诊断统计 | 自动更新 |
| **scrollbar** | 右侧滚动条，带诊断位置标记 | 自动显示 |
| **缩进线** | 彩虹色缩进引导线 | 自动显示 |

---

## 6. 基础操作

> 以下 `<Space>` 即 Leader 键。

### 6.1 文件操作

| 按键 | 功能 |
|------|------|
| `<Space><Space>` | 查找文件 (Telescope) |
| `<Space>,` | 切换已打开的 buffer |
| `<Space>e` | 打开/关闭文件树 |
| `<Space>fr` | 按使用频率排序的最近文件 |
| `<Ctrl-s>` | 保存文件 (普通/插入模式均可) |

### 6.2 窗口管理

| 按键 | 功能 |
|------|------|
| `<Ctrl-h/j/k/l>` | 在窗口间移动 (左/下/上/右) |
| `<Space>w` + 子键 | 窗口操作菜单 |
| `<Space>-` | 水平分割 |
| `<Space>\|` | 垂直分割 |

### 6.3 编辑增强

| 按键 | 功能 |
|------|------|
| `V` 选中 + `J` | 向下移动选中行 |
| `V` 选中 + `K` | 向上移动选中行 |
| `<Space>d` | 删除但不覆盖剪贴板 |
| `<Esc><Esc>` | 清除搜索高亮 |
| `gcc` | 注释/取消注释当前行 |
| `gc` (visual) | 注释/取消注释选中区域 |
| `sa` + 动作 + 字符 | 添加环绕 (vim-sandwich) |
| `sd` + 字符 | 删除环绕 |
| `sr` + 旧 + 新 | 替换环绕 |

### 6.4 折叠

| 按键 | 功能 |
|------|------|
| `za` | 切换当前折叠 |
| `zR` | 展开所有折叠 |
| `zM` | 关闭所有折叠 |
| `zo` | 展开当前折叠 |
| `zc` | 关闭当前折叠 |

折叠基于 Treesitter 语法树，按函数/类/模块自动识别折叠区域。默认不启用折叠（打开文件时代码全部展开）。

---

## 7. 文件与搜索

### 7.1 Telescope 搜索

Telescope 是核心搜索引擎，支持模糊匹配。

| 按键 | 功能 | 说明 |
|------|------|------|
| `<Space><Space>` | 查找文件 | 项目内文件名搜索 |
| `<Space>/` 或 `<Space>sg` | Live grep | 跨文件内容实时搜索 |
| `<Space>sw` | 搜索光标下的词 | 快速查找当前变量 |
| `<Space>sb` | Buffer 内搜索 | 当前文件内搜索 |
| `<Space>sh` | 搜索 help | Neovim 帮助文档搜索 |
| `<Space>fr` | 最近文件 (频率排序) | 按使用频次排序 |
| `<Space>,` | Buffer 列表 | 切换已打开文件 |
| `<Space>?` | 搜索键位 | 查找所有快捷键和命令 |

**Telescope 窗口内操作：**

| 按键 | 功能 |
|------|------|
| `<Ctrl-j>` / `<Ctrl-k>` | 上下移动选择 |
| `<Enter>` | 打开选中文件 |
| `<Ctrl-x>` | 水平分割打开 |
| `<Ctrl-v>` | 垂直分割打开 |
| `<Esc>` | 关闭 Telescope |

### 7.2 文件树 (neo-tree)

`<Space>e` 打开左侧文件树后：

| 按键 | 功能 |
|------|------|
| `<Enter>` | 打开文件/展开目录 |
| `a` | 新建文件/目录 |
| `d` | 删除 |
| `r` | 重命名 |
| `y` | 复制文件名 |
| `c` | 复制文件 |
| `m` | 移动文件 |
| `q` | 关闭文件树 |
| `.` | 显示隐藏文件 |

### 7.3 Quickfix 增强 (nvim-bqf)

当搜索结果或编译错误进入 quickfix 列表时，nvim-bqf 提供：
- 预览窗口（自动显示匹配位置上下文）
- 模糊过滤（在 quickfix 内二次搜索）

| 按键 | 功能 |
|------|------|
| `:cn` | 跳到下一个匹配 |
| `:cp` | 跳到上一个匹配 |
| `<Space>xq` | 在 Trouble 面板打开 quickfix |

---

## 8. LSP 智能功能

每种语言自动启用对应的 LSP 服务：

| 语言 | LSP 服务器 | 功能 |
|------|-----------|------|
| C/C++ | clangd | 补全、跳转、诊断、clang-tidy |
| Python | pyright + ruff | 类型检查、补全、诊断 |
| SystemVerilog / Verilog | verible-verilog-ls | 语法检查、风格、跳转 |
| Tcl | tclint | 语法检查 |
| Lua | lua-language-server | 配置文件编辑用 |

### 8.1 代码导航

| 按键 | 功能 | 说明 |
|------|------|------|
| `gd` | 跳到定义 | 最常用，跳到函数/变量/模块定义处 |
| `gD` | 跳到声明 | C/C++ 头文件声明 |
| `gr` | 查找所有引用 | 列出所有使用该符号的位置 |
| `gI` | 跳到实现 | 虚函数/接口的具体实现 |
| `gy` | 跳到类型定义 | 查看变量的类型定义 |
| `K` | 悬浮文档 | 显示函数签名、注释文档 |
| `<Ctrl-t>` | 跳回 | 返回跳转前的位置 |
| `<Ctrl-]>` | ctags 跳转 | LSP 不可用时的兜底方案 |

### 8.2 代码操作

| 按键 | 功能 |
|------|------|
| `<Space>cr` | 智能重命名 (全项目范围) |
| `<Space>ca` | 代码动作 (自动修复、提取函数等) |
| `<Space>cf` | 格式化当前文件 |
| `<Space>cs` | 当前文件符号大纲 |
| `<Space>cS` | 工作区符号搜索 |

### 8.3 自动补全

输入时自动弹出补全菜单 (nvim-cmp)：

| 按键 | 功能 |
|------|------|
| `<Tab>` | 选择下一个补全项 / 展开 snippet |
| `<Shift-Tab>` | 选择上一个补全项 |
| `<Enter>` | 确认补全 |
| `<Ctrl-e>` | 关闭补全菜单 |
| `<Ctrl-Space>` | 手动触发补全 |

补全来源优先级：LSP > snippet > buffer 词 > 文件路径。

### 8.4 跳转兜底机制

当 LSP 无法提供跳转时（如老版本 Verilog 代码），系统自动 fallback：

1. **LSP 跳转** (最准) -- verible / clangd / pyright
2. **ctags 跳转** (vim-gutentags 后台自动生成) -- `<Ctrl-]>`
3. **cscope 跳转** (C/C++ caller/callee) -- `<Space>j` 前缀
4. **Telescope 文本搜索** (最后手段) -- `<Space>sg`

### 8.5 SV 跨文件跳转配置

打开 `.sv` / `.svh` 文件时会自动：
1. 查找项目根目录下的 `*.f` filelist 文件
2. 如果没有 `*.f`，自动扫描目录生成 filelist (最多 2000 个文件)
3. 将 filelist 传给 verible LSP，实现跨文件符号解析

如果你的项目使用 filelist，确保项目根目录有 `.f` 文件。

### 8.6 C/C++ 项目配置

clangd 需要 `compile_commands.json` 来理解项目结构：

```bash
# CMake 项目
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .

# Makefile 项目 (使用 bear)
bear -- make
```

有了 `compile_commands.json`，clangd 的补全、跳转、诊断会显著更准。

---

## 9. 代码对齐

代码对齐是本配置的核心功能之一，基于 mini.align 和 vim-easy-align。

### 9.1 快速对齐 (普通模式)

| 按键 | 功能 | 示例 |
|------|------|------|
| `<Space>a=` | 段落按 `=` 对齐 | 变量赋值对齐 |
| `<Space>a:` | 段落按 `:` 对齐 | 字典/JSON 对齐 |
| `<Space>a,` | 段落按 `,` 对齐 | 参数列表对齐 |
| `<Space>a\|` | 段落按 `\|` 对齐 | Markdown 表格对齐 |
| `<Space>a<` | 段落按 `<=` 对齐 | **SV 非阻塞赋值对齐** |
| `<Space>a/` | 段落按 `//` 对齐 | 行尾注释对齐 |
| `<Space>aa` | 自定义分隔符 | 输入任意模式 |
| `<Space>aA` | vim-easy-align | 复杂场景 |

### 9.2 交互式对齐 (可视模式)

1. `V` 进入行选择模式，选中要对齐的行
2. 按 `ga` 进入 mini.align 交互模式
3. 输入分隔符 (如 `=`) 即可对齐

按 `gA` 可以实时预览对齐效果。

### 9.3 对齐示例

**对齐前 (SV 非阻塞赋值)：**
```systemverilog
data_out <= data_in;
valid <= 1'b1;
ready_to_send <= buffer_not_empty;
```

光标在段落内，按 `<Space>a<`：

**对齐后：**
```systemverilog
data_out       <= data_in;
valid          <= 1'b1;
ready_to_send  <= buffer_not_empty;
```

**对齐前 (变量赋值)：**
```python
x = 1
long_name = "hello"
y = 42
```

按 `<Space>a=`：

**对齐后：**
```python
x         = 1
long_name = "hello"
y         = 42
```

---

## 10. 编译与仿真

### 10.1 任务运行器 (overseer.nvim)

`<Space>r` 打开运行菜单：

| 按键 | 功能 |
|------|------|
| `<Space>rr` | 任务菜单 -- 列出所有可运行的任务 |
| `<Space>rt` | 切换任务列表面板 |
| `<Space>rm` | 运行 Makefile target (自动发现所有 target) |
| `<Space>rp` | pytest 运行当前 Python 文件 |
| `<Space>rl` | 重跑上一次命令 |
| `<Space>rk` | 对运行中任务执行操作 (停止/重启等) |

### 10.2 编译错误跳转

编译产生的错误自动进入 quickfix 列表：

| 按键 | 功能 |
|------|------|
| `:cn` | 跳到下一个错误 |
| `:cp` | 跳到上一个错误 |
| `<Space>xq` | 用 Trouble 面板查看 quickfix |

---

## 11. VCS / UVM 专用功能

### 11.1 VCS 命令

`<Space>v` 打开 VCS 菜单：

| 按键 | 命令 | 功能 |
|------|------|------|
| `<Space>vc` | `:VcsCompile` | 编译 -- 调用 `make comp` |
| `<Space>vs` | `:VcsSim` | 仿真 -- 弹出输入框填 UVM_TESTNAME，调用 `make sim TEST=xxx` |
| `<Space>vS` | `:VcsLast` | 重跑上次仿真 |
| `<Space>vw` | `:VcsWave` | 打开波形工具 (默认 verdi，可通过 `$VCS_WAVE_TOOL` 改为 dve) |
| `<Space>vq` | `:VcsClean` | 清理编译产物 -- 调用 `make clean` |

VCS 的 errorformat 已预配置，编译错误可直接 `:cn` / `:cp` 跳转到 `file.sv:line`。

### 11.2 VCS 环境配置

确保以下环境变量在 shell 中设置好：

```bash
# 在 ~/.bashrc 或 ~/.cshrc 中
export VCS_HOME=/path/to/vcs
export VERDI_HOME=/path/to/verdi
export UVM_HOME=/path/to/uvm/src
export PATH=$VCS_HOME/bin:$VERDI_HOME/bin:$PATH

# 可选：切换波形工具
export VCS_WAVE_TOOL=verdi  # 或 dve
```

### 11.3 项目 Makefile 模板

VCS 命令依赖项目 Makefile 中定义以下 target：

```makefile
# 示例 Makefile
comp:
	vlogan -sverilog -full64 +v2k -f filelist.f
	vcs -sverilog -full64 -debug_access+all tb_top

sim:
	./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_MEDIUM

clean:
	rm -rf csrc simv* *.daidir DVEfiles ucli.key vc_hdrs.h
```

---

## 12. 代码片段 (Snippets)

在**插入模式**下输入触发词然后按 `<Tab>` 展开。

### 12.1 UVM 组件

| 触发词 | 展开内容 |
|--------|----------|
| `uvc` | uvm_component 骨架 |
| `uvo` | uvm_object 骨架 |
| `uvm_test` | uvm_test (含 env 和 objection) |
| `uvm_seq` | uvm_sequence body |
| `uvm_seq_item` | uvm_sequence_item |
| `uvm_env` | uvm_env 骨架 |
| `uvm_agent` | uvm_agent 骨架 |
| `uvm_driver` | uvm_driver 骨架 |
| `uvm_monitor` | uvm_monitor 骨架 |
| `uvm_sequencer` | uvm_sequencer |
| `uvm_scbd` | uvm_scoreboard |
| `uvm_subscriber` | uvm_subscriber |
| `uvm_cfg` | uvm_config_db |

### 12.2 UVM Phase

| 触发词 | 展开内容 |
|--------|----------|
| `bldp` | build_phase |
| `cnnp` | connect_phase |
| `eosp` | end_of_elaboration_phase |
| `runp` | run_phase |
| `rstp` | reset_phase |
| `cfgp` | configure_phase |
| `mainp` | main_phase |
| `shutp` | shutdown_phase |
| `extp` | extract_phase |
| `chkp` | check_phase |
| `repp` | report_phase |

### 12.3 UVM 宏与常用语句

| 触发词 | 展开内容 |
|--------|----------|
| `uvi` | `` `uvm_info `` |
| `uvw` | `` `uvm_warning `` |
| `uve` | `` `uvm_error `` |
| `uvf` | `` `uvm_fatal `` |
| `uvfu` | `` `uvm_field_utils_begin `` |
| `uvfo` | `` `uvm_object_utils `` |
| `uvfc` | `` `uvm_component_utils `` |
| `cdb` | `uvm_config_db#(...)::get(...)` |
| `cdbs` | `uvm_config_db#(...)::set(...)` |
| `tic` | `type_id::create(...)` |
| `objs` | `raise/drop_objection` |

### 12.4 RTL / Verilog

| 触发词 | 展开内容 |
|--------|----------|
| `mod` | module 骨架 |
| `aff` | always_ff 块 |
| `acm` | always_comb 块 |
| `alt` | always (时序逻辑) |
| `ifdef` | `` `ifdef / `endif `` |
| `gen` | generate 块 |
| `genfor` | generate for 块 |
| `intf` | interface 骨架 |
| `clkrst` | clock + reset 生成 |
| `fsm3` | 三段式状态机 |
| `inst` | 模块例化 |

### 12.5 Tcl

| 触发词 | 展开内容 |
|--------|----------|
| `proc` | proc 函数定义 |
| `forarr` | foreach 遍历数组 |
| `puts` | puts 打印 |
| `pkg` | package require |
| `tcltb` | Tcl testbench 骨架 |

### 12.6 Python

| 触发词 | 展开内容 |
|--------|----------|
| `pyclass` | class 定义 |
| `pytest` | pytest 测试函数 |
| `dataclass` | @dataclass 类 |
| `argparse` | argparse 参数解析 |
| `__main__` | if __name__ == "__main__" |

### 12.7 C++

| 触发词 | 展开内容 |
|--------|----------|
| `cls` | class 定义 |
| `tpl` | template 模板 |
| `incg` | #include guard |
| `nspace` | namespace 块 |
| `ifndef` | #ifndef guard |

### 12.8 自定义 Snippet

编辑 `~/.config/nvim/snippets/` 下的 JSON 文件即可热加载：

```json
{
  "my_snippet": {
    "prefix": "mysnip",
    "body": [
      "line1: ${1:placeholder}",
      "line2: ${2:another}",
      "$0"
    ],
    "description": "My custom snippet"
  }
}
```

保存后无需重启，LuaSnip 会自动加载。

---

## 13. 诊断与错误处理

### 13.1 实时诊断

代码中的错误和警告会以多种方式展示：
- **左侧 sign 列**：错误显示红色标记，警告显示黄色标记
- **下划波浪线**：有问题的代码下方显示波浪线
- **Hover 弹窗**：光标停在问题代码上时显示详情
- **状态栏**：底部显示当前文件错误/警告数量

### 13.2 诊断导航

| 按键 | 功能 |
|------|------|
| `]d` | 跳到下一个诊断 |
| `[d` | 跳到上一个诊断 |
| `<Space>xx` | 打开 Trouble 面板 -- 工作区所有诊断 |
| `<Space>xX` | Trouble 面板 -- 仅当前文件诊断 |
| `<Space>xs` | 符号大纲面板 |

### 13.3 格式化

| 操作 | 说明 |
|------|------|
| 保存时自动格式化 | 默认开启 (markdown 除外) |
| `<Space>cf` | 手动格式化当前文件 |
| `<Space>uf` | 开关自动格式化 |

格式化工具映射：

| 语言 | 格式化工具 |
|------|-----------|
| C/C++ | clang-format (使用项目 `.clang-format` 配置) |
| Python | ruff format (优先) / black (备选) |
| SystemVerilog / Verilog | verible-verilog-format |
| Lua | stylua |
| Shell | shfmt |
| Markdown | prettier |

### 13.4 静态检查 (Linter)

在保存文件或停止输入时自动触发：

| 语言 | Linter | 时机 |
|------|--------|------|
| Python | ruff | 输入停顿 + 保存 |
| C/C++ | cppcheck | 保存 |
| SystemVerilog | verible-verilog-lint | 保存 |
| Verilog | verilator --lint-only | 保存 |
| Shell | shellcheck | 输入停顿 |
| Markdown | markdownlint | 保存 |

### 13.5 保存时自动清理

保存文件时会自动删除行尾空白 (trailing whitespace)，markdown 文件除外。

---

## 14. Git 集成

### 14.1 快捷键

`<Space>g` 打开 Git 菜单：

| 按键 | 功能 |
|------|------|
| `<Space>gg` | 打开 LazyGit (全功能 Git 终端 UI) |
| `<Space>gb` | 当前行 git blame |
| `<Space>gd` | Diff 视图 |
| `]c` / `[c` | 跳到下/上一个 git 修改块 (hunk) |

### 14.2 Gitsigns (行内标记)

编辑区左侧 sign 列自动显示 git 变更状态：
- 绿色竖线：新增行
- 蓝色竖线：修改行
- 红色三角：删除行

### 14.3 Diffview

`:DiffviewOpen` 打开全屏 diff 视图，支持：
- 文件级别的变更对比
- 多文件分屏浏览
- `:DiffviewClose` 关闭

---

## 15. 终端

### 15.1 内置终端 (toggleterm)

| 按键 | 功能 |
|------|------|
| `<Ctrl-/>` | 开关浮动终端 |
| `<Space>tt` | 水平终端 |
| `<Space>tv` | 垂直终端 (80列宽) |
| `<Space>tf` | 浮动终端 |

### 15.2 终端内操作

- 进入终端自动进入插入模式
- 按 `<Esc>` 退出终端插入模式，回到普通模式
- 普通模式下可以用 vim 操作翻页、复制终端输出

---

## 16. 主题与 UI 定制

### 16.1 主题切换

| 按键 | 功能 |
|------|------|
| `<Space>ub` | 切换主题 |

预装三套主题：
- **everforest** (默认) -- 柔和暖色，护眼
- **gruvbox-material** -- 温暖复古
- **rose-pine** -- 优雅淡色

切换方式：`:colorscheme gruvbox-material` 或 `:colorscheme rose-pine`

### 16.2 UI 开关

| 按键 | 功能 |
|------|------|
| `<Space>un` | 切换行号显示 |
| `<Space>ur` | 切换相对行号 |
| `<Space>uf` | 切换保存时自动格式化 |
| `<Space>uz` | Zen 模式 (全屏专注) |

### 16.3 默认编辑器设置

| 选项 | 值 | 说明 |
|------|-----|------|
| Tab 宽度 | 2 空格 | 空格替代 Tab |
| 行号 | 绝对 + 相对 | 当前行绝对行号，其余显示相对距离 |
| 剪贴板 | 系统剪贴板 | `yy` 复制直接可在系统粘贴 |
| 鼠标 | 全模式启用 | 可以鼠标点击、选择、滚动 |
| 光标行高亮 | 开启 | 当前行有背景色 |
| 滚动边距 | 上下 8 行 | 光标不会贴到屏幕边缘 |
| 搜索 | 忽略大小写 + 智能大小写 | 搜索小写时不区分，含大写时精确匹配 |
| 撤销 | 持久化 | 关闭文件后重新打开仍可撤销 |
| 新窗口 | 右侧 / 下方 | 分屏默认位置 |

---

## 17. Neovide GUI 专属功能

仅在通过 `neovide` 启动时生效：

| 功能 | 设置 |
|------|------|
| 字体 | JetBrainsMono Nerd Font 14pt, Ligature 开启 |
| 光标尾迹 | 动画时长 0.05s, 尾迹长度 0.6 |
| 平滑滚动 | 动画时长 0.2s |
| 窗口透明度 | 95% |
| 窗口模糊 | 水平/垂直模糊 2.0 |
| 窗口大小 | 记住上次窗口尺寸 |
| 剪贴板 | `Cmd+C` 复制, `Cmd+V` 粘贴 |

---

## 18. 快速跳转与编辑增强

### 18.1 Leap 跳转

按 `s` + 两个字符即可跳转到屏幕上任意匹配位置：

1. 按 `s` (向前跳) 或 `S` (向后跳)
2. 输入目标位置的两个字符
3. 如果有多个匹配，按显示的标签字母选择

比如要跳到 `function` 这个词：按 `s` 然后输入 `fu`，直接跳过去。

### 18.2 vim-sandwich 环绕操作

| 操作 | 按键 | 示例 |
|------|------|------|
| 添加 | `sa` + 动作 + 字符 | `saiw"` 给当前词加双引号 |
| 删除 | `sd` + 字符 | `sd"` 删除周围双引号 |
| 替换 | `sr` + 旧 + 新 | `sr"'` 双引号改单引号 |

### 18.3 自动配对

输入 `(`、`[`、`{`、`"`、`'` 时自动补全另一半。

---

## 19. 插件管理

### 19.1 Lazy.nvim 插件管理器

| 命令 | 功能 |
|------|------|
| `:Lazy` | 打开插件管理界面 |
| `:Lazy update` | 更新所有插件 |
| `:Lazy sync` | 同步插件 (安装缺失 + 更新) |
| `:Lazy health` | 检查插件健康状态 |
| `:Lazy profile` | 查看启动耗时分析 |

### 19.2 Mason 工具管理器

| 命令 | 功能 |
|------|------|
| `:Mason` | 打开 Mason 管理界面 |
| `:Mason update` | 更新所有工具 |
| `:MasonToolsInstall` | 安装所有配置的工具 |

Mason 管理的工具列表：
- **LSP**: verible, clangd, pyright, lua-language-server, tclint
- **Formatter**: verible-verilog-format, clang-format, ruff, black, stylua, shfmt
- **Linter**: verible-verilog-lint, verilator, cppcheck, shellcheck, markdownlint
- **Debugger**: debugpy

### 19.3 Treesitter 语法解析器

| 命令 | 功能 |
|------|------|
| `:TSUpdate` | 更新所有语法解析器 |
| `:TSInstall <lang>` | 安装指定语言解析器 |

已安装的解析器：systemverilog, verilog, tcl, c, cpp, python, lua, make, cmake, toml, ninja, rst

---

## 20. 配置自定义

### 20.1 文件结构

```
~/.config/nvim/
├── init.lua                   # 入口 (不要修改)
├── lua/
│   ├── config/
│   │   ├── lazy.lua           # LazyVim 引导 (不要修改)
│   │   ├── options.lua        # 编辑器选项 (可修改)
│   │   ├── keymaps.lua        # 自定义键位 (可修改)
│   │   └── autocmds.lua       # 自动命令 (可修改)
│   └── plugins/
│       ├── theme.lua          # 主题
│       ├── lang-*.lua         # 各语言配置
│       └── *.lua              # 其他插件配置
├── snippets/                  # 代码片段 (可增减)
└── CHEATSHEET.md              # 速查表 (可修改)
```

### 20.2 修改建议

**修改编辑器选项** -- 编辑 `~/.config/nvim/lua/config/options.lua`：
```lua
-- 例：改为 4 空格缩进
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
```

**添加新键位** -- 编辑 `~/.config/nvim/lua/config/keymaps.lua`：
```lua
vim.keymap.set("n", "<leader>xx", function()
  -- your action
end, { desc = "My custom action" })
```

**添加新插件** -- 在 `~/.config/nvim/lua/plugins/` 下新建 `.lua` 文件：
```lua
-- ~/.config/nvim/lua/plugins/my-plugin.lua
return {
  { "author/plugin-name", event = "VeryLazy", opts = {} },
}
```

### 20.3 同步修改回仓库

在 `~/gvim_work` 目录运行：

```bash
make sync
```

会将 `~/.config/nvim` 的修改同步回 `templates/` 目录，然后可以 `git commit` 保存。

---

## 21. 升级与回滚

### 21.1 升级

| 操作 | 命令 | 说明 |
|------|------|------|
| 升级插件 | `:Lazy update` | 在 nvim 内执行 |
| 升级 LSP/工具 | `:Mason update` | 在 nvim 内执行 |
| 升级语法解析器 | `:TSUpdate` | 在 nvim 内执行 |
| 升级配置 | `cd ~/gvim_work && git pull && bash install.sh` | 拉取最新配置重装 |

### 21.2 回滚

安装脚本每次运行都会备份当前配置到 `~/.config/nvim.bak.YYYYMMDD`。

```bash
# 查看可用备份
ls ~/.config/nvim.bak.*

# 回滚到指定日期
bash install.sh --restore 20260425

# 或使用 make
make restore D=20260425
```

插件版本锁定在 `~/.config/nvim/lazy-lock.json`，可以：
```vim
" 在 nvim 内回滚插件到锁定版本
:Lazy restore
```

---

## 22. 跨机器同步

### 22.1 部署到新机器

```bash
# 在新机器上
git clone https://github.com/Beihang-yuting/nvim_work.git ~/gvim_work
cd ~/gvim_work
bash install.sh
```

### 22.2 保持多台机器同步

```bash
# 在主开发机上修改配置后
cd ~/gvim_work
make sync              # 同步 nvim 配置到 templates/
git add -A && git commit -m "update config"
git push

# 在其他机器上
cd ~/gvim_work
git pull
bash install.sh        # 重新部署
```

---

## 23. 离线 / 内网环境

### 23.1 无外网安装

```bash
bash install.sh --no-mason
```

这会跳过 Mason 工具下载。LSP/格式化/静态检查功能会降级，但基础编辑、语法高亮、文件搜索等不受影响。

### 23.2 离线可用的功能

| 功能 | 是否需要网络 |
|------|-------------|
| 语法高亮 (Treesitter) | 首次安装需要，之后离线可用 |
| 文件搜索 (Telescope) | 不需要 |
| 代码对齐 | 不需要 |
| Snippet 展开 | 不需要 |
| 文件树 | 不需要 |
| Git 操作 | 不需要 (本地 git) |
| LSP 跳转/补全 | 不需要 (工具已安装的情况下) |
| ctags 跳转 | 不需要 |

### 23.3 手动安装 Mason 工具

如果需要在无网环境用 LSP，可以在有网的机器上打包 `~/.local/share/nvim/mason/` 目录，拷贝到目标机器。

---

## 24. 常见问题

### Q: 启动后没有颜色/显示乱码

确保终端支持 24-bit 真彩色：
```bash
# 在 ~/.bashrc 中添加
export TERM=xterm-256color

# tmux 用户需要在 ~/.tmux.conf 中添加
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

字体乱码则需要安装 Nerd Font：
```bash
bash ~/gvim_work/install.sh  # 安装脚本会自动安装字体
# 然后在终端设置中选择 JetBrainsMono Nerd Font
```

### Q: LSP 不工作 / 没有补全

1. 检查 LSP 是否安装：`:Mason` 查看工具状态
2. 检查 LSP 是否启动：`:LspInfo` 查看当前 buffer 的 LSP 状态
3. C/C++ 项目需要 `compile_commands.json`
4. SV 项目需要 `.f` filelist 或自动扫描

### Q: 插件安装失败 / 网络超时

```vim
" 在 nvim 内重试
:Lazy sync

" 或使用代理
" 在 ~/.bashrc 中设置
export https_proxy=http://proxy:port
```

### Q: 如何禁用某个插件

在 `~/.config/nvim/lua/plugins/` 下新建文件：
```lua
-- disabled.lua
return {
  { "plugin/name", enabled = false },
}
```

### Q: 保存时不想自动格式化

按 `<Space>uf` 切换，或在配置中永久关闭：
```lua
-- ~/.config/nvim/lua/config/options.lua
vim.g.disable_autoformat = true
```

### Q: Neovide 安装失败

参考 `lib/neovide.sh` 中的逻辑：
1. 优先尝试 `cargo install neovide`
2. 失败时自动下载 AppImage

手动安装 AppImage：
```bash
mkdir -p ~/.local/bin
curl -fL https://github.com/neovide/neovide/releases/latest/download/neovide-linux-x86_64.AppImage \
  -o ~/.local/bin/neovide
chmod +x ~/.local/bin/neovide
```

### Q: 如何查看启动耗时

```vim
:Lazy profile
```

正常启动应在 2 秒以内。如果某个插件耗时过长，可以设置为 lazy load。

### Q: 复制内容到系统剪贴板不生效

确保系统有剪贴板工具：
```bash
# Ubuntu/Debian
sudo apt install xclip

# 或
sudo apt install xsel

# SSH 远程环境下需要 X11 forwarding
ssh -X user@remote
```

---

## 附录：完整键位速查

> 按 `<Space>?h` 在 nvim 内打开速查表，或按 `<Space>?` 模糊搜索所有键位。

### Leader 键分组一览

| 前缀 | 分组 | 用途 |
|------|------|------|
| `<Space>a` | +align | 代码对齐 |
| `<Space>b` | +buffer | buffer 管理 |
| `<Space>c` | +code | LSP 代码操作 |
| `<Space>d` | +debug | 调试 (DAP) |
| `<Space>e` | -- | 文件树开关 |
| `<Space>f` | +file | 文件操作 |
| `<Space>g` | +git | Git 操作 |
| `<Space>j` | +cscope | cscope 查询 (C/C++) |
| `<Space>l` | +lazy | 插件管理 |
| `<Space>q` | +quit | 退出/会话 |
| `<Space>r` | +run | 编译/运行/测试 |
| `<Space>s` | +search | 搜索 |
| `<Space>t` | +terminal | 终端 |
| `<Space>u` | +ui | UI 选项切换 |
| `<Space>U` | +uvm | UVM 专用 |
| `<Space>v` | +vcs | VCS 仿真 |
| `<Space>w` | +window | 窗口管理 |
| `<Space>x` | +diagnostics | 诊断/Trouble |
| `<Space>?` | +help | 帮助/速查 |

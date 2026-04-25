# gvim_work

一份开箱即用的 Neovim 配置仓库（基于 LazyVim），面向 C/C++/Python/Tcl/SystemVerilog/UVM/Verilog 的多语言开发与硬件验证。

## 一键安装

### Linux / WSL

```bash
git clone https://github.com/Beihang-yuting/nvim_work.git ~/gvim_work
cd ~/gvim_work
bash install.sh                # 终端版
bash install.sh --gui          # 含 Neovide GUI
bash install.sh --no-mason     # 无网环境
```

### Windows (PowerShell)

```powershell
git clone https://github.com/Beihang-yuting/nvim_work.git $HOME\gvim_work
cd $HOME\gvim_work
.\install.ps1                  # 终端版 (需要 winget 或 scoop)
.\install.ps1 -Gui             # 含 Neovide GUI
.\install.ps1 -NoMason         # 无网环境
```

### 卸载

```bash
bash install.sh --uninstall    # Linux
```
```powershell
.\install.ps1 -Uninstall       # Windows
```

## 验证

```bash
bash healthcheck.sh
bash test/smoke.sh
```

## 文档

- **使用说明**：[`docs/USAGE.md`](docs/USAGE.md)
- 设计规格：`docs/superpowers/specs/2026-04-25-gvim-setup-design.md`
- 实施计划：`docs/superpowers/plans/2026-04-25-gvim-setup.md`
- 速查表：部署后位于 `~/.config/nvim/CHEATSHEET.md`，按 `<leader>?h` 打开

## 升级 / 回滚

| 操作 | 命令 |
|------|------|
| 升级插件 | `:Lazy update` |
| 升级 LSP/工具 | `:Mason update` |
| 回滚配置 | `bash install.sh --restore <YYYYMMDD>` |

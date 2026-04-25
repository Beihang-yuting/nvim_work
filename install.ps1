#Requires -Version 5.1
<#
.SYNOPSIS
    gvim_work Windows 一键安装脚本
.DESCRIPTION
    在 Windows 上部署基于 LazyVim 的 Neovim 多语言开发环境。
    支持 winget / scoop 包管理器。
.PARAMETER Gui
    同时安装 Neovide GUI
.PARAMETER NoMason
    跳过 mason 外部工具安装
.PARAMETER Minimal
    最小安装，跳过 Lazy sync
.PARAMETER DryRun
    仅打印步骤，不实际执行
.PARAMETER Uninstall
    一键卸载 nvim/neovide 及所有配置和数据
.PARAMETER Restore
    回滚到指定日期备份 (YYYYMMDD)
.EXAMPLE
    .\install.ps1
    .\install.ps1 -Gui
    .\install.ps1 -Uninstall
    .\install.ps1 -Restore 20260425
#>
param(
    [switch]$Gui,
    [switch]$NoMason,
    [switch]$Minimal,
    [switch]$DryRun,
    [switch]$Uninstall,
    [string]$Restore
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# -- 路径定义 --
$NvimConfig   = "$env:LOCALAPPDATA\nvim"
$NvimData     = "$env:LOCALAPPDATA\nvim-data"
$NvimCache    = "$env:TEMP\nvim"
$TemplatesDir = Join-Path $ScriptDir "templates"

# -- 日志函数 --
function Log-Step  ($msg) { Write-Host "`n== $msg ==" -ForegroundColor Cyan }
function Log-Ok    ($msg) { Write-Host "[OK  ] $msg" -ForegroundColor Green }
function Log-Info  ($msg) { Write-Host "[INFO] $msg" -ForegroundColor Gray }
function Log-Warn  ($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Log-Err   ($msg) { Write-Host "[ERR ] $msg" -ForegroundColor Red }

# -- 包管理器检测 --
function Get-PkgManager {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return "winget" }
    if (Get-Command scoop  -ErrorAction SilentlyContinue) { return "scoop" }
    return $null
}

function Install-Pkg {
    param([string]$WingetId, [string]$ScoopName)
    $mgr = Get-PkgManager
    if ($mgr -eq "winget") {
        winget install --id $WingetId --accept-source-agreements --accept-package-agreements -e 2>$null
    } elseif ($mgr -eq "scoop") {
        scoop install $ScoopName 2>$null
    } else {
        Log-Err "未找到 winget 或 scoop，请先安装其中之一"
        Log-Info "安装 scoop: irm get.scoop.dev | iex"
        exit 1
    }
}

# -- 卸载 --
function Uninstall-All {
    Log-Step "一键卸载 Neovim / Neovide 环境"

    $dirs = @($NvimConfig, $NvimData, $NvimCache)
    $backups = Get-ChildItem "$env:LOCALAPPDATA\nvim.bak.*" -Directory -ErrorAction SilentlyContinue

    Write-Host "`n即将删除以下内容：`n"
    Write-Host "  配置/数据目录："
    foreach ($d in $dirs) {
        if (Test-Path $d) { Write-Host "    $d" }
    }
    Write-Host "  备份目录："
    if ($backups) {
        foreach ($b in $backups) { Write-Host "    $($b.FullName)" }
    } else {
        Write-Host "    (无)"
    }
    Write-Host ""

    $answer = Read-Host "确认卸载? [y/N]"
    if ($answer -notmatch '^[yY]') {
        Log-Info "已取消"; return
    }

    foreach ($d in $dirs) {
        if (Test-Path $d) {
            Remove-Item $d -Recurse -Force
            Log-Ok "已删除 $d"
        }
    }

    # 通过包管理器卸载二进制
    $mgr = Get-PkgManager
    if ($mgr -eq "winget") {
        winget uninstall Neovim.Neovim   2>$null
        winget uninstall Neovide.Neovide 2>$null
    } elseif ($mgr -eq "scoop") {
        scoop uninstall neovim  2>$null
        scoop uninstall neovide 2>$null
    }
    Log-Ok "已卸载 neovim / neovide"

    if ($backups) {
        $answer2 = Read-Host "同时删除所有备份? [y/N]"
        if ($answer2 -match '^[yY]') {
            foreach ($b in $backups) {
                Remove-Item $b.FullName -Recurse -Force
                Log-Ok "已删除 $($b.FullName)"
            }
        } else {
            Log-Info "保留备份目录"
        }
    }

    Log-Ok "卸载完成"
}

# -- 备份 --
function Backup-NvimConfig {
    if (-not (Test-Path $NvimConfig)) {
        Log-Info "无现有 nvim 配置，跳过备份"; return
    }
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $dst = "$env:LOCALAPPDATA\nvim.bak.$stamp"
    Copy-Item $NvimConfig $dst -Recurse -Force
    Log-Ok "已备份旧配置到 $dst"
}

function Restore-NvimConfig {
    param([string]$Date)
    $pattern = "$env:LOCALAPPDATA\nvim.bak.${Date}*"
    $found = Get-ChildItem $pattern -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $found) {
        Log-Err "找不到备份 $pattern"; exit 1
    }
    if (Test-Path $NvimConfig) { Remove-Item $NvimConfig -Recurse -Force }
    Copy-Item $found.FullName $NvimConfig -Recurse -Force
    Log-Ok "已从 $($found.FullName) 恢复"
}

# -- 安装系统依赖 --
function Install-SystemDeps {
    Log-Step "安装系统依赖"

    $deps = @(
        @{ Check = "nvim";   WingetId = "Neovim.Neovim";           Scoop = "neovim"     },
        @{ Check = "git";    WingetId = "Git.Git";                  Scoop = "git"        },
        @{ Check = "rg";     WingetId = "BurntSushi.ripgrep.MSVC";  Scoop = "ripgrep"    },
        @{ Check = "fd";     WingetId = "sharkdp.fd";               Scoop = "fd"         },
        @{ Check = "node";   WingetId = "OpenJS.NodeJS.LTS";        Scoop = "nodejs-lts" },
        @{ Check = "python"; WingetId = "Python.Python.3.12";       Scoop = "python"     }
    )

    foreach ($dep in $deps) {
        if (Get-Command $dep.Check -ErrorAction SilentlyContinue) {
            Log-Ok "$($dep.Check) 已存在"
        } else {
            if ($DryRun) {
                Log-Info "DRY: 安装 $($dep.Check)"
            } else {
                Log-Info "安装 $($dep.Check) ..."
                Install-Pkg -WingetId $dep.WingetId -ScoopName $dep.Scoop
            }
        }
    }
}

# -- 安装 Nerd Font --
function Install-NerdFont {
    Log-Step "安装 Nerd Font"
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $marker  = Join-Path $fontDir ".jb-mono-nf-installed"
    if (Test-Path $marker) {
        Log-Ok "Nerd Font 已安装"; return
    }

    if ($DryRun) { Log-Info "DRY: install JetBrainsMono Nerd Font"; return }

    # scoop 有 nerd-fonts bucket
    $mgr = Get-PkgManager
    if ($mgr -eq "scoop") {
        scoop bucket add nerd-fonts 2>$null
        scoop install JetBrainsMono-NF 2>$null
        if ($LASTEXITCODE -eq 0) {
            if (-not (Test-Path $fontDir)) { New-Item $fontDir -ItemType Directory -Force | Out-Null }
            New-Item $marker -ItemType File -Force | Out-Null
            Log-Ok "Nerd Font 安装完成 (scoop)"; return
        }
    }

    # 手动下载安装
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    $tmp = Join-Path $env:TEMP "jb-nf.zip"
    $extractDir = Join-Path $env:TEMP "jb-nf"
    try {
        Log-Info "下载 JetBrainsMono Nerd Font ..."
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
        Expand-Archive -Path $tmp -DestinationPath $extractDir -Force
        if (-not (Test-Path $fontDir)) { New-Item $fontDir -ItemType Directory -Force | Out-Null }
        Get-ChildItem "$extractDir\*.ttf" | ForEach-Object {
            Copy-Item $_.FullName $fontDir -Force
        }
        New-Item $marker -ItemType File -Force | Out-Null
        Log-Ok "Nerd Font 安装完成"
    } catch {
        Log-Warn "Nerd Font 下载失败，跳过 (可手动安装)"
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# -- 安装 Neovide --
function Install-Neovide {
    Log-Step "安装 Neovide GUI"
    if (Get-Command neovide -ErrorAction SilentlyContinue) {
        Log-Ok "Neovide 已存在"; return
    }
    if ($DryRun) { Log-Info "DRY: install neovide"; return }

    Install-Pkg -WingetId "Neovide.Neovide" -ScoopName "neovide"
    if (Get-Command neovide -ErrorAction SilentlyContinue) {
        Log-Ok "Neovide 安装完成"
    } else {
        Log-Warn "Neovide 安装失败，可手动从 https://neovide.dev 下载"
    }
}

# -- 克隆 LazyVim starter --
function Install-LazyVimStarter {
    Log-Step "克隆 LazyVim starter"
    if ($DryRun) { Log-Info "DRY: git clone LazyVim/starter -> $NvimConfig"; return }

    if (Test-Path (Join-Path $NvimConfig "init.lua")) {
        Log-Info "已存在 $NvimConfig\init.lua，跳过 clone"
    } else {
        $parent = Split-Path $NvimConfig -Parent
        if (-not (Test-Path $parent)) { New-Item $parent -ItemType Directory -Force | Out-Null }
        git clone --depth=1 https://github.com/LazyVim/starter $NvimConfig
        Remove-Item (Join-Path $NvimConfig ".git") -Recurse -Force -ErrorAction SilentlyContinue
        Log-Ok "LazyVim starter 已克隆"
    }
}

# -- 覆盖模板 --
function Copy-Templates {
    Log-Step "覆盖 templates/"
    if ($DryRun) { Log-Info "DRY: copy templates/ -> $NvimConfig"; return }

    $mappings = @(
        @{ Src = "lua";      Dst = "lua"      },
        @{ Src = "snippets"; Dst = "snippets" },
        @{ Src = "after";    Dst = "after"    }
    )

    foreach ($m in $mappings) {
        $src = Join-Path $TemplatesDir $m.Src
        $dst = Join-Path $NvimConfig $m.Dst
        if (Test-Path $src) {
            if (-not (Test-Path $dst)) { New-Item $dst -ItemType Directory -Force | Out-Null }
            Copy-Item "$src\*" $dst -Recurse -Force
        }
    }

    $cheatsheet = Join-Path $TemplatesDir "CHEATSHEET.md"
    if (Test-Path $cheatsheet) {
        Copy-Item $cheatsheet (Join-Path $NvimConfig "CHEATSHEET.md") -Force
    }
    Log-Ok "templates/ 已覆盖到 $NvimConfig"
}

# -- Lazy sync --
function Invoke-LazySync {
    Log-Step "headless Lazy sync"
    if ($DryRun) { Log-Info "DRY: nvim --headless +Lazy! sync +qa"; return }
    if ($Minimal) { Log-Info "minimal 模式：跳过 Lazy sync"; return }

    try {
        nvim --headless "+Lazy! sync" +qa 2>&1 | Select-Object -Last 5
    } catch {
        Log-Warn "Lazy sync 出错，可手动重跑: nvim 启动后执行 :Lazy sync"
    }
}

# -- 主流程 --

# 处理卸载
if ($Uninstall) {
    Uninstall-All
    exit 0
}

# 处理回滚
if ($Restore) {
    Restore-NvimConfig -Date $Restore
    exit 0
}

# 正常安装流程
Install-SystemDeps
Install-NerdFont

if ($Gui) { Install-Neovide }

Log-Step "备份现有配置"
if ($DryRun) { Log-Info "DRY: backup" } else { Backup-NvimConfig }

Install-LazyVimStarter
Copy-Templates
Invoke-LazySync

if (-not $NoMason) {
    Log-Step "headless Mason install"
    if ($DryRun) { Log-Info "DRY: nvim --headless +MasonToolsInstall +qa" }
}

Log-Step "完成"
Log-Ok "运行 'nvim' 或 'neovide' 启动。按 <Space>?h 看速查表。"
Write-Host ""
Write-Host "提示：如果终端显示乱码，请将终端字体设置为 JetBrainsMono Nerd Font" -ForegroundColor Yellow

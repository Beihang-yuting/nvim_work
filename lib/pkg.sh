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
      local fdfind_path
      fdfind_path="$(command -v fdfind 2>/dev/null || true)"
      if [ -n "$fdfind_path" ] && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$fdfind_path" /usr/local/bin/fd 2>/dev/null || true
      fi
      ;;
    rhel|fedora)
      sudo dnf groupinstall -y "Development Tools" || log_warn "Development Tools group install failed"
      pkg_install git curl unzip ripgrep fd-find nodejs npm python3 python3-pip cargo make
      ;;
    arch)
      pkg_install git curl unzip base-devel ripgrep fd nodejs npm python python-pip rust make
      ;;
  esac
}

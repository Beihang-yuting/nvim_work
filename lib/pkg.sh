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

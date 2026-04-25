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

#!/usr/bin/env bash
set -euo pipefail

packages=(
  build-essential
  bc
  bison
  flex
  libssl-dev
  libelf-dev
  xz-utils
  curl
  gcc-aarch64-linux-gnu
)

if [ ! -r /etc/os-release ]; then
  echo "cannot detect Linux distribution; install kernel build dependencies manually" >&2
  exit 1
fi

. /etc/os-release

case "${ID:-}" in
  ubuntu|debian)
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
    ;;
  *)
    echo "unsupported distribution: ${ID:-unknown}" >&2
    echo "install these packages or their equivalents:" >&2
    printf '  %s\n' "${packages[@]}" >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
check-applevf-config.sh

Verify a Linux .config has the built-in options Microagent needs for
Apple VF boot and guest-to-host vsock readiness.

Options:
  --config <path>       Kernel .config path. Defaults to .kernel-build/linux-6.12.22/.config.
  --help                Show help.
USAGE
}

config=".kernel-build/linux-6.12.22/.config"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --config)
      config="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ ! -r "$config" ]; then
  echo "kernel config is not readable: $config" >&2
  exit 1
fi

required=(
  CONFIG_BLK_DEV_INITRD=y
  CONFIG_DEVTMPFS=y
  CONFIG_DEVTMPFS_MOUNT=y
  CONFIG_EXT4_FS=y
  CONFIG_NET=y
  CONFIG_INET=y
  CONFIG_UNIX=y
  CONFIG_VIRTIO=y
  CONFIG_VIRTIO_BLK=y
  CONFIG_VIRTIO_CONSOLE=y
  CONFIG_HW_RANDOM_VIRTIO=y
  CONFIG_VIRTIO_MMIO=y
  CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
  CONFIG_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS_COMMON=y
)

missing=0
for option in "${required[@]}"; do
  if ! grep -qxF "$option" "$config"; then
    echo "missing required config: $option" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "apple-vf kernel config passed: $config"

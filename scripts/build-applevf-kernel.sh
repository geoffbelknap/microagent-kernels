#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
build-applevf-kernel.sh

Build a Linux arm64 kernel for Microagent's Apple VF backend.

Options:
  --version <version>        Linux version. Defaults to 6.12.22.
  --work-dir <dir>           Build work directory. Defaults to .kernel-build.
  --out-dir <dir>            Output directory. Defaults to dist/kernels.
  --jobs <n>                 Parallel build jobs. Defaults to host CPU count.
  --cross-prefix <prefix>    Optional CROSS_COMPILE prefix for cross builds.
  --help                     Show help.
USAGE
}

cpu_count() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
    return
  fi
  getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2
}

host_arch() {
  case "$(uname -m)" in
    arm64|aarch64) echo "arm64" ;;
    *) echo "other" ;;
  esac
}

version="6.12.22"
work_dir=".kernel-build"
out_dir="dist/kernels"
jobs="$(cpu_count)"
cross_prefix=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      version="${2:-}"
      shift 2
      ;;
    --work-dir)
      work_dir="${2:-}"
      shift 2
      ;;
    --out-dir)
      out_dir="${2:-}"
      shift 2
      ;;
    --jobs)
      jobs="${2:-}"
      shift 2
      ;;
    --cross-prefix)
      cross_prefix="${2:-}"
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

if [ -z "$cross_prefix" ] && [ "$(host_arch)" != "arm64" ] && command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
  cross_prefix="aarch64-linux-gnu-"
fi

for tool in curl tar make sha256sum; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing required tool: $tool" >&2
    exit 1
  fi
done

mkdir -p "$work_dir" "$out_dir"

major="${version%%.*}"
archive="linux-$version.tar.xz"
source_dir="$work_dir/linux-$version"
archive_path="$work_dir/$archive"
url="https://cdn.kernel.org/pub/linux/kernel/v$major.x/$archive"

if [ ! -f "$archive_path" ]; then
  curl -fL -o "$archive_path" "$url"
fi

if [ ! -d "$source_dir" ]; then
  tar -C "$work_dir" -xf "$archive_path"
fi

make_args=(
  "ARCH=arm64"
)
if [ -n "$cross_prefix" ]; then
  make_args+=("CROSS_COMPILE=$cross_prefix")
fi

make -C "$source_dir" "${make_args[@]}" defconfig

config="$source_dir/scripts/config"
kernel_config="$source_dir/.config"
"$config" --file "$kernel_config" --enable BLK_DEV_INITRD
"$config" --file "$kernel_config" --enable DEVTMPFS
"$config" --file "$kernel_config" --enable DEVTMPFS_MOUNT
"$config" --file "$kernel_config" --enable EXT4_FS
"$config" --file "$kernel_config" --enable NET
"$config" --file "$kernel_config" --enable INET
"$config" --file "$kernel_config" --enable UNIX
"$config" --file "$kernel_config" --enable PCI
"$config" --file "$kernel_config" --enable PCI_HOST_GENERIC
"$config" --file "$kernel_config" --enable VIRTIO
"$config" --file "$kernel_config" --enable VIRTIO_BLK
"$config" --file "$kernel_config" --enable VIRTIO_CONSOLE
"$config" --file "$kernel_config" --enable HW_RANDOM_VIRTIO
"$config" --file "$kernel_config" --enable VIRTIO_PCI
"$config" --file "$kernel_config" --enable VIRTIO_MMIO
"$config" --file "$kernel_config" --enable VIRTIO_MMIO_CMDLINE_DEVICES
"$config" --file "$kernel_config" --enable VSOCKETS
"$config" --file "$kernel_config" --enable VIRTIO_VSOCKETS
"$config" --file "$kernel_config" --enable VIRTIO_VSOCKETS_COMMON
"$config" --file "$kernel_config" --disable DEBUG_INFO

make -C "$source_dir" "${make_args[@]}" olddefconfig
make -C "$source_dir" "${make_args[@]}" "-j$jobs" Image

artifact="$out_dir/microagent-kernel-$version-apple-vf-arm64"
cp "$source_dir/arch/arm64/boot/Image" "$artifact"
sha256sum "$artifact" >"$artifact.sha256"

echo "$artifact"
cat "$artifact.sha256"

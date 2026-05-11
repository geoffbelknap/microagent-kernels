#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
build-hyperv-kernel.sh

Build a Linux amd64 kernel for Microagent's Windows Hyper-V backend.

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
  "ARCH=x86"
)
if [ -n "$cross_prefix" ]; then
  make_args+=("CROSS_COMPILE=$cross_prefix")
fi

make -C "$source_dir" "${make_args[@]}" x86_64_defconfig

config="$source_dir/scripts/config"
kernel_config="$source_dir/.config"
"$config" --file "$kernel_config" --enable BLK_DEV_INITRD
"$config" --file "$kernel_config" --enable DEVTMPFS
"$config" --file "$kernel_config" --enable DEVTMPFS_MOUNT
"$config" --file "$kernel_config" --enable TMPFS
"$config" --file "$kernel_config" --enable PROC_FS
"$config" --file "$kernel_config" --enable SYSFS
"$config" --file "$kernel_config" --enable EXT4_FS
"$config" --file "$kernel_config" --enable SCSI
"$config" --file "$kernel_config" --enable BLK_DEV_SD
"$config" --file "$kernel_config" --enable NET
"$config" --file "$kernel_config" --enable INET
"$config" --file "$kernel_config" --enable UNIX
"$config" --file "$kernel_config" --enable HYPERV
"$config" --file "$kernel_config" --enable HYPERV_STORAGE
"$config" --file "$kernel_config" --enable HYPERV_UTILS
"$config" --file "$kernel_config" --enable HYPERV_BALLOON
"$config" --file "$kernel_config" --enable VSOCKETS
"$config" --file "$kernel_config" --enable HYPERV_VSOCKETS
"$config" --file "$kernel_config" --enable SERIAL_8250
"$config" --file "$kernel_config" --enable SERIAL_8250_CONSOLE
"$config" --file "$kernel_config" --enable SERIAL_CORE_CONSOLE
"$config" --file "$kernel_config" --disable DEBUG_INFO

make -C "$source_dir" "${make_args[@]}" olddefconfig
make -C "$source_dir" "${make_args[@]}" "-j$jobs" bzImage

artifact="$out_dir/microagent-kernel-$version-windows-hyperv-amd64"
cp "$source_dir/arch/x86/boot/bzImage" "$artifact"
sha256sum "$artifact" >"$artifact.sha256"

echo "$artifact"
cat "$artifact.sha256"

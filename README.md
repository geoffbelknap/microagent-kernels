# microagent-kernels

Curated Linux kernels for Microagent.

This repo builds and releases the kernel images that `microagent` installs
by default. The toolchain for using Microagent stays in `microagent`; this
repo owns kernel configs, build scripts, checksums, and release notes.

## Build

Build an amd64 Firecracker kernel on a Linux host:

```sh
make deps
make kernel-amd64
make check-kernel-config-amd64
```

Build an arm64 Apple VF kernel on a Linux host:

```sh
make deps
make kernel-applevf-arm64
make check-applevf-config-arm64
```

Build an amd64 Windows Hyper-V kernel on a Linux host. WSL is acceptable for
building this kernel; the Microagent Windows Hyper-V runtime does not use WSL.

```sh
make deps
make kernel-hyperv-amd64
make check-hyperv-config-amd64
```

The build writes:

```text
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
dist/kernels/microagent-kernel-6.12.22-apple-vf-arm64
dist/kernels/microagent-kernel-6.12.22-apple-vf-arm64.sha256
dist/kernels/microagent-kernel-6.12.22-windows-hyperv-amd64
dist/kernels/microagent-kernel-6.12.22-windows-hyperv-amd64.sha256
```

Build artifacts are not committed. Releases should attach the kernel image and
its SHA-256 file.

The config checks verify each built kernel has backend boot-critical options
such as block storage, vsock, ext4, and console support built in.

The full KVM boot smoke lives in `microagent`:

```sh
make smoke-firecracker
```

The Apple VF vsock diagnostic smoke also lives in `microagent`:

```sh
make smoke-applevf-vsock
```

For local Windows Hyper-V testing, copy the built kernel to the Microagent
local kernel override path:

```powershell
C:\Users\geoff\.microagent\kernels\windows-hyperv\amd64\Image
```

From WSL, that copy step is:

```sh
mkdir -p /mnt/c/Users/geoff/.microagent/kernels/windows-hyperv/amd64
cp dist/kernels/microagent-kernel-*-windows-hyperv-amd64 /mnt/c/Users/geoff/.microagent/kernels/windows-hyperv/amd64/Image
```

`kernels-6.1.155-r2` is the first boot-proven Firecracker amd64 kernel release
for `microagent v0.1.22`. Its SHA-256 is:

```text
4bbe8b2fd19f78fea4bf02d52a67482227a896c90a63f272b6a084fa46a416c0
```

## Requirements

`make deps` installs the host packages needed to build Linux kernels on Ubuntu
and Debian.

Cross-builds need the matching cross compiler and should pass
`--cross-prefix`. On Debian and Ubuntu, `make deps` installs the arm64 cross
compiler used by the Apple VF build.

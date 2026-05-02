# microagent-kernels

Curated Linux kernels for Microagent.

This repo builds and releases the kernel images that `microagent-kit` installs
by default. The toolchain for using Microagent stays in `microagent-kit`; this
repo owns kernel configs, build scripts, checksums, and release notes.

## Build

Build an amd64 Firecracker kernel on a Linux host:

```sh
make deps
make kernel-amd64
make check-kernel-config-amd64
```

The build writes:

```text
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
```

Build artifacts are not committed. Releases should attach the kernel image and
its SHA-256 file.

The config check verifies the built kernel has Firecracker boot-critical
options such as virtio-mmio, virtio block, vsock, ext4, and serial console
support built in.

The full KVM boot smoke lives in `microagent-kit`:

```sh
make smoke-firecracker
```

`kernels-6.1.155-r2` is the first boot-proven Firecracker amd64 kernel release
for `microagent-kit v0.1.22`. Its SHA-256 is:

```text
4bbe8b2fd19f78fea4bf02d52a67482227a896c90a63f272b6a084fa46a416c0
```

## Requirements

`make deps` installs the host packages needed to build Linux kernels on Ubuntu
and Debian.

Cross-builds need the matching cross compiler and should pass
`--cross-prefix`.

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
```

The build writes:

```text
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
```

Build artifacts are not committed. Releases should attach the kernel image and
its SHA-256 file.

## Requirements

`make deps` installs the host packages needed to build Linux kernels on Ubuntu
and Debian.

Cross-builds need the matching cross compiler and should pass
`--cross-prefix`.

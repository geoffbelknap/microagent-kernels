# microagent-kernels

Curated Linux kernels for Microagent.

This repo builds and releases the kernel images that `microagent-kit` installs
by default. The toolchain for using Microagent stays in `microagent-kit`; this
repo owns kernel configs, build scripts, checksums, and release notes.

## Build

Build an amd64 Firecracker kernel on a Linux host:

```sh
scripts/build-firecracker-kernel.sh --arch amd64
```

The build writes:

```text
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64
dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
```

Build artifacts are not committed. Releases should attach the kernel image and
its SHA-256 file.

## Requirements

Install the host packages needed to build Linux kernels. On Ubuntu:

```sh
sudo apt-get update
sudo apt-get install -y build-essential bc bison flex libssl-dev libelf-dev xz-utils curl
```

Cross-builds need the matching cross compiler and should pass
`--cross-prefix`.

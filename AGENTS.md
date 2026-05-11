# microagent-kernels

This repo builds curated Linux kernels for Microagent.

## Scope

- Keep build scripts, kernel configs, checksums, and release notes here.
- Do not add Microagent CLI/runtime code here.
- Do not commit built kernels, Linux source trees, or build directories.
- Release artifacts should be pinned by SHA-256 and consumed by `microagent`.

## Build Rules

- Prefer native Linux builds for the target architecture.
- Avoid Docker, Podman, and containerized build assumptions.
- Keep scripts readable and explicit. Do not hide required host dependencies.
- Build outputs belong under `dist/`.
- Temporary kernel source trees belong under `.kernel-build/`.

## Public Boundary

This repo is intended to be public once the kernel build path is proven. Keep
docs focused on Microagent kernels and avoid references to private Agency work.

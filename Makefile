.PHONY: deps kernel-amd64 kernel-arm64 check-kernel-config-amd64 release-check clean

deps:
	scripts/install-build-deps.sh

kernel-amd64:
	scripts/build-firecracker-kernel.sh --arch amd64

kernel-arm64:
	scripts/build-firecracker-kernel.sh --arch arm64

check-kernel-config-amd64:
	scripts/check-firecracker-config.sh --config .kernel-build/linux-6.1.155/.config

release-check: kernel-amd64 check-kernel-config-amd64
	cat dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
	file dist/kernels/microagent-kernel-6.1.155-firecracker-amd64

clean:
	rm -rf .kernel-build dist

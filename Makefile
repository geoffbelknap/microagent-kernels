.PHONY: deps kernel-amd64 kernel-arm64 check-kernel-config-amd64 clean

deps:
	scripts/install-build-deps.sh

kernel-amd64:
	scripts/build-firecracker-kernel.sh --arch amd64

kernel-arm64:
	scripts/build-firecracker-kernel.sh --arch arm64

check-kernel-config-amd64:
	scripts/check-firecracker-config.sh --config .kernel-build/linux-6.1.155/.config

clean:
	rm -rf .kernel-build dist

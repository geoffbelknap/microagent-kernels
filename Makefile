.PHONY: deps kernel-amd64 kernel-arm64 kernel-applevf-arm64 kernel-hyperv-amd64 check-kernel-config-amd64 check-applevf-config-arm64 check-hyperv-config-amd64 release-check release-check-hyperv-amd64 clean

deps:
	scripts/install-build-deps.sh

kernel-amd64:
	scripts/build-firecracker-kernel.sh --arch amd64

kernel-arm64:
	scripts/build-firecracker-kernel.sh --arch arm64

kernel-applevf-arm64:
	scripts/build-applevf-kernel.sh

kernel-hyperv-amd64:
	scripts/build-hyperv-kernel.sh

check-kernel-config-amd64:
	scripts/check-firecracker-config.sh --config .kernel-build/linux-6.1.155/.config

check-applevf-config-arm64:
	scripts/check-applevf-config.sh --config .kernel-build/linux-6.12.22/.config

check-hyperv-config-amd64:
	scripts/check-hyperv-config.sh --config .kernel-build/linux-6.12.22/.config

release-check: kernel-amd64 check-kernel-config-amd64
	cat dist/kernels/microagent-kernel-6.1.155-firecracker-amd64.sha256
	file dist/kernels/microagent-kernel-6.1.155-firecracker-amd64

release-check-hyperv-amd64: kernel-hyperv-amd64 check-hyperv-config-amd64
	cat dist/kernels/microagent-kernel-6.12.22-windows-hyperv-amd64.sha256
	file dist/kernels/microagent-kernel-6.12.22-windows-hyperv-amd64

clean:
	rm -rf .kernel-build dist

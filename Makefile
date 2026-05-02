.PHONY: deps kernel-amd64 kernel-arm64 clean

deps:
	scripts/install-build-deps.sh

kernel-amd64:
	scripts/build-firecracker-kernel.sh --arch amd64

kernel-arm64:
	scripts/build-firecracker-kernel.sh --arch arm64

clean:
	rm -rf .kernel-build dist

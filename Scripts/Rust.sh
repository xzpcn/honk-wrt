#!/bin/bash
#honk所需的Rust编译环境：工具链与bpf-linker版本均取自honk源码内的官方锁定
set -e

HONK_SRC="${HONK_SRC:-$GITHUB_WORKSPACE/$WRT_DIR/package/honk/src}"

if [ ! -f "$HONK_SRC/rust-toolchain.toml" ]; then
	echo "honk source not found: $HONK_SRC"
	exit 1
fi

STABLE=$(grep -oP '^channel\s*=\s*"\K[^"]+' "$HONK_SRC/rust-toolchain.toml")
EBPF=$(grep -oP '^channel\s*=\s*"\K[^"]+' "$HONK_SRC/crates/honk-ebpf/rust-toolchain.toml")
source "$HONK_SRC/.github/ci/pins.env"

export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

if ! command -v rustup >/dev/null 2>&1; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none --profile minimal
fi
export PATH="$CARGO_HOME/bin:$PATH"

#honk-core交叉编译（stable+musl目标），eBPF对象（nightly+rust-src）
rustup toolchain install "$STABLE" --profile minimal --component rustfmt,clippy
rustup target add aarch64-unknown-linux-musl x86_64-unknown-linux-musl --toolchain "$STABLE"
rustup toolchain install "$EBPF" --profile minimal --component rust-src,llvm-tools
rustup default "$STABLE"

#eBPF链接器，预编译二进制，版本与SHA256由pins.env锁定
if ! bpf-linker --version 2>/dev/null | grep -q "$BPF_LINKER_VERSION"; then
	curl -fsSL --retry 3 -o /tmp/bpf-linker.tar.zst \
		"https://github.com/aya-rs/bpf-linker/releases/download/v$BPF_LINKER_VERSION/bpf-linker-x86_64-unknown-linux-musl.tar.zst"
	echo "$BPF_LINKER_SHA256  /tmp/bpf-linker.tar.zst" | sha256sum -c -
	zstd -dc /tmp/bpf-linker.tar.zst | tar -xf - -C "$CARGO_HOME/bin"
	rm -f /tmp/bpf-linker.tar.zst
fi
bpf-linker --version

#GitHub Actions跨步骤环境变量
if [ -n "$GITHUB_PATH" ]; then
	echo "$CARGO_HOME/bin" >> "$GITHUB_PATH"
	echo "CARGO_HOME=$CARGO_HOME" >> "$GITHUB_ENV"
	echo "RUSTUP_HOME=$RUSTUP_HOME" >> "$GITHUB_ENV"
fi

echo "Rust environment ready: stable=$STABLE ebpf=$EBPF bpf-linker=$BPF_LINKER_VERSION"
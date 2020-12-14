#!/usr/bin/env bash

# rustup (Rust toolchain installer) completion

if _binary_exists rustup; then
	eval "$(rustup completions bash)"
fi

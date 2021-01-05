#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096

# rustup (Rust toolchain installer) completion

if _binary_exists rustup; then
	eval "$(rustup completions bash)"
fi

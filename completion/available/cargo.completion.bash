# shellcheck shell=bash
# cargo (Rust package manager) completion

if _binary_exists rustup && _binary_exists cargo; then
	eval "$(rustup completions bash cargo)"
fi

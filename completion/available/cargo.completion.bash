#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096
# cargo (Rust package manager) completion

if _binary_exists rustup && _binary_exists cargo; then
	eval "$(rustup completions bash cargo)"
fi

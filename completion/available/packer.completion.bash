#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096
cite "about-completion"
about-completion "packer completion"

if _binary_exists packer; then
	complete -C packer packer
fi

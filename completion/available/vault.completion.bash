#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096
cite "about-completion"
about-completion "vault completion"

if _binary_exists vault; then
	complete -C vault vault
fi

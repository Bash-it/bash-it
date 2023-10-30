# shellcheck shell=bash
cite "about-completion"
about-completion "packer completion"

if _binary_exists packer; then
	complete -C packer packer
fi

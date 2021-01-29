# shellcheck shell=bash
cite "about-completion"
about-completion "vault completion"

if _binary_exists vault; then
	complete -C vault vault
fi

# shellcheck shell=bash
cite "about-completion"
about-completion "Hashicorp consul completion"

if _command_exists consul; then
	complete -C "$(which consul)" consul
fi

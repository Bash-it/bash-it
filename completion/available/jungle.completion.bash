# shellcheck shell=bash
cite "about-completion"
about-completion "jungle(AWS cli tool) completion"

if _command_exists jungle; then
	eval "$(_JUNGLE_COMPLETE=source jungle)"
fi

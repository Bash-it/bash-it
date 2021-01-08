# shellcheck shell=bash
# pipx completion

if _command_exists register-python-argcomplete && _command_exists pipx; then
	eval "$(register-python-argcomplete pipx)"
fi

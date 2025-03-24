# shellcheck shell=bash
# shellcheck disable=SC1090

if test -s "${BASH_IT?}/vendor/github.com/gaelicWizard/bash-progcomp/defaults.completion.bash"; then
	# shellcheck disable=SC1090
	source "$_"
fi

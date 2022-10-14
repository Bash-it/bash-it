# shellcheck shell=bash

if test -s "${BASH_IT?}/vendor/github.com/gaelicWizard/bash-progcomp/defaults.completion.bash"; then
	source "$_"
fi

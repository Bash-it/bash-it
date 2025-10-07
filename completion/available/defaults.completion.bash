# shellcheck shell=bash
# shellcheck disable=SC1090

if [[ -s "${BASH_IT?}/vendor/github.com/gaelicWizard/bash-progcomp/defaults.completion.bash" ]]; then
	# shellcheck source-path=SCRIPTDIR/../../vendor/github.com/gaelicWizard/bash-progcomp
	source "${BASH_IT?}/vendor/github.com/gaelicWizard/bash-progcomp/defaults.completion.bash"
fi

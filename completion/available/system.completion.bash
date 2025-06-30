# shellcheck shell=bash
#
# Loads the system's Bash completion modules.
# If Homebrew is installed (OS X), it's Bash completion modules are loaded.

# Load before other completions
# BASH_IT_LOAD_PRIORITY: 325

# Bash-completion is too large and complex to expect to handle unbound variables throughout the whole codebase.
if shopt -qo nounset; then
	__bash_it_restore_nounset=true
	shopt -uo nounset
else
	__bash_it_restore_nounset=false
fi

# shellcheck disable=SC1090 disable=SC1091
if [[ -r "${BASH_COMPLETION:-}" ]]; then
	source "${BASH_COMPLETION}"
elif [[ -r /etc/bash_completion ]]; then
	source /etc/bash_completion
# Some distribution makes use of a profile.d script to import completion.
elif [[ -r /etc/profile.d/bash_completion.sh ]]; then
	source /etc/profile.d/bash_completion.sh
elif _bash_it_homebrew_check; then
	: "${BASH_COMPLETION_COMPAT_DIR:=${BASH_IT_HOMEBREW_PREFIX}/etc/bash_completion.d}"
	case "${BASH_VERSION}" in
		1* | 2* | 3.0* | 3.1*)
			_log_warning "Cannot load completion due to version of shell. Are you using Bash 3.2+?"
			;;
		3.2* | 4.0* | 4.1*)
			# Import version 1.x of bash-completion, if installed.
			BASH_COMPLETION="${BASH_IT_HOMEBREW_PREFIX}/opt/bash-completion@1/etc/bash_completion"
			if [[ -r "$BASH_COMPLETION" ]]; then
				source "$BASH_COMPLETION"
			else
				unset BASH_COMPLETION
			fi
			;;
		4.2* | 5* | *)
			# homebrew/versions/bash-completion2 (required for projects.completion.bash) is installed to this path
			if [[ -r "${BASH_IT_HOMEBREW_PREFIX}/opt/bash-completion@2/etc/profile.d/bash_completion.sh" ]]; then
				source "${BASH_IT_HOMEBREW_PREFIX}/opt/bash-completion@2/etc/profile.d/bash_completion.sh"
			fi
			;;
	esac
fi

if [[ ${__bash_it_restore_nounset:-false} == "true" ]]; then
	shopt -so nounset
fi
unset __bash_it_restore_nounset

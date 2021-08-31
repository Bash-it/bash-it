#!/usr/bin/env bash
#
# Loads the system's Bash completion modules.
# If Homebrew is installed (OS X), it's Bash completion modules are loaded.

if shopt -qo nounset
then # Bash-completion is too large and complex to expect to handle unbound variables throughout the whole codebase.
	BASH_IT_RESTORE_NOUNSET=true
	shopt -uo nounset
else
	BASH_IT_RESTORE_NOUNSET=false
fi

if [[ -r "${BASH_COMPLETION:-}" ]] ; then
	source "${BASH_COMPLETION}"
elif [[ -r /etc/bash_completion ]] ; then
  # shellcheck disable=SC1091
  source /etc/bash_completion

# Some distribution makes use of a profile.d script to import completion.
elif [[ -r /etc/profile.d/bash_completion.sh ]] ; then
  # shellcheck disable=SC1091
  source /etc/profile.d/bash_completion.sh

elif _bash_it_homebrew_check
then
  # homebrew/versions/bash-completion2 (required for projects.completion.bash) is installed to this path
  if [[ -r "$BASH_IT_HOMEBREW_PREFIX"/etc/profile.d/bash_completion.sh ]] ; then
    # shellcheck disable=SC1090
    source "$BASH_IT_HOMEBREW_PREFIX"/etc/profile.d/bash_completion.sh
  fi
fi

if $BASH_IT_RESTORE_NOUNSET
then
	shopt -so nounset
fi
unset BASH_IT_RESTORE_NOUNSET

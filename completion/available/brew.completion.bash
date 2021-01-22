# shellcheck shell=bash
cite "about-completion"
about-completion "brew completion"

# Load late to make sure `system` completion loads first
# BASH_IT_LOAD_PRIORITY: 375

if [[ "$(uname -s)" != 'Darwin' ]]; then
	_log_warning "unsupported operating system - only 'Darwin' is supported"
	return 0
fi

# Make sure brew is installed
_command_exists brew || return 0

BREW_PREFIX=${BREW_PREFIX:-$(brew --prefix)}

if [[ -r "$BREW_PREFIX"/etc/bash_completion.d/brew ]]; then
	# shellcheck disable=1090
	source "$BREW_PREFIX"/etc/bash_completion.d/brew

elif [[ -r "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh ]]; then
	# shellcheck disable=1090
	source "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh

elif [[ -f "$BREW_PREFIX"/completions/bash/brew ]]; then
	# For the git-clone based installation, see here for more info:
	# https://github.com/Bash-it/bash-it/issues/1458
	# https://docs.brew.sh/Shell-Completion
	# shellcheck disable=1090
	source "$BREW_PREFIX"/completions/bash/brew
fi

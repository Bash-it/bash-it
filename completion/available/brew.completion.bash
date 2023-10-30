# shellcheck shell=bash
cite "about-completion"
about-completion "brew completion"

# Load late to make sure `system` completion loads first
# BASH_IT_LOAD_PRIORITY: 375

if [[ "$OSTYPE" != 'darwin'* ]]; then
	_log_warning "unsupported operating system - only 'Darwin' is supported"
	return 0
fi

# Make sure brew is installed
_bash_it_homebrew_check || return 0

if [[ -r "$BASH_IT_HOMEBREW_PREFIX/etc/bash_completion.d/brew" ]]; then
	# shellcheck disable=1090,1091
	source "$BASH_IT_HOMEBREW_PREFIX/etc/bash_completion.d/brew"

elif [[ -r "$BASH_IT_HOMEBREW_PREFIX/Library/Contributions/brew_bash_completion.sh" ]]; then
	# shellcheck disable=1090,1091
	source "$BASH_IT_HOMEBREW_PREFIX/Library/Contributions/brew_bash_completion.sh"

elif [[ -f "$BASH_IT_HOMEBREW_PREFIX/completions/bash/brew" ]]; then
	# For the git-clone based installation, see here for more info:
	# https://github.com/Bash-it/bash-it/issues/1458
	# https://docs.brew.sh/Shell-Completion
	# shellcheck disable=1090,1091
	source "$BASH_IT_HOMEBREW_PREFIX/completions/bash/brew"
fi

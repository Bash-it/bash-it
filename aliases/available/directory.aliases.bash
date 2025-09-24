# shellcheck shell=bash
about-alias 'Shortcuts for directory commands: ls, cd, &c.'

if command ls --color -d . &> /dev/null; then
	alias ls='ls --color=auto'
	# BSD `ls` doesn't need an argument (`-G`) when `$CLICOLOR` is set.
fi

# List directory contents
alias sl=ls
alias la='ls -AF' # Compact view, show hidden
alias ll='ls -Al'
alias l='ls -A'
alias l1='ls -1'
alias lf='ls -F'

# Change directory
alias ..='cd ..'         # Go up one directory
alias cd..='cd ..'       # Common misspelling for going up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias -- -='cd -'        # Go back

# Create or remove directory
alias md='mkdir -p'
alias rd='rmdir'

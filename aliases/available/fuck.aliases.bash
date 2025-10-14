# shellcheck shell=bash
about-alias 'fuck/please to retry last command with sudo'
url "https://github.com/Bash-it/bash-it"

# Play nicely with 'thefuck' plugin
if ! _command_exists fuck; then
	alias fuck='sudo $(fc -ln -1)'
fi
alias please=fuck
alias plz=please
alias fucking=sudo

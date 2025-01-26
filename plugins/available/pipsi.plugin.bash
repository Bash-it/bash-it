# shellcheck shell=bash
cite about-plugin
about-plugin 'load pipsi, if you are using it'

if [[ -f "$HOME/.local/bin/pipsi" ]]; then
	pathmunge ~/.local/bin
fi

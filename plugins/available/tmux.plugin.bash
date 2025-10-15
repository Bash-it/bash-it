# shellcheck shell=bash
# make sure that tmux is launched in 256 color mode

cite about-plugin
about-plugin 'make sure that tmux is launched in 256 color mode'
url "https://github.com/tmux/tmux"

alias tmux="TERM=xterm-256color tmux"

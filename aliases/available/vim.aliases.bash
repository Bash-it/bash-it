# shellcheck shell=bash
about-alias 'vim abbreviations'

alias v='${VISUAL:-vim}'

if ! _command_exists vim; then
	_log_warning "Without 'vim', these aliases just aren't that useful..."
fi
# open the vim help in fullscreen incorporated from
# https://stackoverflow.com/a/4687513
alias vimh='vim -c ":h | only"'

# open vim in new tab is taken from
# http://stackoverflow.com/questions/936501/let-gvim-always-run-a-single-instancek
_command_exists mvim && function mvimt { command mvim --remote-tab-silent "$@" || command mvim "$@"; }
_command_exists gvim && function gvimt { command gvim --remote-tab-silent "$@" || command gvim "$@"; }

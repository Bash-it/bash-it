# shellcheck shell=bash
cite 'about-alias'
about-alias 'vim abbreviations'

if _command_exists vim; then
	alias v='$VIM'
	# open the vim help in fullscreen incorporated from
	# https://stackoverflow.com/a/4687513
	alias vimh='${VIM} -c ":h | only"'
fi

# open vim in new tab is taken from
# http://stackoverflow.com/questions/936501/let-gvim-always-run-a-single-instancek
case $OSTYPE in
	darwin*)
		_command_exists mvim && function mvimt { command mvim --remote-tab-silent "$@" || command mvim "$@"; }
		;;
	*)
		_command_exists gvim && function gvimt { command gvim --remote-tab-silent "$@" || command gvim "$@"; }
		;;
esac

# shellcheck shell=bash
cite 'about-alias'
about-alias 'vim abbreviations'

VIM=$(command -v vim)
GVIM=$(command -v gvim)
MVIM=$(command -v mvim)

if [[ -n $VIM ]]; then
	alias v='$VIM'
	# open the vim help in fullscreen incorporated from
	# https://stackoverflow.com/a/4687513
	alias vimh='${VIM} -c ":h | only"'
fi

# open vim in new tab is taken from
# http://stackoverflow.com/questions/936501/let-gvim-always-run-a-single-instancek
case $OSTYPE in
	darwin*)
		[[ -n $MVIM ]] && function mvimt { command mvim --remote-tab-silent "$@" || command mvim "$@"; }
		;;
	*)
		[[ -n $GVIM ]] && function gvimt { command gvim --remote-tab-silent "$@" || command gvim "$@"; }
		;;
esac

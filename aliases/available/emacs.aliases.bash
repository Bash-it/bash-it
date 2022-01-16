# shellcheck shell=bash
about-alias 'emacs editor'

case $OSTYPE in
	linux*)
		alias em='emacs'
		alias en='emacs -nw'
		alias e='emacsclient -n'
		alias et='emacsclient -t'
		alias ed='emacs --daemon'
		alias E='SUDO_EDITOR=emacsclient sudo -e'
		;;
	darwin*)
		alias em='open -a emacs'
		;;
esac

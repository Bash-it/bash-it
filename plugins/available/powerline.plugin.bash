#!/usr/bin/env bash

cite about-plugin
about-plugin 'enables powerline daemon'

command -v powerline-daemon &>/dev/null || return
powerline-daemon -q

#the following should not be executed if bashit powerline themes in use
case "$BASH_IT_THEME" in
	*powerline*)
		return
		;;
esac
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
bashPowerlineInit=$(python -c \
	"import os; \
	import powerline;\
	print(os.path.join(os.path.dirname(\
	powerline.__file__),\
	'bindings', \
	'bash', \
	'powerline.sh'))")
[ -e $bashPowerlineInit ] || return
. $bashPowerlineInit

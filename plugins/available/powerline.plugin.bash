#!/usr/bin/env bash

cite about-plugin
about-plugin 'enables powerline daemon'

command -v powerline-daemon &>/dev/null || return
powerline-daemon -q
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

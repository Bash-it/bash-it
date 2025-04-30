# shellcheck shell=bash
# shellcheck disable=SC2034

cite about-plugin
about-plugin 'enables powerline daemon'

_command_exists powerline-daemon || return
powerline-daemon -q

#the following should not be executed if bashit powerline themes in use
case "$BASH_IT_THEME" in
	*powerline*)
		return
		;;
esac
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
bashPowerlineInit="$(python -c \
	"import os; \
	import powerline;\
	print(os.path.join(os.path.dirname(\
	powerline.__file__),\
	'bindings', \
	'bash', \
	'powerline.sh'))")"
[ -e "$bashPowerlineInit" ] || return
# shellcheck disable=SC1090
source "$bashPowerlineInit"

# shellcheck shell=bash
# shellcheck disable=SC2034

cite about-plugin
about-plugin 'enables powerline daemon'

if ! _binary_exists powerline-daemon; then
	_log_warning "Unable to locate '$_'."
	return 1
fi

powerline-daemon -q

#the following should not be executed if bashit powerline themes in use
case "$BASH_IT_THEME" in
	*powerline*)
		return
		;;
esac
export POWERLINE_BASH_CONTINUATION=1
export POWERLINE_BASH_SELECT=1
bashPowerlineInit="$(python -c \
	"import os; \
	import powerline;\
	print(os.path.join(os.path.dirname(\
	powerline.__file__),\
	'bindings', \
	'bash', \
	'powerline.sh'))")"

if ! [[ -s ${bashPowerlineInit?} ]]; then
	_log_warning "Failed to initialize 'powerline'."
	return 1
fi

# shellcheck disable=SC1090
source "${bashPowerlineInit?}"

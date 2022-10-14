# shellcheck shell=bash
cite about-plugin
about-plugin 'load ble.sh, the Bash line editor!'

if [[ ${BLE_VERSION-} ]]; then
	_log_warning "ble.sh is already loaded!"
	return
fi

_bash_it_ble_path=${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh
if [[ -f $_bash_it_ble_path ]]; then
	# shellcheck disable=1090
	source "$_bash_it_ble_path" --attach=prompt
else
	_log_error "Could not find ble.sh in $_bash_it_ble_path"
	_log_error "Please install using the following command:"
	_log_error "git clone https://github.com/akinomyoga/ble.sh && make -C ble.sh install"
fi
unset _bash_it_ble_path

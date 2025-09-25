#!/usr/bin/env bash
# bash-it installer

# Show how to use this installer
function _bash-it-install-help() {
	echo -e "\n$0 : Install bash-it"
	echo -e "Usage:\n$0 [arguments] \n"
	echo "Arguments:"
	echo "--help (-h): Display this help message"
	echo "--silent (-s): Install default settings without prompting for input"
	echo "--interactive (-i): Interactively choose plugins"
	echo "--no-modify-config (-n): Do not modify existing config file"
	echo "--append-to-config (-a): Keep existing config file and append bash-it templates at the end"
	echo "--overwrite-backup (-f): Overwrite existing backup"
}

# Interactively enable several things
function _bash-it-install-enable() {
	local file_type single_type enable_func file_name just_the_name RESP
	file_type=$1
	single_type=$(echo "$file_type" | sed -e "s/aliases$/alias/g" | sed -e "s/plugins$/plugin/g")
	enable_func="_enable-$single_type"
	for path in "${BASH_IT?}/${file_type}/available/"[^_]*; do
		file_name="${path##*/}"
		while true; do
			just_the_name="${file_name%".${file_type}.bash"}"
			read -r -e -n 1 -p "Would you like to enable the $just_the_name $file_type? [y/N] " RESP
			case $RESP in
				[yY])
					"$enable_func" "$just_the_name"
					break
					;;
				[nN] | "")
					break
					;;
				*)
					echo -e "${echo_orange:-}Please choose y or n.${echo_normal:-}"
					;;
			esac
		done
	done
}

# Back up existing profile
function _bash-it-install-backup-config() {
	test -w "${HOME?}/${CONFIG_FILE?}" \
		&& cp -aL "${HOME?}/${CONFIG_FILE?}" "${HOME?}/${CONFIG_FILE?}.bak" \
		&& echo -e "${echo_green:-}Your original ${CONFIG_FILE?} has been backed up to ${CONFIG_FILE?}.bak${echo_normal:-}"
}

# Back up existing profile and create new one for bash-it
function _bash-it-install-backup-new() {
	_bash-it-install-backup-config
	sed "s|{{BASH_IT}}|${BASH_IT?}|" "${BASH_IT?}/template/bashrc.template.bash" > "${HOME?}/${CONFIG_FILE?}"
	echo -e "${echo_green:-}Copied the template ${CONFIG_FILE?} into ~/${CONFIG_FILE?}, edit this file to customize bash-it${echo_normal:-}"
}

# Back up existing profile and append bash-it templates at the end
function _bash-it-install-backup-append() {
	_bash-it-install-backup-config
	(sed "s|{{BASH_IT}}|${BASH_IT?}|" "${BASH_IT?}/template/bashrc.template.bash" | tail -n +2) >> "${HOME?}/${CONFIG_FILE?}"
	echo -e "${echo_green:-}Bash-it template has been added to your ${CONFIG_FILE?}${echo_normal:-}"
}

function _bash-it-install-backup-check() {
	if ! [[ -e "${HOME?}/$BACKUP_FILE" ]]; then
		return
	fi
	echo -e "${echo_yellow:-}Backup file already exists. Make sure to backup your .bashrc before running this installation.${echo_normal:-}" >&2

	if [[ -z "${overwrite_backup:-}" ]]; then
		while [[ -z "${silent:-}" ]]; do
			read -e -n 1 -r -p "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$BACKUP_FILE) [y/N] " RESP
			case $RESP in
				[yY])
					overwrite_backup=true
					break
					;;
				[nN] | "")
					break
					;;
				*)
					echo -e "${echo_orange:-}Please choose y or n.${echo_normal:-}"
					;;
			esac
		done
	fi
	if [[ -z "${overwrite_backup:-}" ]]; then
		echo -e "${echo_orange:-}Installation aborted. Please come back soon!${echo_normal:-}"
		if [[ -n "${silent:-}" ]]; then
			echo -e "${echo_orange:-}Use \"-f\" flag to force overwrite of backup.${echo_normal:-}"
		fi
		exit 1
	else
		echo -e "${echo_green:-}Overwriting backup...${echo_normal:-}"
	fi
}

function _bash-it-install-modify-config() {
	_bash-it-install-backup-check

	if [[ -z "${silent:-}" ]]; then
		while [[ -z "${append_to_config:-}" ]]; do
			read -e -n 1 -r -p "Would you like to keep your $CONFIG_FILE and append bash-it templates at the end? [y/N] " choice
			case $choice in
				[yY])
					append_to_config=true
					break
					;;
				[nN] | "")
					break
					;;
				*)
					echo -e "${echo_orange:-}Please choose y or n.${echo_normal:-}"
					;;
			esac
		done
	fi
	if [[ -n "${append_to_config:-}" ]]; then
		# backup/append
		_bash-it-install-backup-append
	else
		# backup/new by default
		_bash-it-install-backup-new
	fi
	_bash-it-install-modify-profile
}

function _bash-it-install-modify-profile() {
	local choice profile_string=$'if [[ $- == *i* && -s ~/.bashrc ]]; then\n\tsource ~/.bashrc\nfi'
	if [[ ! -f ~/.bash_profile ]]; then
		printf '%s\n' "${profile_string}" > ~/.bash_profile
	else
		printf "${echo_yellow:-}%s${echo_normal:-}" "You may need to update your ~/.bash_profile (or ~/.profile) to source your ~/.bashrc:"
		printf '%s\n' "${profile_string}"
	fi
}

for param in "$@"; do
	shift
	case "$param" in
		"--help") set -- "$@" "-h" ;;
		"--silent") set -- "$@" "-s" ;;
		"--interactive") set -- "$@" "-i" ;;
		"--no-modify-config") set -- "$@" "-n" ;;
		"--append-to-config") set -- "$@" "-a" ;;
		"--overwrite-backup") set -- "$@" "-f" ;;
		*) set -- "$@" "$param" ;;
	esac
done

OPTIND=1
while getopts "hsinaf" opt; do
	case "$opt" in
		"h")
			_bash-it-install-help
			exit 0
			;;
		"s") silent=true ;;
		"i") interactive=true ;;
		"n") no_modify_config=true ;;
		"a") append_to_config=true ;;
		"f") overwrite_backup=true ;;
		"?")
			_bash-it-install-help >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

if [[ -n "${silent:-}" && -n "${interactive:-}" ]]; then
	echo -e "${echo_orange:-}Options --silent and --interactive are mutually exclusive. Please choose one or the other.${echo_normal:-}"
	exit 1
fi

if [[ -n "${no_modify_config:-}" && -n "${append_to_config:-}" ]]; then
	echo -e "${echo_orange:-}Options --no-modify-config and --append-to-config are mutually exclusive. Please choose one or the other.${echo_normal:-}"
	exit 1
fi

BASH_IT="$(cd "${BASH_SOURCE%/*}" && pwd)"

CONFIG_FILE=".bashrc"

# overriding CONFIG_FILE:
CONFIG_FILE="${BASH_IT_CONFIG_FILE:-"${CONFIG_FILE}"}"
# create subdir if CONFIG_FILE has subdirectory components
if [[ "${CONFIG_FILE%/*}" != "${CONFIG_FILE}" ]]; then
	mkdir -p "${HOME}/${CONFIG_FILE%/*}"
fi

BACKUP_FILE="${CONFIG_FILE?}.bak"
echo "Installing bash-it"
if [[ -z "${no_modify_config}" ]]; then
	_bash-it-install-modify-config
fi

# Disable auto-reload in case its enabled
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=''
# Load dependencies for enabling components
# shellcheck source-path=SCRIPTPATH/vendor/github.com/erichs/composure
source "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"
cite _about _param _example _group _author _version
# shellcheck source-path=SCRIPTDIR/lib
source "${BASH_IT}/lib/log.bash"
# shellcheck source-path=SCRIPTDIR/lib
source "${BASH_IT?}/lib/utilities.bash"
# shellcheck source-path=SCRIPTDIR/lib
source "${BASH_IT?}/lib/helpers.bash"
# shellcheck source-path=SCRIPTDIR/lib
source "${BASH_IT?}/lib/colors.bash"

if [[ -n ${interactive:-} && -z "${silent:-}" ]]; then
	for type in "aliases" "plugins" "completion"; do
		echo -e "${echo_green:-}Enabling ${type}${echo_normal:-}"
		_bash-it-install-enable "$type"
	done
else
	echo ""
	_bash-it-profile-load "default"
fi

echo ""
echo -e "${echo_green:-}Installation finished successfully! Enjoy bash-it!${echo_normal:-}"
echo -e "${echo_green:-}To start using it, open a new tab or 'source ~/${CONFIG_FILE?}'.${echo_normal:-}"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  bash-it show aliases"
echo "  bash-it show completions"
echo "  bash-it show plugins"
echo ""
echo "To avoid issues and to keep your shell lean, please enable only features you really want to use."
echo "Enabling everything can lead to issues."

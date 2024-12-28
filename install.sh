#!/usr/bin/env bash
# bash-it installer

# Show how to use this installer
function _bash-it_show_usage() {
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

# enable a thing
function _bash-it_load_one() {
	file_type=$1
	file_to_enable=$2
	mkdir -p "$BASH_IT/${file_type}/enabled"

	dest="${BASH_IT}/${file_type}/enabled/${file_to_enable}"
	if [ ! -e "${dest}" ]; then
		ln -sf "../available/${file_to_enable}" "${dest}"
	else
		echo "File ${dest} exists, skipping"
	fi
}

# Interactively enable several things
function _bash-it_load_some() {
	file_type=$1
	single_type=$(echo "$file_type" | sed -e "s/aliases$/alias/g" | sed -e "s/plugins$/plugin/g")
	enable_func="_enable-$single_type"
	[ -d "$BASH_IT/$file_type/enabled" ] || mkdir "$BASH_IT/$file_type/enabled"
	for path in "$BASH_IT/${file_type}/available/"[^_]*; do
		file_name=$(basename "$path")
		while true; do
			just_the_name="${file_name%%.*}"
			read -r -e -n 1 -p "Would you like to enable the $just_the_name $file_type? [y/N] " RESP
			case $RESP in
				[yY])
					$enable_func "$just_the_name"
					break
					;;
				[nN] | "")
					break
					;;
				*)
					echo -e "\033[91mPlease choose y or n.\033[m"
					;;
			esac
		done
	done
}

# Back up existing profile
function _bash-it_backup() {
	test -w "$HOME/$CONFIG_FILE" \
		&& cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" \
		&& echo -e "\033[0;32mYour original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak\033[0m"
}

# Back up existing profile and create new one for bash-it
function _bash-it_backup_new() {
	_bash-it_backup
	sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
	echo -e "\033[0;32mCopied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it\033[0m"
}

# Back up existing profile and append bash-it templates at the end
function _bash-it_backup_append() {
	_bash-it_backup
	(sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
	echo -e "\033[0;32mBash-it template has been added to your $CONFIG_FILE\033[0m"
}

function _bash-it_check_for_backup() {
	if ! [[ -e "$HOME/$BACKUP_FILE" ]]; then
		return
	fi
	echo -e "\033[0;33mBackup file already exists. Make sure to backup your .bashrc before running this installation.\033[0m" >&2

	if [[ -z "${overwrite_backup}" ]]; then
		while [[ -z "${silent}" ]]; do
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
					echo -e "\033[91mPlease choose y or n.\033[m"
					;;
			esac
		done
	fi
	if [[ -z "${overwrite_backup}" ]]; then
		echo -e "\033[91mInstallation aborted. Please come back soon!\033[m"
		if [[ -n "${silent}" ]]; then
			echo -e "\033[91mUse \"-f\" flag to force overwrite of backup.\033[m"
		fi
		exit 1
	else
		echo -e "\033[0;32mOverwriting backup...\033[m"
	fi
}

function _bash-it_modify_config_files() {
	_bash-it_check_for_backup

	if [[ -z "${silent}" ]]; then
		while [[ -z "${append_to_config}" ]]; do
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
					echo -e "\033[91mPlease choose y or n.\033[m"
					;;
			esac
		done
	fi
	if [[ -n "${append_to_config}" ]]; then
		# backup/append
		_bash-it_backup_append
	else
		# backup/new by default
		_bash-it_backup_new
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
			_bash-it_show_usage
			exit 0
			;;
		"s") silent=true ;;
		"i") interactive=true ;;
		"n") no_modify_config=true ;;
		"a") append_to_config=true ;;
		"f") overwrite_backup=true ;;
		"?")
			_bash-it_show_usage >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

if [[ -n "${silent}" && -n "${interactive}" ]]; then
	echo -e "\033[91mOptions --silent and --interactive are mutually exclusive. Please choose one or the other.\033[m"
	exit 1
fi

if [[ -n "${no_modify_config}" && -n "${append_to_config}" ]]; then
	echo -e "\033[91mOptions --no-modify-config and --append-to-config are mutually exclusive. Please choose one or the other.\033[m"
	exit 1
fi

BASH_IT="$(cd "${BASH_SOURCE%/*}" && pwd)"

case $OSTYPE in
	darwin*)
		CONFIG_FILE=.bash_profile
		;;
	*)
		CONFIG_FILE=.bashrc
		;;
esac

# overriding CONFIG_FILE:
CONFIG_FILE="${BASH_IT_CONFIG_FILE:-"${CONFIG_FILE}"}"
# create subdir if CONFIG_FILE has subdirectory components
if [[ "${CONFIG_FILE%/*}" != "${CONFIG_FILE}" ]]; then
	mkdir -p "${HOME}/${CONFIG_FILE%/*}"
fi

BACKUP_FILE=$CONFIG_FILE.bak
echo "Installing bash-it"
if [[ -z "${no_modify_config}" ]]; then
	_bash-it_modify_config_files
fi

# Disable auto-reload in case its enabled
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=''
# Load dependencies for enabling components
# shellcheck disable=SC1090
source "${BASH_IT}"/vendor/github.com/erichs/composure/composure.sh
# shellcheck source=./lib/utilities.bash
source "$BASH_IT/lib/utilities.bash"
# shellcheck source=./lib/log.bash
source "${BASH_IT}/lib/log.bash"
cite _about _param _example _group _author _version
# shellcheck source=./lib/helpers.bash
source "$BASH_IT/lib/helpers.bash"

if [[ -n $interactive && -z "${silent}" ]]; then
	for type in "aliases" "plugins" "completion"; do
		echo -e "\033[0;32mEnabling ${type}\033[0m"
		_bash-it_load_some "$type"
	done
else
	echo ""
	_bash-it-profile-load "default"
fi

echo ""
echo -e "\033[0;32mInstallation finished successfully! Enjoy bash-it!\033[0m"
# shellcheck disable=SC2086
echo -e "\033[0;32mTo start using it, open a new tab or 'source "~/$CONFIG_FILE"'.\033[0m"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  bash-it show aliases"
echo "  bash-it show completions"
echo "  bash-it show plugins"
echo ""
echo "To avoid issues and to keep your shell lean, please enable only features you really want to use."
echo "Enabling everything can lead to issues."

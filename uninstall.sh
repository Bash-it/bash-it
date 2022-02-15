#!/usr/bin/env bash
#
# Since we're uninstalling, avoid depending on any other part of _Bash It_.
# I.e., hard-code colors (avoid `lib/colors.bash`), &c.

: "${BASH_IT:=${HOME?}/.bash_it}"

CONFIG_FILE=".bashrc"
if [[ ! -e ~/.bashrc && -e ~/.bash_profile ]]; then
	# legacy Mac or WSL or just no backup file
	CONFIG_FILE=".bash_profile"
fi

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

BACKUP_FILE=$CONFIG_FILE.bak

if [[ ! -e "${HOME?}/$BACKUP_FILE" ]]; then
	printf '\e[0;33m%s\e[0m\n' "Backup file ~/$BACKUP_FILE not found."

	test -w "${HOME?}/$CONFIG_FILE" \
		&& mv "${HOME?}/$CONFIG_FILE" "${HOME?}/$CONFIG_FILE.uninstall" \
		&& printf '\e[0;32m%s\e[0m\n' "Moved your ~/$CONFIG_FILE to ~/$CONFIG_FILE.uninstall."
else
	test -w "${HOME?}/$BACKUP_FILE" \
		&& cp -a "${HOME?}/$BACKUP_FILE" "${HOME?}/$CONFIG_FILE" \
		&& rm "${HOME?}/$BACKUP_FILE" \
		&& printf '\e[0;32m%s\e[0m\n' "Your original ~/$CONFIG_FILE has been restored."
fi

printf '\n\e[0;32m%s\e[0m\n\n' "Uninstallation finished successfully! Sorry to see you go!"
printf '%s\n' "Final steps to complete the uninstallation:"
printf '\t%s\n' "-> Remove the ${BASH_IT//${HOME?}/\~} folder"
printf '\t%s\n' "-> Open a new shell/tab/terminal"

#!/usr/bin/env bash
: "${BASH_IT:=${HOME?}/.bash_it}"

CONFIG_FILE=".bashrc"
if [[ ! -e ~/.bashrc && -e ~/.bash_profile ]]; then
	# legacy Mac or WSL or just no backup file
	CONFIG_FILE=".bash_profile"
fi

BACKUP_FILE=$CONFIG_FILE.bak

if [[ ! -e "${HOME?}/$BACKUP_FILE" ]]; then
	echo -e "\033[0;33mBackup file ${HOME?}/$BACKUP_FILE not found.\033[0m" >&2

	test -w "${HOME?}/$CONFIG_FILE" \
		&& mv "${HOME?}/$CONFIG_FILE" "${HOME?}/$CONFIG_FILE.uninstall" \
		&& echo -e "\033[0;32mMoved your ${HOME?}/$CONFIG_FILE to ${HOME?}/$CONFIG_FILE.uninstall.\033[0m"
else
	test -w "${HOME?}/$BACKUP_FILE" \
		&& cp -a "${HOME?}/$BACKUP_FILE" "${HOME?}/$CONFIG_FILE" \
		&& rm "${HOME?}/$BACKUP_FILE" \
		&& echo -e "\033[0;32mYour original $CONFIG_FILE has been restored.\033[0m"
fi

echo ""
echo -e "\033[0;32mUninstallation finished successfully! Sorry to see you go!\033[0m"
echo ""
echo "Final steps to complete the uninstallation:"
echo "  -> Remove the $BASH_IT folder"
echo "  -> Open a new shell/tab/terminal"

#!/usr/bin/env bash
#
# Since we're uninstalling, avoid depending on any other part of _Bash It_.
# I.e., hard-code colors (avoid `lib/colors.bash`), &c.

: "${BASH_IT:=${HOME?}/.bash_it}"

if [[ ! -e ~/.bashrc && ! -e ~/.bash_profile && ! -e ~/.bashrc.bak && ! -e ~/.bash_profile.bak ]]; then
	echo "We can't locate your configuration files, so we can't uninstall..."
	return
elif grep -F -q -- BASH_IT ~/.bashrc && grep -F -q -- BASH_IT ~/.bash_profile; then
	echo "We can't figure out if Bash-it is loaded from ~/.bashrc or ~/.bash_profile..."
	return
elif grep -F -q -- BASH_IT ~/.bashrc || [[ -e ~/.bashrc.bak && ! -e ~/.bashrc ]]; then
	CONFIG_FILE=".bashrc"
elif grep -F -q -- BASH_IT ~/.bash_profile || [[ -e ~/.bash_profile.bak && ! -e ~/.bash_profile ]]; then
	CONFIG_FILE=".bash_profile"
else
	echo "Bash-it does not appear to be installed."
	return
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
# possible states:
# - both .bash* /and/ .bash*.bak, /and/ both config reference `$BASH_IT`: no solution
# - both config and bak, but only one references `$BASH_IT`: that one
# - both config, only one bak, but other references `$BASH_IT`: the other one?
# - both config, no bak, with `$BASH_IT` reference: that one
# - one config, no bak, but no `$BASH_IT` reference: wut
# - no config, with bak, with `$BASH_IT`: re-create???
# - no config, no bak: nothing.

BACKUP_FILE=$CONFIG_FILE.bak

if [[ ! -e "${HOME?}/$BACKUP_FILE" ]]; then
	printf '\e[0;33m%s\e[0m\n' "Backup file ~/$BACKUP_FILE not found."

	test -w "${HOME?}/$CONFIG_FILE" \
		&& mv "${HOME?}/$CONFIG_FILE" "${HOME?}/$CONFIG_FILE.uninstall" \
		&& printf '\e[0;32m%s\e[0m\n' "Moved your ~/$CONFIG_FILE to ~/$CONFIG_FILE.uninstall."
else
	# Create a backup of the current config before restoring the old one
	# Use -L to dereference symlinks (for homesick/dotfile managers)
	if [[ -e "${HOME?}/$CONFIG_FILE" ]]; then
		cp -L "${HOME?}/$CONFIG_FILE" "${HOME?}/$CONFIG_FILE.pre-uninstall.bak"
		printf '\e[0;33m%s\e[0m\n' "Current ~/$CONFIG_FILE backed up to ~/$CONFIG_FILE.pre-uninstall.bak"
	fi

	test -w "${HOME?}/$BACKUP_FILE" \
		&& cp -a "${HOME?}/$BACKUP_FILE" "${HOME?}/$CONFIG_FILE" \
		&& rm "${HOME?}/$BACKUP_FILE" \
		&& printf '\e[0;32m%s\e[0m\n' "Your original ~/$CONFIG_FILE has been restored."

	printf '\e[0;33m%s\e[0m\n' "NOTE: If you had made changes since installing Bash-it, they are preserved in ~/$CONFIG_FILE.pre-uninstall.bak"
fi

printf '\n\e[0;32m%s\e[0m\n\n' "Uninstallation finished successfully! Sorry to see you go!"
printf '%s\n' "Final steps to complete the uninstallation:"
printf '\t%s\n' "-> Remove the ${BASH_IT//${HOME?}/\~} folder"
printf '\t%s\n' "-> Open a new shell/tab/terminal"

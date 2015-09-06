#!/bin/bash
#
# -binaryanomaly

cite 'about-alias'
about-alias 'Apt and dpkg aliases for Ubuntu and Debian distros.'

# set apt aliases
function _set_pkg_aliases()
{
	if [ -x $(which apt) ]; then
		alias apts='sudo apt-cache search'
		alias aptshow='sudo apt-cache show'
		alias aptinst='sudo apt-get install -V'
		alias aptupd='sudo apt-get update'
		alias aptupg='sudo apt-get dist-upgrade -V && sudo apt-get autoremove'
		alias aptupgd='sudo apt-get update && sudo apt-get dist-upgrade -V && sudo apt-get autoremove'
		alias aptrm='sudo apt-get remove'
		alias aptpurge='sudo apt-get remove --purge'

		alias chkup='/usr/lib/update-notifier/apt-check -p --human-readable'
		alias chkboot='cat /var/run/reboot-required'

		alias pkgfiles='dpkg --listfiles'
	fi
}

_set_pkg_aliases

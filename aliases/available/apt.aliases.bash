#!/bin/bash
#
# -binaryanomaly

cite 'about-alias'
about-alias 'Apt and dpkg aliases for Ubuntu and Debian distros.'

# set apt aliases
function _set_pkg_aliases()
{
	# Wrapper for sudo if BASHIT_ROOT is non-zero
	if ! ((EUID)) && [ -n $BASHIT_ROOT ]; then BASHIT_USE_ROOT=true; fi

	# Aliases
	if [ -x $(which apt) ]; then
		alias apti="${BASHIT_USE_ROOT:+sudo }apt-get install" # Advanced Packating Tool Install
		alias aptr="${BASHIT_USE_ROOT:+sudo }apt-get remove" # Advanced Packating Tool Remove
		alias apts="${BASHIT_USE_ROOT:+sudo }apt-cache search" # Advanced Packating Tool Search
		alias aptfu="${BASHIT_USE_ROOT:+sudo }apt-get update -y && ${BASHIT_USE_ROOT:+sudo }apt-get upgrade -y && ${BASHIT_USE_ROOT:+sudo }apt-get dist-upgrade -y && ${BASHIT_USE_ROOT:+sudo }apt-get autoremove -y" # Advanced Packaging Tool Full Update/Upgrade
		alias aptar="${BASHIT_USE_ROOT:+sudo }apt-get autoremove -y" # Advanced Packaging Tool Auto Remove
		alias aptiv="${BASHIT_USE_ROOT:+sudo }apt-get install -V" # Advanced Packaging Tool Install Verbose
		alias aptupd="${BASHIT_USE_ROOT:+sudo }apt-get update -y" # Advanced Packaging Tool UPDate
		alias aptli="${OSH_ROOT:+sudo }apt list --installed" # Advanced Packaging Tool List installed

		alias aptupg="${BASHIT_USE_ROOT:+sudo }apt-get dist-upgrade -V"
		alias aptshow='apt-cache show'
		alias aptupgd="${BASHIT_USE_ROOT:+sudo }apt-get update && sudo apt-get dist-upgrade -V && sudo apt-get autoremove"
		alias aptp="${BASHIT_USE_ROOT:+sudo }apt-get remove --purge"#  Advanced Packating Tool Purge

		alias chkup='/usr/lib/update-notifier/apt-check -p --human-readable'
		alias chkboot='cat /var/run/reboot-required'

		alias pkgfiles='dpkg --listfiles'
	fi
}

_set_pkg_aliases

#!/usr/bin/env bash

cite 'about-alias'
about-alias 'Cave frontend for paludis package manager.'

# set apt aliases
function _set_pkg_aliases()
{
	if [ -x $(which cave) ]; then
		if ((EUID)) && [ -n "$BASHIT_ROOT" ]; then BASHIT_USE_ROOT=true; fi
		alias cave="${OSH_ROOT:+sudo }cave"
		alias cr="${OSH_ROOT:+sudo }cave resolve" # Cave Resolve
		alias cui="${OSH_ROOT:+sudo }cave uninstall" # Cave UnInstall
		alias cs="${OSH_ROOT:+sudo }cave show" # Cave Show
		alias cli="${OSH_ROOT:+sudo }cave print-ids --matching '*/*::/'" # Cave List Installed
	fi
}

_set_pkg_aliases

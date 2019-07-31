#!/usr/bin/env bash

cite 'about-alias'
about-alias 'emerge and ebuild aliases for gentoo-based distributions.'

# set apt aliases
function _set_pkg_aliases()
{
	if [ -x $(which emerge) ]; then
		if ((EUID)) && [ -n "$BASHIT_ROOT" ]; then BASHIT_USE_ROOT=true; fi
		# Emerge
		alias em="${BASHIT_USE_ROOT:+sudo }emerge" # Enoch Merge
		alias emfu="${BASHIT_USE_ROOT:+sudo }emerge --sync && emerge -uDUj @world"
		alias es="${BASHIT_USE_ROOT:+sudo }emerge --search" # Enoch Search
		alias er="${BASHIT_USE_ROOT:+sudo }emerge -c" # Enoch Remove
		alias emli="${BASHIT_USE_ROOT:+sudo }eix-installed -a" # Enoch List Installed
		alias eN="${BASHIT_USE_ROOT:+sudo }emerge -C" # Enoch Nuke (force removal of package)
		alias esync="${BASHIT_USE_ROOT:+sudo }emerge --sync" # Enoch SYNC
		# Ebuild
		alias eb="${BASHIT_USE_ROOT:+sudo }ebuild" # Enoch Build
	fi
}

_set_pkg_aliases

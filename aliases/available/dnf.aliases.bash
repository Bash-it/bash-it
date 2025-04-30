# shellcheck shell=bash
about-alias 'dnf aliases for fedora 22+ distros'

if _command_exists dnf; then
	alias dnfp="dnf info"            # Show package information
	alias dnfl="dnf list"            # List packages
	alias dnfli="dnf list installed" # List installed packages
	alias dnfgl="dnf grouplist"      # List package groups
	alias dnfmc="dnf makecache"      # Generate metadata cache
	alias dnfs="dnf search"          # Search package

	alias dnfi="sudo dnf install"       # Install package
	alias dnfr="sudo dnf remove"        # Remove package
	alias dnfu="sudo dnf upgrade"       # Upgrade package
	alias dnfc="sudo dnf clean all"     # Clean cache
	alias dnfri="sudo dnf reinstall"    # Reinstall package
	alias dnfgi="sudo dnf groupinstall" # Install package group
	alias dnfgr="sudo dnf groupremove"  # Remove package group
fi

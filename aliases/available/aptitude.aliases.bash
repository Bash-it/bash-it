# shellcheck shell=bash
#
# -binaryanomaly

cite 'about-alias'
about-alias 'Aptitude and dpkg aliases for Ubuntu and Debian distros.'

# set apt aliases
function _set_pkg_aliases() {
	if _command_exists aptitude; then
		alias apts='aptitude search'
		alias aptshow='aptitude show'
		alias aptinst='sudo aptitude install -V'
		alias aptupd='sudo aptitude update'
		alias aptsupg='sudo aptitude safe-upgrade'
		alias aptupg='sudo apt-get dist-upgrade -V && sudo apt-get autoremove'
		alias aptupgd='sudo apt-get update && sudo apt-get dist-upgrade -V && sudo apt-get autoremove'
		alias aptrm='sudo aptitude remove'
		alias aptpurge='sudo aptitude purge'
		alias aptclean='sudo aptitude clean && sudo aptitude autoclean'
		alias apty='aptitude why'
		alias aptyn='aptitude why-not'

		alias chkup='/usr/lib/update-notifier/apt-check -p --human-readable'
		alias chkboot='cat /var/run/reboot-required'

		alias pkgfiles='dpkg --listfiles'
		alias listinstalled='aptitude search "~i!~M"'
	fi
}

_set_pkg_aliases

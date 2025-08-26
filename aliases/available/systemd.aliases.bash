# shellcheck shell=bash
about-alias 'systemd service'

case $OSTYPE in
	linux*)
		# Improve aliases by bringing the common root `sc|scd` + `sre` for action + `u` for user
		alias sc='systemctl'
		alias scu='systemctl --user'
		alias scdr='systemctl daemon-reload'
		alias scdru='systemctl --user daemon-reload'
		alias scr='systemctl restart'
		alias scru='systemctl --user restart'
		alias sce='systemctl stop'
		alias sceu='systemctl --user stop'
		alias scs='systemctl start'
		alias scsu='systemctl --user start'
		# Keeping previous aliases for a non-breaking change.
		alias scue='sceu'
		alias scus='scsu'
		alias scur='scdru'
		;;
esac

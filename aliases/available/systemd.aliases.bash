cite 'about-alias'
about-alias 'systemd service'

case $OSTYPE in
    linux*)
	alias sc='systemctl'
	alias scu='systemctl --user'
	alias scd='systemctl daemon-reload'
	alias scdu='systemctl --user daemon-reload'
	alias scr='systemctl restart'
	alias scru='systemctl --user restart'
	alias sce='systemctl stop'
	alias sceu='systemctl --user stop'
	alias scs='systemctl start'
	alias scsu='systemctl --user start'
    ;;
esac

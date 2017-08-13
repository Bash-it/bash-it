cite 'about-alias'
about-alias 'systemd service'

case $OSTYPE in
    linux*)
	alias sc='systemctl'
	alias scr='systemctl daemon-reload'
	alias scu='systemctl --user'
	alias scur='systemctl --user daemon-reload'
	alias sce='systemctl stop'
	alias scue='systemctl --user stop'
	alias scs='systemctl start'
	alias scus='systemctl --user start'
    ;;
esac

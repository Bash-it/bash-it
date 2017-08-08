# Author: Arthur Miller
# Created: 2017-08-08
# License: Public Domain

cite about-plugin
about-plugin 'SystemD helper functions'

# Reloads a systemwide service. If no agruments are given, reloads all services.
# Requires admin priviledge.
scrs(){
    if [ $# -eq 0 ]; then
	systemctl daemon-reload
    else
	echo "Stopping $1.service ..."
	systemctl stop "$1.service"
	echo "Starting $1.service ..."
	systemctl start "$1.service"
    fi;
}

# Display status of a systemwide service. If no arguments are given, display
# status for all services. Requires admin priviledge.
scst(){
    if [ $# -eq 0 ]; then
	systemctl status
    else
	systemctl status "$1.service"
    fi;
}

# Reloads an user service. If no agruments are given, reloads all user services.
scurs(){
    if [ $# -eq 0 ]; then
	systemctl --user daemon-reload
    else
	echo "Stopping $1.service ..."
	systemctl --user stop "$1.service"
	echo "Starting $1.service ..."
	systemctl --user start "$1.service"
    fi;
}

# runs systemctl --user status command
scust(){
    if [ $# -eq 0 ]; then
	systemctl --user status
    else
	systemctl --user status "$1.service"
    fi;
}

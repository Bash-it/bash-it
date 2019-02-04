function wttr() {
if [ -n "$1" ]; then
    if [ "$(ping -c 1 wttr.in)" ]; then
        if [ "$(which curl 2>/dev/null)" ]; then
            CITY="$(curl -s ipinfo.io/city)"
            echo "Weather of $1"
			      echo " "
            curl -s "wttr.in/$1?Q0"
        elif [ "$(which wget 2>/dev/null)" ]; then
            CITY="$(wget -qO- ipinfo.io/city)"
            echo "Weather of $1"
			      echo " "
            wget -qO- "wttr.in/$1?Q0"
        fi
        echo " "
    else
        echo "Can't connect to wttr.in"
        exit 1
    fi
else
    if [ "$(ping -c 1 wttr.in)" ]; then
        if [ "$(which curl 2>/dev/null)" ]; then
            CITY="$(curl -s ipinfo.io/city)"
            echo "Weather of $CITY"
			      echo " "
            curl -s "wttr.in/$CITY?Q0"
        elif [ "$(which wget 2>/dev/null)" ]; then
            CITY="$(wget -qO- ipinfo.io/city)"
            echo "Weather of $CITY"
			      echo " "
            wget -qO- "wttr.in/$CITY?Q0"
        fi
        echo
    else
        echo "Can't connect to wttr.in"
        exit 1
    fi
fi
}

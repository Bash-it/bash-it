function del() { mkdir -p /tmp/.trash && mv "$@" /tmp/.trash; }


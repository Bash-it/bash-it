set_xterm_title () {
    local title="$1"
    echo -ne "\e]0;$title\007"
}

precmd () {
    set_xterm_title "${USER}@${HOSTNAME} `dirs -0` $PROMPTCHAR"
}

preexec () {
    set_xterm_title "$1 {`dirs -0`} (${USER}@${HOSTNAME})"
}

preexec_install

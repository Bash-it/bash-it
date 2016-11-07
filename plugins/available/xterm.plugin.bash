cite about-plugin
about-plugin 'automatically set your xterm title with host and location info'

set_xterm_title () {
    local title="$1"
    echo -ne "\033]0;$title\007"
}


precmd () {
    set_xterm_title "${USER}@${SHORT_HOSTNAME:-${HOSTNAME}} `dirs -0` $PROMPTCHAR"
}

preexec () {
    set_xterm_title "$1 {`dirs -0`} (${USER}@${SHORT_HOSTNAME:-${HOSTNAME}})"
}

case "$TERM" in
    xterm*|rxvt*) preexec_install;;
esac

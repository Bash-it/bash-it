# This plugin is known to cause issues on OS X with the evaluation of
# colors.  Please read [issue 108] for more information.
#
# You can manually turn this on by symlinking it into your
# plugins/enabled/ directory.
#
# [issue 108]: https://github.com/revans/bash-it/issues/108

cite about-plugin
about-plugin 'automatically set your xterm title with host and location info'

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

case "$TERM" in
    xterm*|rxvt*) preexec_install;;
esac

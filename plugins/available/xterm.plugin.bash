cite about-plugin
about-plugin 'automatically set your xterm title with host and location info'


short_dirname () {
    local dir_name=`dirs -0`
    [ "$SHORT_TERM_LINE" = true ] && [ ${#dir_name} -gt 8 ] && echo ${dir_name##*/} || echo $dir_name
}

short_command () {
  local input_command="$@"
  [ "$SHORT_TERM_LINE" = true ] && [ ${#input_command} -gt 8 ] && echo ${input_command%% *} || echo $input_command
}

set_xterm_title () {
    local title="$1"
    echo -ne "\033]0;$title\007"
}

precmd () {
    set_xterm_title "${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}} `short_dirname` $PROMPTCHAR"
}

preexec () {
    set_xterm_title "$(short_command $1) {`short_dirname`} (${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}})"
}

case "$TERM" in
    xterm*|rxvt*) preexec_install;;
esac

cite about-plugin
about-plugin 'automatically set your xterm title with host and location info'


_short-dirname () {
  local dir_name=`dirs +0`
  [ "$SHORT_TERM_LINE" = true ] && [ ${#dir_name} -gt 8 ] && echo ${dir_name##*/} || echo $dir_name
}

_short-command () {
  local input_command="$@"
  [ "$SHORT_TERM_LINE" = true ] && [ ${#input_command} -gt 8 ] && echo ${input_command%% *} || echo $input_command
}

set_xterm_title () {
    local title="$1"
    echo -ne "\033]0;$title\007"
}

precmd_xterm_title () {
    set_xterm_title "${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}} `_short-dirname` $PROMPTCHAR"
}

preexec_xterm_title () {
    set_xterm_title "`_short-command $1` {`_short-dirname`} (${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}})"
}

case "$TERM" in
    xterm*|rxvt*)
        precmd_functions+=(precmd_xterm_title)
        preexec_functions+=(preexec_xterm_title)
        ;;
esac

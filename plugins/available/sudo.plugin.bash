cite about-plugin
about-plugin 'Toggle sudo at the beginning of the current or the previous command'

function sudo-command-line() {
  [[ ${#READLINE_LINE} -eq 0 ]] && READLINE_LINE=$(fc -l -n -1 | xargs)
  if [[ $READLINE_LINE == sudo\ * ]]; then
    READLINE_LINE="${READLINE_LINE#sudo }"
  else
    READLINE_LINE="sudo $READLINE_LINE"
  fi
  READLINE_POINT=${#READLINE_LINE}
}

# Define shortcut keys: [Esc] [Esc]
bind -x '"\e\e": sudo-command-line'

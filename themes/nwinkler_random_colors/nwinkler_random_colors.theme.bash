#!/bin/bash

# Two line prompt showing the following information:
# (time) SCM [username@hostname] pwd (SCM branch SCM status)
# →
#
# Example:
# (14:00:26) ± [foo@bar] ~/.bash_it (master ✓)
# →
#
# The arrow on the second line is showing the exit status of the last command:
# * Green: 0 exit status
# * Red: non-zero exit status
#
# The exit code functionality currently doesn't work if you are using the 'fasd' plugin,
# since 'fasd' is messing with the $PROMPT_COMMAND

RANDOM_COLOR_FILE=$HOME/.nwinkler_random_colors

function randomize_nwinkler {
  declare -a AVAILABLE_COLORS

  AVAILABLE_COLORS=(
    $black
    $red
    $green
    $yellow
    $blue
    $purple
    $cyan
    $white
    $orange
    $bold_black
    $bold_red
    $bold_green
    $bold_yellow
    $bold_blue
    $bold_purple
    $bold_cyan
    $bold_white
    $bold_orange
  )
  # Uncomment these to allow underlines:
    #$underline_black
    #$underline_red
    #$underline_green
    #$underline_yellow
    #$underline_blue
    #$underline_purple
    #$underline_cyan
    #$underline_white
    #$underline_orange
  #)

  USERNAME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  HOSTNAME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  TIME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  PATH_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}

  echo "$USERNAME_COLOR,$HOSTNAME_COLOR,$TIME_COLOR,$PATH_COLOR," > $RANDOM_COLOR_FILE
}

if [ -f $RANDOM_COLOR_FILE ];
then
  # read the colors already stored in the file
  IFS=',' read -ra COLORS < $RANDOM_COLOR_FILE
  USERNAME_COLOR=${COLORS[0]}
  HOSTNAME_COLOR=${COLORS[1]}
  TIME_COLOR=${COLORS[2]}
  PATH_COLOR=${COLORS[3]}
else
  # No colors stored yet. Generate them!
  randomize_nwinkler

  echo
  echo "Looks like you are using the nwinkler_random_color bashit theme for the first time."
  echo "Random colors have been generated to be used in your prompt."
  echo "If you don't like them, run the command:"
  echo "  randomize_nwinkler"
  echo "until you get a combination that you like."
  echo
fi

PROMPT_END_CLEAN="${green}→${reset_color}"
PROMPT_END_DIRTY="${red}→${reset_color}"

function prompt_end() {
  echo -e "$PROMPT_END"
}

prompt_setter() {
  local exit_status=$?
  if [[ $exit_status -eq 0 ]]; then PROMPT_END=$PROMPT_END_CLEAN
    else PROMPT_END=$PROMPT_END_DIRTY
  fi
  # Save history
  history -a
  history -c
  history -r
  PS1="(${TIME_COLOR}\t${reset_color}) $(scm_char) [${USERNAME_COLOR}\u${reset_color}@${HOSTNAME_COLOR}\H${reset_color}] ${PATH_COLOR}\w${reset_color}$(scm_prompt_info) ${reset_color}\n$(prompt_end) "
  PS2='> '
  PS4='+ '
}

safe_append_prompt_command prompt_setter

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"

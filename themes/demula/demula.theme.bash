#!/bin/bash 

# Theme inspired on:
#  - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
#  - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
#  - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#  - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
#  - Docs of Bash - http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR='\[${normal}\]'
D_INTERMEDIATE_COLOR='\[${white}\]'
D_USER_COLOR='\[${purple}\]'
D_SUPERUSER_COLOR='\[${red}\]'
D_MACHINE_COLOR='\[${cyan}\]'
D_DIR_COLOR='\[${green}\]'
D_SCM_COLOR='\[${yellow}\]'
D_BRANCH_COLOR='\[${yellow}\]'
D_CHANGES_COLOR='\[${white}\]'
D_CMDFAIL_COLOR='\[${red}\]'
D_VIMSHELL_COLOR='\[${cyan}\]'
# ------------------------------------------------------------------ FUNCTIONS
case $TERM in
  xterm*)
      TITLEBAR="\[\033]0;\w\007\]"
      ;;
  *)
      TITLEBAR=""
      ;;
esac

is_vim_shell() {
  if [ ! -z "$VIMRUNTIME" ]
  then
    echo "${D_INTERMEDIATE_COLOR}on ${D_VIMSHELL_COLOR}\
vim shell${D_DEFAULT_COLOR} "
  fi
}

demula_battery_charge() {
  if [ ! -z "$(battery_charge)" ]
  then
    battery_charge
  fi
}

mitsuhikos_lastcommandfailed() {
  code=$?
  if [ $code != 0 ];
  then
    echo "${D_INTERMEDIATE_COLOR}exited ${D_CMDFAIL_COLOR}\
$code ${D_DEFAULT_COLOR}" 
  fi
}

# vcprompt for scm instead of bash_it default
# https://github.com/xvzf/vcprompt
demula_vcprompt() {
  local D_VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt
  local D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${D_INTERMEDIATE_COLOR}:\
${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${D_DEFAULT_COLOR}"
  local D_VCPROMPT_OUTPUT=$($D_VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT")	

  echo $D_VCPROMPT_OUTPUT
}


# -------------------------------------------------------------- PROMPT OUTPUT
prompt() {
  local SAVE_CURSOR='\[\033[s\]'
  local RESTORE_CURSOR='\[\033[u\]'
  local MOVE_CURSOR_RIGHTMOST='\[\033[500C\]'
  local MOVE_CURSOR_LEFTMOST='\[\033[500D\]'
  local MOVE_CURSOR_5_LEFT='\[\033[5D\]'
  local MOVE_CURSOR_1_DOWN='\[\033[1B\]'

  PS1="${TITLEBAR}\n\
${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}\
$(demula_battery_charge)${RESTORE_CURSOR}\
${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}\
at ${D_MACHINE_COLOR}\h ${D_INTERMEDIATE_COLOR}\
in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}\
$(mitsuhikos_lastcommandfailed)\
$(demula_vcprompt)\
$(is_vim_shell)\n\
${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
  
  PS2="${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
}

# Runs prompt (this bypasses bash_it $PROMPT setting)
PROMPT_COMMAND=prompt


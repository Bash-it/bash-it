#!/bin/bash
SCM_THEME_PROMPT_DIRTY=''
SCM_THEME_PROMPT_CLEAN=''
SCM_GIT_CHAR="${bold_cyan}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"

if [ ! -z $THEME_PROMPT_HOST_COLOR ]; then
    THEME_PROMPT_HOST_COLOR=$(eval echo $`echo ${THEME_PROMPT_HOST_COLOR}`);
else
    THEME_PROMPT_HOST_COLOR="$blue"
fi

doubletime_scm_prompt() {
  CHAR=$(scm_char)
  if [ $CHAR = $SCM_NONE_CHAR ]
  then
    return
  else
    echo "$(git_prompt_status)"
  fi
}

virtualenv_prompt() {
  if [ ! -z "$VIRTUAL_ENV" ]
  then
    echo "(`basename $VIRTUAL_ENV`) "
  fi
}

function prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  if [[ -z "$THEME_PROMPT_CLOCK_FORMAT" ]]
  then
      clock="\t"
  else
      clock=$THEME_PROMPT_CLOCK_FORMAT
  fi
  PS1="
$clock $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)\w
$(doubletime_scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '
}

PROMPT_COMMAND=prompt_setter

git_prompt_status() {

  if [ -n "$(git status | grep 'Changes not staged' 2> /dev/null)" ]; then
    git_status="${bold_red}$(scm_prompt_info) ✗"
  elif [ -n "$(git status | grep 'Changes to be committed' 2> /dev/null)" ]; then
     git_status="${bold_yellow}$(scm_prompt_info) ^"
  elif [ -n "$(git status | grep 'Untracked files' 2> /dev/null)" ]; then
     git_status="${bold_cyan}$(scm_prompt_info) +"
  elif [ -n "$(git status | grep 'nothing to commit' 2> /dev/null)" ]; then
     git_status="${bold_green}$(scm_prompt_info) ${green}✓"
  else
    git_status="$(scm_prompt_info)"
  fi
  echo "[$git_status${normal}]"

}

# git_prompt_color() {
#
#   if [ -n "$(git status | grep 'Changes not staged' 2> /dev/null)" ]; then
#     git_status='${bold_red} ✗'
#   elif [ -n "$(git status | grep 'Changes to be committed' 2> /dev/null)" ]; then
#      git_status='${bold_yellow} ^'
#   elif [ -n "$(git status | grep 'Untracked files' 2> /dev/null)" ]; then
#      git_status='${bold_cyan} +'
#   else
#     git_status='${bold_green} ✓'
#   fi
#   echo $git_status
#
# }

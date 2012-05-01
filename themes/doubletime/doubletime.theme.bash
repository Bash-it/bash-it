#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=''
SCM_THEME_PROMPT_CLEAN=''
SCM_GIT_CHAR="${bold_cyan}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
if [ ! -z $RVM_THEME_PROMPT_COLOR ]; then
    RVM_THEME_PROMPT_COLOR=$(eval echo $`echo ${RVM_THEME_PROMPT_COLOR}`);
else
    RVM_THEME_PROMPT_COLOR="${red}"
fi
RVM_THEME_PROMPT_PREFIX="(${RVM_THEME_PROMPT_COLOR}rb${normal}: "
RVM_THEME_PROMPT_SUFFIX=") "
if [ ! -z $VIRTUALENV_THEME_PROMPT_COLOR ]; then
    VIRTUALENV_THEME_PROMPT_COLOR=$(eval echo $`echo ${VIRTUALENV_THEME_PROMPT_COLOR}`);
else
    VIRTUALENV_THEME_PROMPT_COLOR="${green}"
fi
VIRTUALENV_THEME_PROMPT_PREFIX="(${VIRTUALENV_THEME_PROMPT_COLOR}py${normal}: "
VIRTUALENV_THEME_PROMPT_SUFFIX=") "

if [ ! -z $THEME_PROMPT_HOST_COLOR ]; then
    THEME_PROMPT_HOST_COLOR=$(eval echo $`echo ${THEME_PROMPT_HOST_COLOR}`);
else
    THEME_PROMPT_HOST_COLOR="$blue"
fi

doubletime_scm_prompt() {
  CHAR=$(scm_char)
  if [ $CHAR = $SCM_NONE_CHAR ]; then
    return
  elif [ $CHAR = $SCM_GIT_CHAR ]; then
    echo "$(git_prompt_status)"
  else
    echo "[$(scm_prompt_info)]"
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
$clock $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)$(ruby_version_prompt)\w
$(doubletime_scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '
}

PROMPT_COMMAND=prompt_setter

git_prompt_status() {
  local git_status_output
  git_status_output=$(git status 2> /dev/null )
  if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
    git_status="${bold_red}$(scm_prompt_info) ✗"
  elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
     git_status="${bold_yellow}$(scm_prompt_info) ^"
  elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
     git_status="${bold_cyan}$(scm_prompt_info) +"
  elif [ -n "$(echo $git_status_output | grep 'nothing to commit')" ]; then
     git_status="${bold_green}$(scm_prompt_info) ${green}✓"
  else
    git_status="$(scm_prompt_info)"
  fi
  echo "[$git_status${normal}]"

}

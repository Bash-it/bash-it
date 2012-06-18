#!/usr/bin/env bash
fmt_time () { #format time just the way I like it
  if [ `date +%p` = "PM" ]; then
    meridiem="pm"
  else
    meridiem="am"
  fi
  date +"%l:%M:%S$meridiem"|sed 's/ //g'
}

pwdtail () { #returns the last 2 fields of the working directory
  pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

prompt_command () {
  if [ "\$(type -t __git_ps1)" ]; then # if we're in a Git repo, show current branch
      BRANCH="\$(__git_ps1 '[ %s ] ')"
  fi
  local TIME=`fmt_time`
  local GREEN="\[\033[0;32m\]"
  local CYAN="\[\033[0;36m\]"
  local BCYAN="\[\033[1;36m\]"
  local BLUE="\[\033[0;34m\]"
  local GRAY="\[\033[0;37m\]"
  local DKGRAY="\[\033[1;30m\]"
  local WHITE="\[\033[1;37m\]"
  local RED="\[\033[0;31m\]"
  local BLACK="\[\033[0;30m\]"
  local DEFAULT="\[\033[0;39m\]"
  local TITLEBAR='\[\e]2;`pwdtail`\a'
  export PS1="\[${TITLEBAR}\]${CYAN}[ ${BCYAN}\u${GREEN}@${BCYAN}\h${WHITE} ${TIME} ${CYAN}]${GRAY}\w\n${GREEN}${BRANCH}${DEFAULT}$ "
}

PROMPT_COMMAND=prompt_command;

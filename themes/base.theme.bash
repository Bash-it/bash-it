#!/bin/bash

THEME_PROMPT_HOST='\H'
SCM_THEME_PROMPT_DIRTY=' ✗'
SCM_THEME_PROMPT_CLEAN=' ✓'
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'

GIT='git'
SCM_GIT_CHAR='±'

HG='hg'
SCM_HG_CHAR='☿'

SVN='svn'
SCM_SVN_CHAR='⑆'

SCM_NONE_CHAR='○'

RVM_THEME_PROMPT_PREFIX=' |'
RVM_THEME_PROMPT_SUFFIX='|'

VIRTUALENV_THEME_PROMPT_PREFIX=' |'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'

function scm {
  if [[ -d .git ]]; then SCM=$GIT
  elif [[ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]]; then SCM=$GIT
  elif [[ -d .hg ]]; then SCM=$HG
  elif [[ -n "$(hg root 2> /dev/null)" ]]; then SCM=$HG
  elif [[ -d .svn ]]; then SCM=$SVN
  else SCM='NONE'
  fi
}

function scm_char {
  if [[ -z $SCM ]]; then scm; fi
  [[ $SCM == $GIT ]] && echo $SCM_GIT_CHAR && return
  [[ $SCM == $HG ]] && echo $SCM_HG_CHAR && return
  [[ $SCM == $SVN ]] && echo $SCM_SVN_CHAR && return
  echo $SCM_NONE_CHAR
}

function scm_prompt_info {
  if [[ -z $SCM ]]; then scm; fi
  [[ $SCM == $GIT ]] && git_prompt_info && return
  [[ $SCM == $HG ]] && hg_prompt_info && return
  [[ $SCM == $SVN ]] && svn_prompt_info && return
}

# Stolen from Steve Losh
# left in for backwards-compatibility
function prompt_char {
    char=$(scm_char);
    echo -e "$char"
}

function git_prompt_info {
  if [[ -n $(git status -s 2> /dev/null |grep -v ^# |grep -v "working directory clean") ]]; then
      state=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
  else
      state=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  fi
  prefix=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  suffix=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return

  echo -e "$prefix${ref#refs/heads/}$state$suffix"
}

function svn_prompt_info {
  if [[ -n $(svn status 2> /dev/null) ]]; then
      state=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
  else
      state=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  fi
  prefix=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  suffix=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  ref=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return

  [[ -z $ref ]] && return
  echo -e "$prefix$ref$state$suffix"
}

function hg_prompt_info() {
    if [[ -n $(hg status 2> /dev/null) ]]; then
        state=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        state=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    branch=$(hg summary 2> /dev/null | grep branch | awk '{print $2}')
    changeset=$(hg summary 2> /dev/null | grep parent | awk '{print $2}')

    echo -e "$prefix${REF_COLOR}${branch}${DEFAULT_COLOR}:${changeset#*:}$state$suffix"
}

function rvm_version_prompt {
  if which rvm &> /dev/null; then
    rvm=$(rvm tools identifier) || return
    echo -e "$RVM_THEME_PROMPT_PREFIX$rvm$RVM_THEME_PROMPT_SUFFIX"
  fi
}

function virtualenv_prompt {
  if which virtualenv &> /dev/null; then
    virtualenv=$([ ! -z "$VIRTUAL_ENV" ] && echo "`basename $VIRTUAL_ENV`") || return
    echo -e "$VIRTUALENV_THEME_PROMPT_PREFIX$virtualenv$VIRTUALENV_THEME_PROMPT_SUFFIX"
  fi
}

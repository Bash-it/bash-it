#!/usr/bin/env bash

THEME_PROMPT_HOST='\H'
SCM_THEME_PROMPT_DIRTY='*'
SCM_THEME_PROMPT_CLEAN=''
SCM_THEME_PROMPT_PREFIX="${reset}${bold}${light_gray}[${reset}${bold}${purple}"
SCM_THEME_PROMPT_SUFFIX="${reset}${bold}${light_gray}]${reset}${bold}${purple}"

SCM_GIT='git'
SCM_GIT_CHAR=''

SCM_HG='hg'
SCM_HG_CHAR=''

SCM_SVN='svn'
SCM_SVN_CHAR=''

SCM_NONE='NONE'
SCM_NONE_CHAR=''

RVM_THEME_PROMPT_PREFIX="${reset}${bold}${light_gray}[${reset}${bold}${purple}"
RVM_THEME_PROMPT_SUFFIX="${reset}${bold}${light_gray}]${reset}${bold}${purple}"

VIRTUALENV_THEME_PROMPT_PREFIX="${reset}${bold}${light_gray}[${reset}${bold}${purple}"
VIRTUALENV_THEME_PROMPT_SUFFIX="${reset}${bold}${light_gray}]${reset}${bold}${purple}"

RBENV_THEME_PROMPT_PREFIX="${reset}${bold}${light_gray}[${reset}${bold}${purple}"
RBENV_THEME_PROMPT_SUFFIX="${reset}${bold}${light_gray}]${reset}${bold}${purple}"

RBFU_THEME_PROMPT_PREFIX="${reset}${bold}${light_gray}[${reset}${bold}${purple}"
RBFU_THEME_PROMPT_SUFFIX="${reset}${bold}${light_gray}]${reset}${bold}${purple}"

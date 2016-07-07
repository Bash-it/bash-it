#!/usr/bin/env bash
#
# This theme was obviously inspired a lot by 
#
# - Demula theme
#
# which in itself was inspired by :
#
# - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
# - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
# - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
# - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
# - Bash_it modern theme
#
# Hawaii50 theme supports :
#
# - configurable directory length
# - hg, svn, git detection (I work in all of them)
# - virtualenv, rvm + gemsets
# 
# Screenshot: http://i.imgur.com/4IAMJ.png 
#
# by Ryan Kanno <ryankanno@localkinegrinds.com>
#
# And yes, we code out in Hawaii. :D
#
# Note: I also am really new to this bash scripting game, so if you see things
# that are flat out wrong, or if you think of something neat, just send a pull
# request.  This probably only works on a Mac - as some functions are OS 
# specific like getting ip, etc.
#

# IMPORTANT THINGS TO CHANGE ==================================================

# Show IP in prompt
# One thing to be weary about if you have slow Internets
IP_ENABLED=1

# virtual prompts
VIRTUAL_PROMPT_ENABLED=1

# COLORS ======================================================================
ORANGE='\[\e[0;33m\]'

DEFAULT_COLOR="${white}"

USER_COLOR="${purple}"
SUPERUSER_COLOR="${red}"
MACHINE_COLOR=$ORANGE
IP_COLOR=$ORANGE
DIRECTORY_COLOR="${green}"

VE_COLOR="${cyan}"
RVM_COLOR="${cyan}"

REF_COLOR="${purple}"

# SCM prompts
SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX=' on '
SCM_THEME_PROMPT_SUFFIX=''

# rvm prompts
RVM_THEME_PROMPT_PREFIX=''
RVM_THEME_PROMPT_SUFFIX=''

# virtualenv prompts
VIRTUALENV_THEME_PROMPT_PREFIX=''
VIRTUALENV_THEME_PROMPT_SUFFIX=''

VIRTUAL_THEME_PROMPT_PREFIX=' using '
VIRTUAL_THEME_PROMPT_SUFFIX=''

# Max length of PWD to display
MAX_PWD_LENGTH=20

# Max length of Git Hex to display
MAX_GIT_HEX_LENGTH=5

# IP address
IP_SEPARATOR=', '

# FUNCS =======================================================================

function get_ip_info {
    myip=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    echo -e "$(ips | sed -e :a -e '$!N;s/\n/${IP_SEPARATOR}/;ta' | sed -e 's/127\.0\.0\.1\${IP_SEPARATOR}//g'), ${myip}"
}

# Displays ip prompt 
function ip_prompt_info() {
    if [[ $IP_ENABLED == 1 ]]; then
        echo -e " ${DEFAULT_COLOR}(${IP_COLOR}$(get_ip_info)${DEFAULT_COLOR})"
    fi 
}

# Displays virtual info prompt (virtualenv/rvm)
function virtual_prompt_info() {
    local virtual_env_info=$(virtualenv_prompt)
    local rvm_info=$(ruby_version_prompt)
    local virtual_prompt=""

    local prefix=${VIRTUAL_THEME_PROMPT_PREFIX}
    local suffix=${VIRTUAL_THEME_PROMPT_SUFFIX}

    # If no virtual info, just return
    [[ -z "$virtual_env_info" && -z "$rvm_info" ]] && return

    # If virtual_env info present, append to prompt
    [[ -n "$virtual_env_info" ]] && virtual_prompt="virtualenv: ${VE_COLOR}$virtual_env_info${DEFAULT_COLOR}"

    if [[ -n "$rvm_info" ]]
    then
        [[ -n "$virtual_env_info" ]] && virtual_prompt="$virtual_prompt, "
        virtual_prompt="${virtual_prompt}rvm: ${RVM_COLOR}$rvm_info${DEFAULT_COLOR}"
    fi
    echo -e "$prefix$virtual_prompt$suffix"
}

# Parse git info
function git_prompt_info() {
    if [[ -n $(git status -s 2> /dev/null |grep -v ^# |grep -v "working directory clean") ]]; then
        state=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        state=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    commit_id=$(git rev-parse HEAD 2>/dev/null) || return

    echo -e "$prefix${REF_COLOR}${ref#refs/heads/}${DEFAULT_COLOR}:${commit_id:0:$MAX_GIT_HEX_LENGTH}$state$suffix"
}

# Parse hg info
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

# Parse svn info
function svn_prompt_info() {
    if [[ -n $(svn status --ignore-externals -q 2> /dev/null) ]]; then
        state=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
        state=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    ref=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
    [[ -z $ref ]] && return

    revision=$(svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )

    echo -e "$prefix${REF_COLOR}$ref${DEFAULT_COLOR}:$revision$state$suffix"
}

# Displays last X characters of pwd 
function limited_pwd() {

    # Replace $HOME with ~ if possible 
    RELATIVE_PWD=${PWD/#$HOME/\~}

    local offset=$((${#RELATIVE_PWD}-$MAX_PWD_LENGTH))

    if [ $offset -gt "0" ]
    then
        local truncated_symbol="..."
        TRUNCATED_PWD=${RELATIVE_PWD:$offset:$MAX_PWD_LENGTH}
        echo -e "${truncated_symbol}/${TRUNCATED_PWD#*/}"
    else
        echo -e "${RELATIVE_PWD}"
    fi
}

# Displays the current prompt
function prompt() {
    local UC=$USER_COLOR
    [ $UID -eq "0" ] && UC=$SUPERUSER_COLOR

    if [[ $VIRTUAL_PROMPT_ENABLED == 1 ]]; then
        PS1="$(scm_char) ${UC}\u ${DEFAULT_COLOR}at ${MACHINE_COLOR}\h$(ip_prompt_info) ${DEFAULT_COLOR}in ${DIRECTORY_COLOR}$(limited_pwd)${DEFAULT_COLOR}$(virtual_prompt_info)$(scm_prompt_info)${reset_color} \$ "
    else
        PS1="$(scm_char) ${UC}\u ${DEFAULT_COLOR}at ${MACHINE_COLOR}\h$(ip_prompt_info) ${DEFAULT_COLOR}in ${DIRECTORY_COLOR}$(limited_pwd)${DEFAULT_COLOR}$(scm_prompt_info)${reset_color} \$ "
    fi
    PS2='> '
    PS4='+ '
}

safe_append_prompt_command prompt

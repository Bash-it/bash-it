#!/bin/basORANGEh

# Colors
ORANGE='\e[0;33m'
GREY='\e[1:37m'

DEFAULT_COLOR='\[${white}\]'

USER_COLOR='\[${purple}\]'
SUPERUSER_COLOR='\[${red}\]'
MACHINE_COLOR=$ORANGE
IP_COLOR=$MACHINE_COLOR
DIRECTORY_COLOR='\[${green}\]'

VE_COLOR='\[${cyan}\]'
RVM_COLOR='\[${cyan}\]'

SCM_COLOR=$ORANGE
REF_COLOR='\[${purple}\]'

# SCM prompts
SCM_THEME_PROMPT_DIRTY=' ${bold_red}✗${normal}'
SCM_THEME_PROMPT_CLEAN=' ${bold_green}✓${normal}'

# Max length of PWD to display
MAX_PWD_LENGTH=20

# Max length of Git Hex to display
MAX_GIT_HEX_LENGTH=5

# Removed prefix/suffix
SCM_THEME_PROMPT_PREFIX=" "
SCM_THEME_PROMPT_SUFFIX=""

function ip {
    echo $(ifconfig en1 | grep "inet " | awk '{ print $2 }')
}

# Override function scm
function scm {
  if [[ -d .git ]]; then SCM=$GIT
  elif [[ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]]; then SCM=$GIT
  elif [[ -n "$(hg summary 2> /dev/null)" ]]; then SCM=$HG
  elif [[ -d .svn ]]; then SCM=$SVN
  else SCM='NONE'
  fi
}

# Displays the current virtualenv information
function curr_virtualenv_info() {
    [ ! -z "$VIRTUAL_ENV" ] && echo "`basename $VIRTUAL_ENV`"
}

# Displays the current rvm information w/gemset
function curr_rvm_info() {
    local ruby_version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
    local ruby_gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')

    if [ "$ruby_version" != "" ]; then
        [ "$ruby_gemset" != "" ] && ruby_gemset="@$ruby_gemset"
        echo "$ruby_version$ruby_gemset"
    fi
}

# Displays using ...
function virtual_info() {
    local virtual_env_info=$(curr_virtualenv_info)
    local rvm_info=$(curr_rvm_info)

    # If no virtual info, just return
    [ "$virtual_env_info" == "" -a "$rvm_info" == "" ] && return

    local prompt=" using"

    # If virtual_env info present, append to prompt
    [ "$virtual_env_info" != "" ] && prompt="$prompt virtualenv: ${VE_COLOR}$virtual_env_info${DEFAULT_COLOR}"

    if [ "$rvm_info" != "" ]
    then
        [ "$virtual_env_info" != "" ] && prompt="$prompt,"
        prompt="$prompt rvm: ${RVM_COLOR}$rvm_info${DEFAULT_COLOR}"
    fi
    echo "$prompt"
}

# SCM information
function scm_info() {
    SCM_CHAR=$(scm_char)
    [ "$SCM_CHAR" == "$SCM_NONE_CHAR" ] && return
    local prompt=" on"
    [ "$SCM_CHAR" == "$SCM_GIT_CHAR" ] && echo "$prompt$(parse_git_info)" && return
    [ "$SCM_CHAR" == "$SCM_SVN_CHAR" ] && echo "$prompt$(parse_svn_info)" && return
    [ "$SCM_CHAR" == "$SCM_HG_CHAR" ] && echo "$prompt$(parse_hg_info)" && return
}

# Parse git info
function parse_git_info() {
    if [[ -n $(git status -s 2> /dev/null |grep -v ^# |grep -v "working directory clean") ]]; then
      state=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      state=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    rawhex=$(git rev-parse HEAD 2>/dev/null) || return

    echo "$prefix${REF_COLOR}${ref#refs/heads/}${DEFAULT_COLOR}:${rawhex:0:$MAX_GIT_HEX_LENGTH}$state$suffix"
}

# Parse hg info
function parse_hg_info() {
    if [[ -n $(hg status 2> /dev/null) ]]; then
      state=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      state=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    branch=$(hg summary 2> /dev/null | grep branch | awk '{print $2}')
    changeset=$(hg summary 2> /dev/null | grep parent | awk '{print $2}')

    echo "$prefix${REF_COLOR}${branch}${DEFAULT_COLOR}:${changeset#*:}$state$suffix"
}

# Parse svn info
function parse_svn_info() {
    if [[ -n $(svn status --ignore-externals -q 2> /dev/null) ]]; then
      state=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      state=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    prefix=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    suffix=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    ref=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
    revision=$(svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )
    [[ -z $ref ]] && return
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
        echo "${truncated_symbol}/${TRUNCATED_PWD#*/}"
    else
        echo "${RELATIVE_PWD}"
    fi
}

# Displays the current prompt
function prompt() {

  local UC=$USER_COLOR
  [ $UID -eq "0" ] && UC=$SUPERUSER_COLOR
    
  PS1="$(scm_char) ${UC}\u ${DEFAULT_COLOR}at ${MACHINE_COLOR}\h ${DEFAULT_COLOR}(${IP_COLOR}$(ip)${DEFAULT_COLOR})${DEFAULT_COLOR} in ${DIRECTORY_COLOR}$(limited_pwd)${DEFAULT_COLOR}$(virtual_info)$(scm_info) \$ "
  PS2='> '
  PS4='+ '
}

PROMPT_COMMAND=prompt

#!/usr/bin/env bash
# shellcheck disable=2034,2154

SCM_GIT_CHAR_GITLAB='  '
SCM_GIT_CHAR_BITBUCKET='  '
SCM_GIT_CHAR_GITHUB='  '
SCM_GIT_CHAR_DEFAULT='  '
SCM_GIT_CHAR_ICON_BRANCH=''
SCM_HG_CHAR='☿ '
SCM_SVN_CHAR='⑆ '
SCM_NONE_CHAR=
SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${green}| "
SCM_GIT_BEHIND_CHAR="${bold_red}↓${normal}"
SCM_GIT_AHEAD_CHAR="${bold_green}↑${normal}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${bold_yellow}•${normal}"
SCM_GIT_STAGED_CHAR="${bold_green}+${normal}"
GIT_THEME_PROMPT_DIRTY=" ${bold_red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${cyan}"
GIT_THEME_PROMPT_SUFFIX="${cyan}"
SCM_THEME_BRANCH_TRACK_PREFIX="${normal} ⤏  ${cyan}"
SCM_THEME_CURRENT_USER_PREFFIX='  '
SCM_GIT_SHOW_CURRENT_USER=false
EXIT_CODE_ICON=' '

function _git-uptream-remote-logo {
    [[ "$(_git-upstream)" == "" ]] && return

    local remote remote_domain
    remote=$(_git-upstream-remote)
    remote_domain=$(git config --get remote."$remote".url | awk -F'[@:.]' '{print $2}')

    # remove // suffix for https:// url
    remote_domain=${remote_domain//\//}

    case $remote_domain in
        github ) SCM_GIT_CHAR="$SCM_GIT_CHAR_GITHUB";;
        gitlab ) SCM_GIT_CHAR="$SCM_GIT_CHAR_GITLAB";;
        bitbucket ) SCM_GIT_CHAR="$SCM_GIT_CHAR_BITBUCKET";;
        * ) SCM_GIT_CHAR="$SCM_GIT_CHAR_DEFAULT";;
    esac
}

function git_prompt_info {
    git_prompt_vars
    echo -e " on $SCM_GIT_CHAR_ICON_BRANCH $SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_GIT_AHEAD$SCM_GIT_BEHIND$SCM_GIT_STASH$SCM_SUFFIX"
}

function _exit-code {
    if [[ "$1" -ne 0 ]]; then
        exit_code=" ${purple}${EXIT_CODE_ICON}${yellow}${exit_code}${bold_orange}"
    else
        exit_code="${bold_green}"
    fi
}

function _prompt {
    local exit_code="$?" wrap_char=' ' dir_color=$green

    _exit-code exit_code
    _git-uptream-remote-logo

    history -a

    # Detect root shell
    if [ "$(whoami)" = root ]; then
        dir_color=$red
    fi

    PS1="\\n ${purple}$(scm_char)${dir_color}\\w${normal}$(scm_prompt_info)${exit_code}"

    [[ ${#PS1} -gt $((COLUMNS*3)) ]] && wrap_char="\\n"
    PS1="${PS1}${wrap_char}❯${normal} "
}

safe_append_prompt_command _prompt

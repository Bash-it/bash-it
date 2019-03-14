#!/usr/bin/env bash

  #####################################
 #  https://github.com/phreakocious  #
#####################################

# ★ ➤ ▶ ► ‣ ✱ ✽ ❖ ✸ ✹ ◼■ ●○•°✪ ⬤ ⚫⭕ ⧫⬧♦⬥

      prompt_user=▶
     prompt_clean=✔
     prompt_dirty=✗
     prompt_ahead=↑
    prompt_behind=↓
   prompt_diverge=↕

      color_user="$bold_green"
      color_host="$green"
      color_time="$(echo_color rgb 265 265 265)"
        color_at="$color_time"
      color_path="$cyan"
     color_clean="$bold_green"
     color_dirty="$(echo_color rgb 255 95 0)"
     color_ahead="$bold_yellow"
    color_behind="$yellow"
   color_diverge="$bold_white"
    color_branch="$(echo_color rgb 0 255 95)"
   color_success="$bold_green"
   color_failure="$bold_red"

prompt_user_root=★
 color_user_root="$bold_red"
 color_host_root="$red"


###


[[ $EUID -eq 0 ]] && color_host=${color_host_root} && color_user=${color_user_root} && prompt_user="$prompt_user_root"

parse_git() {
  git_status="$(git status 2>/dev/null)" || return

    pattern_clean="working tree clean"
    pattern_ahead="Your branch is ahead of"
   pattern_branch="^On branch ([^${IFS}]*)"
   pattern_behind="Your branch is behind "
  pattern_diverge="Your branch .* has diverged"

  [[ ${git_status} =~ ${pattern_clean}   ]] &&  state="${color_clean}$prompt_clean" || state="${color_dirty}$prompt_dirty"
  [[ ${git_status} =~ ${pattern_ahead}   ]] && remote="${color_ahead}$prompt_ahead "
  [[ ${git_status} =~ ${pattern_behind}  ]] && remote="${color_behind}$prompt_behind "
  [[ ${git_status} =~ ${pattern_diverge} ]] && remote="${color_diverge}$prompt_diverge "
  [[ ${git_status} =~ ${pattern_branch}  ]] && branch="${BASH_REMATCH[1]}"

  echo " ${color_branch}(${branch}) ${remote}${state}"
}

prompt_command() {
  [[ $? -eq 0 ]] && color_exit="$color_success" || color_exit="$color_failure"
  PS1="${color_user}\u${color_at}@${color_host}\h${color_time}·$(date +%H:%M:%S) ${color_path}\w$(parse_git) ${color_exit}${prompt_user} ${normal}"
}

safe_append_prompt_command prompt_command
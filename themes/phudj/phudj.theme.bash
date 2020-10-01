#!/usr/bin/env bash

  #####################################
 #  https://github.com/phreakocious  #
#####################################

#
# phudj is a theme for bash-it -- https://github.com/Bash-it/bash-it
# 

# ★ ➤ ▶ ► ‣ ✱ ✽ ❖ ✸ ✹ ◼■ ●○-°✪ ⧫⬧♦⬥ ⁉ ‼ ✗ ✘ ❓❔ ⁈ ※ ⁂ ⁑ ⧖ ⧗ ☆ ⚠
# ❗⚡ ✅ ❌ ✨❓ 🌀 🌈 🔥 🥓 🌞 💫 💥 💣 💡🌟⛔ ⬤ ⚫⭕ 🔴 🔵 🔶 🔷 🔸 🔹 🔺 🔻 🚫 🚀 ☄ 💢 

      prompt_user=▶
     prompt_clean=✔
     prompt_dirty=✗
     prompt_ahead=↑
    prompt_behind=↓
   prompt_diverge=↕
     prompt_stash=✱

      color_user="$bold_green"
      color_host="$green"
      color_time="\[$(echo_color rgb 265 265 265)\]"
        color_at="$color_time"
      color_path="$cyan"
     color_clean="$bold_green"
     color_dirty="\[$(echo_color rgb 255 95 0)\]"
     color_ahead="$bold_yellow"
    color_behind="$yellow"
   color_diverge="$bold_white"
    color_branch="\[$(echo_color rgb 0 255 95)\]"
   color_success="$bold_green"
   color_failure="$bold_red"
     color_stash="\[$(echo_color rgb 223 15 31)\]"

prompt_user_root=★
 color_user_root="$bold_red"
 color_host_root="$red"

###


[[ $EUID -eq 0 ]] && color_host=${color_host_root} && color_user=${color_user_root} && prompt_user="$prompt_user_root"

# seq/jot are not always available, so eval+echo+brace expansion it shall be
repeat_char() { char=$1; reps=$2; printf "${char}%.0s" $(eval echo {1..$reps}) ; }

parse_git() {
  git_status="$(git status --show-stash 2>/dev/null)" || return

    pattern_clean="working tree clean"
    pattern_ahead="Your branch is ahead of"
   pattern_branch="^On branch ([^${IFS}]*)"
   pattern_behind="Your branch is behind "
  pattern_diverge="Your branch .* has diverged"
    pattern_stash="Your stash currently has ([0-9]+)" 

  [[ ${git_status} =~ ${pattern_clean}   ]] &&  state="${color_clean}$prompt_clean" || state="${color_dirty}$prompt_dirty"
  [[ ${git_status} =~ ${pattern_ahead}   ]] && remote="${color_ahead}$prompt_ahead "
  [[ ${git_status} =~ ${pattern_behind}  ]] && remote="${color_behind}$prompt_behind "
  [[ ${git_status} =~ ${pattern_diverge} ]] && remote="${color_diverge}$prompt_diverge "
  [[ ${git_status} =~ ${pattern_branch}  ]] && branch="${BASH_REMATCH[1]}"
  [[ ${git_status} =~ ${pattern_stash}   ]] &&  stash="${color_stash}$(repeat_char $prompt_stash ${BASH_REMATCH[1]}) "

  echo " ${color_branch}(${branch}) ${stash}${remote}${state}"
}

prompt_command() {
  [[ $? -eq 0 ]] && color_exit="$color_success" || color_exit="$color_failure"
  PS1="${color_user}\u${color_at}@${color_host}\h${color_time}·$(date +%H:%M:%S) ${color_path}\w$(parse_git) ${color_exit}${prompt_user} ${normal}"
}

safe_append_prompt_command prompt_command
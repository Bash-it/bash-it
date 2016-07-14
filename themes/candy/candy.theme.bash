#!/usr/bin/env bash
function prompt_command() {
    PS1="${green}\u@\h ${blue}\T ${reset_color}${white}\w${reset_color}$(scm_prompt_info)${blue} →${bold_blue} ${reset_color} ";
}

safe_append_prompt_command prompt_command

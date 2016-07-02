#!/usr/bin/env bash

# based of the candy theme, but minimized by odbol
function prompt_command() {
    PS1="${blue}\T ${reset_color}${white}\w${reset_color}$(scm_prompt_info)${blue} →${bold_blue} ${reset_color} ";
}

PROMPT_COMMAND=prompt_command;
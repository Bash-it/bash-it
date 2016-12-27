#!/usr/bin/env bash

source "${BASH_IT}/themes/psyco/colors.psyco.bash"
source "${BASH_IT}/themes/psyco/base.psyco.bash"

ruby_format="${reset}${yellow}"
user_name="${reset}${bold}${red}\u"
at_symbol="${reset}${bold}${light_gray}@"
machine_name="${reset}${bold}${orange}\h"
location_word="${reset}${bold}${light_gray} in "
location_path="${reset}${bold}${yellow}\w"
user_privilege="${reset}${bold}${white}\n\$"
input_style="${reset}${normal}"

function prompt_command() {
    PS1="${ruby_format}$(ruby_version_prompt)${user_name}${at_symbol}${machine_name}${location_word}${location_path}$(scm_char)$(scm_prompt_info)${user_privilege}${input_style} "
}

PROMPT_COMMAND=prompt_command;

#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_COLOR_DIRTY="${bold_red}"
SCM_THEME_COLOR_CLEAN="${green}"
SCM_THEME_PROMPT_PREFIX=" ${white}("
SCM_THEME_PROMPT_SUFFIX="${white})"

SUCCESS_PROMPT="${bold_green}→"
ERROR_PROMPT="${bold_red}✗"

function prompt_command() {
		if [ $? = 0 ]; then RESULT_PROMPT=$SUCCESS_PROMPT; else RESULT_PROMPT=$ERROR_PROMPT; fi
    PS1="${bold_cyan}\u@\h ${bold_blue}\w${reset_color}$(scm_prompt_info) $RESULT_PROMPT${normal} ";
}

PROMPT_COMMAND=prompt_command;

#!/bin/bash

# prompt themeing
PROMPT='\n${bold_blue}$(prompt_char)$(git_prompt_info) ${orange}\h ${reset_color}in ${green}\w ${reset_color}→ '

# git themeing
GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"
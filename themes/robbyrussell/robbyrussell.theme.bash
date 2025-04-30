# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154
SCM_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${bold_blue}scm:("
SCM_THEME_PROMPT_SUFFIX="${bold_blue})"

GIT_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${bold_blue}git:("
GIT_THEME_PROMPT_SUFFIX="${bold_blue})"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

VIRTUALENV_THEME_PROMPT_PREFIX='('
VIRTUALENV_THEME_PROMPT_SUFFIX=') '

function git_prompt_info() {
	git_prompt_vars
	echo -e "$SCM_PREFIX${bold_red}$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function prompt_command() {
	PS1="$(conda_or_venv_prompt)${bold_green}➜  ${bold_cyan}\W${reset_color}$(scm_prompt_info)${normal} "
}

PROMPT_COMMAND=prompt_command

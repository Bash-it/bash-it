# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154

SCM_THEME_PROMPT_DIRTY=''
SCM_THEME_PROMPT_CLEAN=''
SCM_GIT_CHAR="${bold_cyan}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
if [[ -n "$RVM_THEME_PROMPT_COLOR" ]]; then
	RVM_THEME_PROMPT_COLOR=$(eval "echo $$(echo ${RVM_THEME_PROMPT_COLOR})")
else
	RVM_THEME_PROMPT_COLOR="${red}"
fi
RVM_THEME_PROMPT_PREFIX="(${RVM_THEME_PROMPT_COLOR}rb${normal}: "
RVM_THEME_PROMPT_SUFFIX=") "
if [[ -n "$VIRTUALENV_THEME_PROMPT_COLOR" ]]; then
	VIRTUALENV_THEME_PROMPT_COLOR=$(eval "echo $$(echo ${VIRTUALENV_THEME_PROMPT_COLOR})")
else
	VIRTUALENV_THEME_PROMPT_COLOR="${green}"
fi
VIRTUALENV_THEME_PROMPT_PREFIX="(${VIRTUALENV_THEME_PROMPT_COLOR}py${normal}: "
VIRTUALENV_THEME_PROMPT_SUFFIX=") "

if [[ -n "$THEME_PROMPT_HOST_COLOR" ]]; then
	THEME_PROMPT_HOST_COLOR=$(eval "echo $$(echo ${THEME_PROMPT_HOST_COLOR})")
else
	THEME_PROMPT_HOST_COLOR="$blue"
fi

function prompt_setter() {
	# Save history
	_save-and-reload-history 1
	PS1="
$(clock_prompt) $(scm_char) [${THEME_PROMPT_HOST_COLOR}\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)$(ruby_version_prompt)\w
$(scm_prompt)$reset_color $ "
	PS2='> '
	PS4='+ '
}

safe_append_prompt_command prompt_setter

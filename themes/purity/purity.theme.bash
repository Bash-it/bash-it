# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# shellcheck disable=SC2154 #TODO: fix these all.

SCM_THEME_PROMPT_DIRTY=" ${bold_red}⊘${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX="${reset_color}( "
SCM_THEME_PROMPT_SUFFIX=" ${reset_color})"

GIT_THEME_PROMPT_DIRTY=" ${bold_red}⊘${normal}"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
GIT_THEME_PROMPT_PREFIX="${reset_color}( "
GIT_THEME_PROMPT_SUFFIX=" ${reset_color})"

STATUS_THEME_PROMPT_BAD="${bold_red}❯${reset_color}${normal} "
STATUS_THEME_PROMPT_OK="${bold_green}❯${reset_color}${normal} "
PURITY_THEME_PROMPT_COLOR="${PURITY_THEME_PROMPT_COLOR:=$blue}"

venv_prompt() {
	python_venv=""
	# Detect python venv
	if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR${CONDA_DEFAULT_ENV}) "
	elif [[ -n "${VIRTUAL_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR$(basename "${VIRTUAL_ENV}")) "
	fi
	[[ -n "${python_venv}" ]] && echo "${python_venv}"
}

function prompt_command() {
	local retval=$? ret_status
	ret_status="$([ $retval -eq 0 ] && echo -e "$STATUS_THEME_PROMPT_OK" || echo -e "$STATUS_THEME_PROMPT_BAD")"
	PS1="\n${PURITY_THEME_PROMPT_COLOR}\w $(scm_prompt_info)\n${ret_status}$(venv_prompt)"
}

safe_append_prompt_command prompt_command

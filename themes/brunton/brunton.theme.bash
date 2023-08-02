# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗${normal?}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓${normal?}"
SCM_GIT_CHAR="${bold_green?}±${normal?}"
SCM_SVN_CHAR="${bold_cyan?}⑆${normal?}"
SCM_HG_CHAR="${bold_red?}☿${normal?}"

function is_vim_shell() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ -n "${VIMRUNTIME:-}" ]] 
     then
		echo "[${cyan?}vim shell${normal?}]"
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local SCM_PROMPT_FORMAT=' %s (%s)' clock_prompt battery_charge scm_prompt is_vim_shell
	clock_prompt="$(clock_prompt)"
	battery_charge="$(battery_charge)"
	scm_prompt="$(scm_prompt)"
	is_vim_shell="$(is_vim_shell)"
	PS1="${white?}${background_blue?} \u${normal?}${background_blue?}@${red?}${background_blue?}\h ${clock_prompt} ${reset_color?}${normal?} ${battery_charge}\n${bold_black?}${background_white?} \w ${normal?}${scm_prompt}${is_vim_shell}\n${white?}>${normal?} "

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

: "${THEME_CLOCK_COLOR:=${blue?}${background_white?}}"
: "${THEME_CLOCK_FORMAT:=" %H:%M:%S"}"

safe_append_prompt_command prompt

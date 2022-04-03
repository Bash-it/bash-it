# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗${normal?}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓${normal?}"
SCM_GIT_CHAR="${bold_green?}±${normal?}"
SCM_SVN_CHAR="${bold_cyan?}⑆${normal?}"
SCM_HG_CHAR="${bold_red?}☿${normal?}"

case "${TERM:-dumb}" in
	xterm*)
		TITLEBAR="\[\033]0;\w\007\]"
		;;
	*)
		TITLEBAR=""
		;;
esac

PS3=">> "

function is_vim_shell() {
	if [[ -n "${VIMRUNTIME:-}" ]]; then
		echo "[${cyan?}vim shell${normal?}]"
	fi
}

function detect_venv() {
	local python_venv=""
	# Detect python venv
	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_venv="(${PYTHON_VENV_CHAR}${CONDA_DEFAULT_ENV}) "
	elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
		python_venv="(${PYTHON_VENV_CHAR}${VIRTUAL_ENV##*/}) "
	fi
}

function prompt() {
	local retval=$? scm_prompt is_vim_shell python_venv
	local SCM_PROMPT_FORMAT='[%s][%s]'
	scm_prompt="$(scm_prompt)"
	is_vim_shell="$(is_vim_shell)"
	if [[ retval -ne 0 ]]; then
		PS1="${TITLEBAR:-}${bold_red?}┌─${reset_color?}${scm_prompt}[${cyan?}\u${normal?}][${cyan?}\w${normal?}]${is_vim_shell}\n${bold_red?}└─▪${normal?} "
	else
		PS1="${TITLEBAR:-}┌─${scm_prompt}[${cyan?}\u${normal?}][${cyan?}\w${normal?}]${is_vim_shell}\n└─▪ "
	fi
	detect_venv
	PS1+="${python_venv?}${dir_color?}"
}

PS2="└─▪ "

safe_append_prompt_command prompt

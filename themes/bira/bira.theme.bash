# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX=" ${yellow?}‹"
SCM_THEME_PROMPT_SUFFIX="›${reset_color?}"

VIRTUALENV_THEME_PROMPT_PREFIX=" ${cyan?}‹"
VIRTUALENV_THEME_PROMPT_SUFFIX="›${reset_color?}"
CONDAENV_THEME_PROMPT_PREFIX=" ${cyan?}‹"
CONDAENV_THEME_PROMPT_SUFFIX="›${reset_color?}"

bold="\[\e[1m\]"

if [[ ${UID} -eq 0 ]]; then
	user_host="${bold_red?}\u@\h${normal?}${reset_color?}"
else
	user_host="${bold_green?}\u@\h${normal?}${reset_color?}"
fi

function prompt_command() {
	local current_dir=" ${bold_blue?}\w${normal?}${reset_color?}"
	local virtualenv_prompt scm_prompt_info
	virtualenv_prompt="${virtualenv_prompt:-$(condaenv_prompt)}"
	scm_prompt_info="$(scm_prompt_info)"
	PS1="╭─${user_host?}${current_dir}${virtualenv_prompt}${scm_prompt_info}\n╰─${bold?}\\$ ${normal?}"
}

safe_append_prompt_command prompt_command

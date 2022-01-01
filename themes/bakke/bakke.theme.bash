# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_DIRTY=" ${red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green?}|"

GIT_THEME_PROMPT_DIRTY=" ${red?}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
GIT_THEME_PROMPT_PREFIX=" ${green?}|"
GIT_THEME_PROMPT_SUFFIX="${green?}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
	#PS1="${bold_cyan}$(scm_char)${green}$(scm_prompt_info)${purple}$(ruby_version_prompt) ${yellow}\h ${reset_color}in ${green}\w ${reset_color}\n${green}→${reset_color} "
	#PS1="\n${purple}\h: ${reset_color} ${green}\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
	#PS1="\n${cyan}\h: ${reset_color} ${yellow}\w\n${red}$(scm_char)${red}$(scm_prompt_info) ${green}→${reset_color} "
	local virtualenv_prompt scm_prompt_info
	virtualenv_prompt="$(virtualenv_prompt)"
	scm_prompt_info="$(scm_prompt_info)"
	PS1="\n${cyan?}\h:${virtualenv_prompt} ${reset_color?} ${yellow?}\w ${green?}${scm_prompt_info}\n${reset_color?}→ "
}

safe_append_prompt_command prompt_command

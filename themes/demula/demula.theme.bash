# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Theme inspired on:
#  - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
#  - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
#  - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#  - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
#  - Bash_it modern theme
#
# Screenshot: http://goo.gl/VCmX5
# by Jesus de Mula <jesus@demula.name>

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR="${normal?}"
D_INTERMEDIATE_COLOR="${white?}"
D_USER_COLOR="${purple?}"
D_SUPERUSER_COLOR="${red?}"
D_MACHINE_COLOR="${cyan?}"
D_DIR_COLOR="${green?}"
D_SCM_COLOR="${yellow?}"
D_BRANCH_COLOR="${yellow?}"
D_CHANGES_COLOR="${white?}"
D_CMDFAIL_COLOR="${red?}"
D_VIMSHELL_COLOR="${cyan?}"

# ------------------------------------------------------------------ FUNCTIONS
case $TERM in
	xterm*)
		TITLEBAR="\033]0;\w\007"
		;;
	*)
		TITLEBAR=""
		;;
esac

is_vim_shell() {
	if [ -n "$VIMRUNTIME" ]; then
		echo "${D_INTERMEDIATE_COLOR}on ${D_VIMSHELL_COLOR}\
vim shell${D_DEFAULT_COLOR} "
	fi
}

mitsuhikos_lastcommandfailed() {
	code=$?
	if [ $code != 0 ]; then
		echo "${D_INTERMEDIATE_COLOR}exited ${D_CMDFAIL_COLOR}\
$code ${D_DEFAULT_COLOR}"
	fi
}

# vcprompt for scm instead of bash_it default
demula_vcprompt() {
	if [ -n "$VCPROMPT_EXECUTABLE" ]; then
		local D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${D_INTERMEDIATE_COLOR}:\
${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${D_DEFAULT_COLOR}"
		$VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT"
	fi
}

# checks if the plugin is installed before calling battery_charge
safe_battery_charge() {
	if _command_exists battery_charge; then
		battery_charge
	fi
}

# -------------------------------------------------------------- PROMPT OUTPUT
prompt() {
	local LAST_COMMAND_FAILED
	LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
	local SAVE_CURSOR='\033[s'
	local RESTORE_CURSOR='\033[u'
	local MOVE_CURSOR_RIGHTMOST='\033[500C'
	local MOVE_CURSOR_5_LEFT='\033[5D'

	if [[ "$OSTYPE" = 'linux'* ]]; then
		PS1="${TITLEBAR}${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}
$(safe_battery_charge)${RESTORE_CURSOR}\
${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}\
at ${D_MACHINE_COLOR}\h ${D_INTERMEDIATE_COLOR}\
in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}\
${LAST_COMMAND_FAILED}\
$(demula_vcprompt)\
$(is_vim_shell)
${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
	else
		PS1="${TITLEBAR}
${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}\
at ${D_MACHINE_COLOR}\h  ${D_INTERMEDIATE_COLOR}\
in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}\
${LAST_COMMAND_FAILED}\
$(demula_vcprompt)\
$(is_vim_shell)\
$(safe_battery_charge)
${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
	fi

	PS2="${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
}

# Runs prompt (this bypasses bash_it $PROMPT setting)
safe_append_prompt_command prompt

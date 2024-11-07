#!/usr/bin/env bash

# Theme inspired on:
#  - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
#  - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
#  - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#  - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
#  - Bash_it modern theme
#
# by Rana Amrit Parth<ramrit9@gmaiil.com>

# For the real Monokai colors you should add these to your .XDefaults or
# terminal configuration:
#! ----------------------------------------------------------- TERMINAL COLORS
#! monokai - http://www.monokai.nl/blog/2006/07/15/textmate-color-theme/
#*background: #272822
#*foreground: #E2DA6E
#*color0: black
#! mild red
#*color1: #CD0000
#! light green
#*color2: #A5E02D
#! orange (yellow)
#*color3: #FB951F
#! "dark" blue
#*color4: #076BCC
#! hot pink
#*color5: #F6266C
#! cyan
#*color6: #64D9ED
#! gray
#*color7: #E5E5E5

# ----------------------------------------------------------------- DEF COLOR
RCol='\e[0m' # Text Reset

# Regular
Bla='\e[0;30m'
Red='\e[0;31m'
Gre='\e[0;32m'
Yel='\e[0;33m'
Blu='\e[0;34m'
Pur='\e[0;35m'
Cya='\e[0;36m'
Whi='\e[0;37m'

# Bold
BBla='\e[1;30m'
BRed='\e[1;31m'
BYel='\e[1;33m'
BGre='\e[1;32m'
BBlu='\e[1;34m'
BPur='\e[1;35m'
BCya='\e[1;36m'
BWhi='\e[1;37m'

# High Intensity
IBla='\e[0;90m'
IRed='\e[0;91m'
IGre='\e[0;92m'
IYel='\e[0;93m'
IBlu='\e[0;94m'
IPur='\e[0;95m'
ICya='\e[0;96m'
IWhi='\e[0;97m'

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR="${Whi}"
D_INTERMEDIATE_COLOR="${BWhi}"
D_USER_COLOR="${Yel}"
D_SUPERUSER_COLOR="${Red}"
D_MACHINE_COLOR="${IYel}"
D_DIR_COLOR="${Gre}"
D_GIT_COLOR="${BBlu}"
D_SCM_COLOR="${BYel}"
D_BRANCH_COLOR="${BYel}"
D_CHANGES_COLOR="${Whi}"
D_CMDFAIL_COLOR="${Red}"
D_VIMSHELL_COLOR="${Cya}"

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
	if [ ! -z "$VIMRUNTIME" ]; then
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
	if [ ! -z "$VCPROMPT_EXECUTABLE" ]; then
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

prompt_git() {
	local s=''
	local branchName=''

	# Check if the current directory is in a Git repository.
	if [ $(
		git rev-parse --is-inside-work-tree &> /dev/null
		echo "${?}"
	) == '0' ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

			# Ensure the index is up to date.
			git update-index --really-refresh -q &> /dev/null

			# Check for uncommitted changes in the index.
			if ! $(git diff --quiet --ignore-submodules --cached); then
				s+='+'
			fi

			# Check for unstaged changes.
			if ! $(git diff-files --quiet --ignore-submodules --); then
				s+='!'
			fi

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard)" ]; then
				s+='?'
			fi

			# Check for stashed files.
			if $(git rev-parse --verify refs/stash &> /dev/null); then
				s+='$'
			fi

		fi

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null \
			|| git rev-parse --short HEAD 2> /dev/null \
			|| echo '(unknown)')"

		[ -n "${s}" ] && s=" [${s}]"

		echo -e "${1}${branchName}${Cya}${s}"
	else
		return
	fi
}

# -------------------------------------------------------------- PROMPT OUTPUT
prompt() {
	local LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
	local SAVE_CURSOR='\033[s'
	local RESTORE_CURSOR='\033[u'
	local MOVE_CURSOR_RIGHTMOST='\033[500C'
	local MOVE_CURSOR_5_LEFT='\033[5D'

	if [[ "$OSTYPE" == 'linux'* ]]; then
		PS1="${TITLEBAR}
${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}\
$(safe_battery_charge)${RESTORE_CURSOR}\
${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}\
at ${D_MACHINE_COLOR}\h ${D_INTERMEDIATE_COLOR}\
in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}\
$(prompt_git "$D_INTERMEDIATE_COLOR on $D_GIT_COLOR")\
${LAST_COMMAND_FAILED}\
$(demula_vcprompt)\
$(is_vim_shell)
${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
	else
		PS1="${TITLEBAR}
${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}\
at ${D_MACHINE_COLOR}\h ${D_INTERMEDIATE_COLOR}\
in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}\
$(prompt_git "$D_INTERMEDIATE_COLOR on $D_GIT_COLOR")\
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

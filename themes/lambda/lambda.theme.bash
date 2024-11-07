# shellcheck shell=bash
# shellcheck disable=SC1090,SC2034

function set_prompt {
	local user_color="\[\033[1;31m\]"          # bold red for username
	local at_color="\[\033[1;37m\]"            # bold white for @ symbol
	local host_color="\[\033[1;31m\]"          # bold red for hostname
	local in_color="\[\033[1;37m\]"            # bold white for "in"
	local dir_color="\[\033[1;35m\]"           # bold purple for current working directory
	local git_color="\[\033[1;36m\]"           # bold cyan for Git information
	local time_color="\[\033[1;32m\]"          # bold green for time taken
	local reset_color="\[\033[0m\]"            # reset color
	local prompt_symbol_color="\[\033[1;31m\]" # bold red for the prompt symbol

	local end_time time_taken
	end_time=$(date +%s%3N) # current time in milliseconds
	# shellcheck disable=SC2154
	time_taken=$((end_time - start_time)) # time in milliseconds

	PS1="${user_color}╭─\\u"            # username
	PS1+="${at_color}@${host_color}\\h" # @ symbol and hostname
	PS1+="${in_color} in"               # "in" between hostname and current directory
	PS1+="${dir_color} \\w"             # current working directory

	# Git information (status symbol)
	PS1+=" ${git_color}$(__git_ps1 "[%s]")${reset_color}"

	if [ $time_taken -gt 0 ]; then
		PS1+=" ${time_color}took ${time_taken}ms" # time taken in milliseconds
	fi

	PS1+="\n${prompt_symbol_color}╰─λ${reset_color} " # red color for the prompt symbol, reset color after
}

PROMPT_COMMAND='start_time=$(date +%s%3N); set_prompt'

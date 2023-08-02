# shellcheck shell=bash

# https://pip.pypa.io/en/stable/user_guide/#command-completion
# Of course, you should first install pip, say on Debian:
# sudo apt-get install python3-pip
# If the pip package is installed within virtual environments, say, python managed by pyenv,
# you should first initialize the corresponding environment.
# So that pip3 is in the system's path.
_command_exists pip3 || return

function __bash_it_complete_pip3() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if _command_exists _pip_completion
	then
		complete -o default -F _pip_completion pip3
		_pip_completion "${@}"
	else
		eval "$(pip3 completion --bash)"
		_pip_completion "${@}"
	fi
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}
complete -o default -F __bash_it_complete_pip3 pip3

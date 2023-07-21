# shellcheck shell=bash
# shellcheck disable=SC2016
cite about-plugin
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump). Add `export JUMP_OPTS=("--bind=z")` to change keybinding'

function __init_jump() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if _command_exists jump 
     then
		eval "$(jump shell bash "${JUMP_OPTS[@]}")"
	fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


__init_jump

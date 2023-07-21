#!/bin/bash
#

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Copyright (c) 2014 Docker, Inc

# bash completion for docker-compose
#
# This work is based on the completion for the docker command.
#
# This script provides completion of:
#  - commands and their options
#  - service names
#  - filepaths
#
# To enable the completions either:
#  - place this file in /etc/bash_completion.d
#  or
#  - copy this file to e.g. ~/.docker-compose-completion.sh and add the line
#    below to your .bashrc after bash completion features are loaded
#    . ~/.docker-compose-completion.sh

__docker_compose_previous_extglob_setting=$(shopt -p extglob)
shopt -s extglob

function __docker_compose_q() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	docker-compose 2>/dev/null "${top_level_options[@]}" "${@}"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# Transforms a multiline list of strings into a single line string
# with the words separated by "|".
function __docker_compose_to_alternatives() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local parts=( $1 )
	local IFS='|'
	echo "${parts[*]}"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# Transforms a multiline list of options into an extglob pattern
# suitable for use in case statements.
function __docker_compose_to_extglob() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local extglob=$( __docker_compose_to_alternatives "${1}" )
	echo "@($extglob)"
}

# Determines whether the option passed as the first argument exist on
# the commandline. The option may be a pattern, e.g. `--force|-f`.
function __docker_compose_has_option() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local pattern="${1}"
	for (( i=2; i < $cword; ++i)); do
		if [[ ${words[$i]} =~ ^($pattern)$ ]]  
     then
			return 0
		fi
	done
	return 1
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# Returns `key` if we are currently completing the value of a map option (`key=value`)
# which matches the extglob passed in as an argument.
# This function is needed for key-specific completions.
function __docker_compose_map_key_of_current_option() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
        local glob="${1}"

        local key glob_pos
        if [ "$cur" = "=" ]  
     then        # key= case
                key="$prev"
                glob_pos=$((cword - 2))
        elif [[ $cur == *=* ]]  
     then     # key=value case (OSX)
                key=${cur%=*}
                glob_pos=$((cword - 1))
        elif [ "$prev" = "=" ]  
     then
                key=${words[$cword - 2]}  # key=value case
                glob_pos=$((cword - 3))
        else
                return
        fi

        [ "${words[$glob_pos]}" = "=" ] && ((glob_pos--))  # --option=key=value syntax

        [[ ${words[$glob_pos]} == @($glob) ]] && echo "$key"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# suppress trailing whitespace
function __docker_compose_nospace() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	# compopt is not available in ancient bash versions
	type compopt &>/dev/null && compopt -o nospace
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


# Outputs a list of all defined services, regardless of their running state.
# Arguments for `docker-compose ps` may be passed in order to filter the service list,
# e.g. `status=running`.
function __docker_compose_services() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	__docker_compose_q ps --services "${@}"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# Applies completion of services based on the current value of `$cur`.
# Arguments for `docker-compose ps` may be passed in order to filter the service list,
# see `__docker_compose_services`.
function __docker_compose_complete_services() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	COMPREPLY=( $(compgen -W "$(__docker_compose_services "${@}")" -- "$cur") )
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

# The services for which at least one running container exists
function __docker_compose_complete_running_services() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local names=$(__docker_compose_services --filter status=running)
	COMPREPLY=( $(compgen -W "$names" -- "$cur") )
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_build() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--build-arg)
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_compose_nospace
			return
			;;
		--memory|-m)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--build-arg --compress --force-rm --help --memory -m --no-cache --no-rm --pull --parallel -q --quiet" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services --filter source=build
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_bundle() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--output|-o)
			_filedir
			return
			;;
	esac

	COMPREPLY=( $( compgen -W "--push-images --help --output -o" -- "$cur" ) )
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_config() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--hash)
			if [[ $cur == \\* ]]  
     then
				COMPREPLY=( '\*' )
			else
				COMPREPLY=( $(compgen -W "$(__docker_compose_services) \\\* " -- "$cur") )
			fi
			return
			;;
	esac

	COMPREPLY=( $( compgen -W "--hash --help --quiet -q --resolve-image-digests --services --volumes" -- "$cur" ) )
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_create() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--build --force-recreate --help --no-build --no-recreate" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_docker_compose() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--tlscacert|--tlscert|--tlskey)
			_filedir
			return
			;;
		--file|-f)
			_filedir "y?(a)ml"
			return
			;;
		--log-level)
			COMPREPLY=( $( compgen -W "debug info warning error critical" -- "$cur" ) )
			return
			;;
		--project-directory)
			_filedir -d
			return
			;;
		$(__docker_compose_to_extglob "$daemon_options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$daemon_boolean_options $daemon_options_with_args $top_level_options_with_args --help -h --no-ansi --verbose --version -v" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_down() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--rmi)
			COMPREPLY=( $( compgen -W "all local" -- "$cur" ) )
			return
			;;
		--timeout|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --rmi --timeout -t --volumes -v --remove-orphans" -- "$cur" ) )
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_events() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--json)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --json" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_exec() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--index|--user|-u|--workdir|-w)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "-d --detach --help --index --privileged -T --user -u --workdir -w" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_help() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _docker_compose_images() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --quiet -q" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _docker_compose_kill() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		-s)
			COMPREPLY=( $( compgen -W "SIGHUP SIGINT SIGKILL SIGUSR1 SIGUSR2" -- "$(echo $cur | tr '[:lower:]' '[:upper:]')" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help -s" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_logs() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--tail)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--follow -f --help --no-color --tail --timestamps -t" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_pause() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_port() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--protocol)
			COMPREPLY=( $( compgen -W "tcp udp" -- "$cur" ) )
			return;
			;;
		--index)
			return;
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --index --protocol" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_ps() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local key=$(__docker_compose_map_key_of_current_option '--filter')
	case "$key" in
		source)
			COMPREPLY=( $( compgen -W "build image" -- "${cur##*=}" ) )
			return
			;;
		status)
			COMPREPLY=( $( compgen -W "paused restarting running stopped" -- "${cur##*=}" ) )
			return
			;;
	esac

	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "source status" -S "=" -- "$cur" ) )
			__docker_compose_nospace
			return;
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --filter --help --quiet -q --services" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_pull() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --ignore-pull-failures --include-deps --no-parallel --quiet -q" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services --filter source=image
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_push() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --ignore-push-failures" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_restart() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--timeout|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --timeout -t" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_rm() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help --stop -s -v" -- "$cur" ) )
			;;
		*)
			if __docker_compose_has_option "--stop|-s"  
     then
				__docker_compose_complete_services
			else
				__docker_compose_complete_services --filter status=stopped
			fi
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_run() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		-e)
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_compose_nospace
			return
			;;
		--entrypoint|--label|-l|--name|--user|-u|--volume|-v|--workdir|-w)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach -d --entrypoint -e --help --label -l --name --no-deps --publish -p --rm --service-ports -T --use-aliases --user -u --volume -v --workdir -w" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_scale() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		=)
			COMPREPLY=("$cur")
			return
			;;
		--timeout|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --timeout -t" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $(compgen -S "=" -W "$(__docker_compose_services)" -- "$cur") )
			__docker_compose_nospace
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_start() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services --filter status=stopped
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_stop() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		--timeout|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --timeout -t" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_top() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_running_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_unpause() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services --filter status=paused
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_up() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$prev" in
		=)
			COMPREPLY=("$cur")
			return
			;;
		--exit-code-from)
			__docker_compose_complete_services
			return
			;;
		--scale)
			COMPREPLY=( $(compgen -S "=" -W "$(__docker_compose_services)" -- "$cur") )
			__docker_compose_nospace
			return
			;;
		--timeout|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--abort-on-container-exit --always-recreate-deps --build -d --detach --exit-code-from --force-recreate --help --no-build --no-color --no-deps --no-recreate --no-start --renew-anon-volumes -V --remove-orphans --scale --timeout -t" -- "$cur" ) )
			;;
		*)
			__docker_compose_complete_services
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose_version() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--short" -- "$cur" ) )
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _docker_compose() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local previous_extglob_setting=$(shopt -p extglob)
	shopt -s extglob

	local commands=(
		build
		bundle
		config
		create
		down
		events
		exec
		help
		images
		kill
		logs
		pause
		port
		ps
		pull
		push
		restart
		rm
		run
		scale
		start
		stop
		top
		unpause
		up
		version
	)

	# Options for the docker daemon that have to be passed to secondary calls to
	# docker-compose executed by this script.
	local daemon_boolean_options="
		--skip-hostname-check
		--tls
		--tlsverify
	"
	local daemon_options_with_args="
		--file -f
		--host -H
		--project-directory
		--project-name -p
		--tlscacert
		--tlscert
		--tlskey
	"

	# These options are require special treatment when searching the command.
	local top_level_options_with_args="
		--log-level
	"

	COMPREPLY=()
	local cur prev words cword
	_get_comp_words_by_ref -n : cur prev words cword

	# search subcommand and invoke its handler.
	# special treatment of some top-level options
	local command='docker_compose'
	local top_level_options=()
	local counter=1

	while [ $counter -lt $cword ]; do
		case "${words[$counter]}" in
			$(__docker_compose_to_extglob "$daemon_boolean_options") )
				local opt=${words[counter]}
				top_level_options+=($opt)
				;;
			$(__docker_compose_to_extglob "$daemon_options_with_args") )
				local opt=${words[counter]}
				local arg=${words[++counter]}
				top_level_options+=($opt $arg)
				;;
			$(__docker_compose_to_extglob "$top_level_options_with_args") )
				(( counter++ ))
				;;
			-*)
				;;
			*)
				command="${words[$counter]}"
				break
				;;
		esac
		(( counter++ ))
	done

	local completions_func=_docker_compose_${command//-/_}
	_is_function $completions_func && $completions_func

	eval "$previous_extglob_setting"
	return 0
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

eval "$__docker_compose_previous_extglob_setting"
unset __docker_compose_previous_extglob_setting

complete -F _docker_compose docker-compose docker-compose.exe

#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2119,SC2155,SC2206,SC2207
#
# Shellcheck ignore list:
#  - SC2016: Expressions don't expand in single quotes, use double quotes for that.
#  - SC2119: Use foo "$@" if function's $1 should mean script's $1.
#  - SC2155: Declare and assign separately to avoid masking return values.
#  - SC2206: Quote to prevent word splitting, or split robustly with mapfile or read -a.
#  - SC2207: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
#
# You can find more details for each warning at the following page:
#    https://github.com/koalaman/shellcheck/wiki/<SCXXXX>
#
# bash completion file for core docker commands
#
# This script provides completion of:
#  - commands and their options
#  - container ids and names
#  - image repos and tags
#  - filepaths
#
# To enable the completions either:
#  - place this file in /etc/bash_completion.d
#  or
#  - copy this file to e.g. ~/.docker-completion.sh and add the line
#    below to your .bashrc after bash completion features are loaded
#    . ~/.docker-completion.sh
#
# Configuration:
#
# For several commands, the amount of completions can be configured by
# setting environment variables.
#
# DOCKER_COMPLETION_SHOW_CONFIG_IDS
# DOCKER_COMPLETION_SHOW_CONTAINER_IDS
# DOCKER_COMPLETION_SHOW_NETWORK_IDS
# DOCKER_COMPLETION_SHOW_NODE_IDS
# DOCKER_COMPLETION_SHOW_PLUGIN_IDS
# DOCKER_COMPLETION_SHOW_SECRET_IDS
# DOCKER_COMPLETION_SHOW_SERVICE_IDS
#   "no"  - Show names only (default)
#   "yes" - Show names and ids
#
# You can tailor completion for the "events", "history", "inspect", "run",
# "rmi" and "save" commands by settings the following environment
# variables:
#
# DOCKER_COMPLETION_SHOW_IMAGE_IDS
#   "none" - Show names only (default)
#   "non-intermediate" - Show names and ids, but omit intermediate image IDs
#   "all" - Show names and ids, including intermediate image IDs
#
# DOCKER_COMPLETION_SHOW_TAGS
#   "yes" - include tags in completion options (default)
#   "no"  - don't include tags in completion options

#
# Note:
# Currently, the completions will not work if the docker daemon is not
# bound to the default communication port/socket
# If the docker daemon is using a unix socket for communication your user
# must have access to the socket for the completions to function correctly
#
# Note for developers:
# Please arrange options sorted alphabetically by long name with the short
# options immediately following their corresponding long form.
# This order should be applied to lists, alternatives and code blocks.

__docker_previous_extglob_setting=$(shopt -p extglob)
shopt -s extglob

__docker_q() {
	docker ${host:+--host "$host"} ${config:+--config "$config"} ${context:+--context "$context"} 2>/dev/null "$@"
}

# __docker_configs returns a list of configs. Additional options to
# `docker config ls` may be specified in order to filter the list, e.g.
# `__docker_configs --filter label=stage=production`.
# By default, only names are returned.
# Set DOCKER_COMPLETION_SHOW_CONFIG_IDS=yes to also complete IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
__docker_configs() {
	local format
	if [ "$1" = "--id" ] ; then
		format='{{.ID}}'
		shift
	elif [ "$1" = "--name" ] ; then
		format='{{.Name}}'
		shift
	elif [ "$DOCKER_COMPLETION_SHOW_CONFIG_IDS" = yes ] ; then
		format='{{.ID}} {{.Name}}'
	else
		format='{{.Name}}'
	fi

	__docker_q config ls --format "$format" "$@"
}

# __docker_complete_configs applies completion of configs based on the current value
# of `$cur` or the value of the optional first option `--cur`, if given.
__docker_complete_configs() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_configs "$@")" -- "$current") )
}

# __docker_containers returns a list of containers. Additional options to
# `docker ps` may be specified in order to filter the list, e.g.
# `__docker_containers --filter status=running`
# By default, only names are returned.
# Set DOCKER_COMPLETION_SHOW_CONTAINER_IDS=yes to also complete IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
__docker_containers() {
	local format
	if [ "$1" = "--id" ] ; then
		format='{{.ID}}'
		shift
	elif [ "$1" = "--name" ] ; then
		format='{{.Names}}'
		shift
	elif [ "${DOCKER_COMPLETION_SHOW_CONTAINER_IDS}" = yes ] ; then
		format='{{.ID}} {{.Names}}'
	else
		format='{{.Names}}'
	fi
	__docker_q ps --format "$format" "$@"
}

# __docker_complete_containers applies completion of containers based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_containers`.
__docker_complete_containers() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_containers "$@")" -- "$current") )
}

__docker_complete_containers_all() {
	__docker_complete_containers "$@" --all
}

# shellcheck disable=SC2120
__docker_complete_containers_removable() {
	__docker_complete_containers "$@" --filter status=created --filter status=exited
}

__docker_complete_containers_running() {
	__docker_complete_containers "$@" --filter status=running
}

# shellcheck disable=SC2120
__docker_complete_containers_stoppable() {
	__docker_complete_containers "$@" --filter status=running --filter status=paused
}

# shellcheck disable=SC2120
__docker_complete_containers_stopped() {
	__docker_complete_containers "$@" --filter status=exited
}

# shellcheck disable=SC2120
__docker_complete_containers_unpauseable() {
	__docker_complete_containers "$@" --filter status=paused
}

__docker_complete_container_names() {
	local containers=( $(__docker_q ps -aq --no-trunc) )
	local names=( $(__docker_q inspect --format '{{.Name}}' "${containers[@]}") )
	names=( "${names[@]#/}" ) # trim off the leading "/" from the container names
	COMPREPLY=( $(compgen -W "${names[*]}" -- "$cur") )
}

__docker_complete_container_ids() {
	local containers=( $(__docker_q ps -aq) )
	COMPREPLY=( $(compgen -W "${containers[*]}" -- "$cur") )
}

# __docker_contexts returns a list of contexts without the special "default" context.
# Completions may be added with `--add`, e.g. `--add default`.
__docker_contexts() {
	local add=()
	while true ; do
		case "$1" in
			--add)
				add+=("$2")
				shift 2
				;;
			*)
				break
				;;
		esac
	done
	__docker_q context ls -q
	echo "${add[@]}"
}

__docker_complete_contexts() {
	local contexts=( $(__docker_contexts "$@") )
	COMPREPLY=( $(compgen -W "${contexts[*]}" -- "$cur") )
}


# __docker_images returns a list of images. For each image, up to three representations
# can be generated: the repository (e.g. busybox), repository:tag (e.g. busybox:latest)
# and the ID (e.g. sha256:ee22cbbd4ea3dff63c86ba60c7691287c321e93adfc1009604eb1dde7ec88645).
#
# The optional arguments `--repo`, `--tag` and `--id` select the representations that
# may be returned. Whether or not a particular representation is actually returned
# depends on the user's customization through several environment variables:
# - image IDs are only shown if DOCKER_COMPLETION_SHOW_IMAGE_IDS=all|non-intermediate.
# - tags can be excluded by setting DOCKER_COMPLETION_SHOW_TAGS=no.
# - repositories are always shown.
#
# In cases where an exact image specification is needed, `--force-tag` can be used.
# It ignores DOCKER_COMPLETION_SHOW_TAGS and only lists valid repository:tag combinations,
# avoiding repository names that would default to a potentially missing default tag.
#
# Additional arguments to `docker image ls` may be specified in order to filter the list,
# e.g. `__docker_images --filter dangling=true`.
#
__docker_images() {
	local repo_format='{{.Repository}}'
	local tag_format='{{.Repository}}:{{.Tag}}'
	local id_format='{{.ID}}'
	local all
	local format

	if [ "$DOCKER_COMPLETION_SHOW_IMAGE_IDS" = "all" ] ; then
		all='--all'
	fi

	while true ; do
		case "$1" in
			--repo)
				format+="$repo_format\n"
				shift
				;;
			--tag)
				if [ "${DOCKER_COMPLETION_SHOW_TAGS:-yes}" = "yes" ]; then
					format+="$tag_format\n"
				fi
				shift
				;;
			--id)
				if [[ $DOCKER_COMPLETION_SHOW_IMAGE_IDS =~ ^(all|non-intermediate)$ ]] ; then
					format+="$id_format\n"
				fi
				shift
				;;
			--force-tag)
				# like `--tag` but ignores environment setting
				format+="$tag_format\n"
				shift
				;;
			*)
				break
				;;
		esac
	done

	__docker_q image ls --no-trunc --format "${format%\\n}" $all "$@" | grep -v '<none>$'
}

# __docker_complete_images applies completion of images based on the current value of `$cur` or
# the value of the optional first option `--cur`, if given.
# See __docker_images for customization of the returned items.
__docker_complete_images() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_images "$@")" -- "$current") )
	__ltrim_colon_completions "$current"
}

# __docker_networks returns a list of all networks. Additional options to
# `docker network ls` may be specified in order to filter the list, e.g.
# `__docker_networks --filter type=custom`
# By default, only names are returned.
# Set DOCKER_COMPLETION_SHOW_NETWORK_IDS=yes to also complete IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
__docker_networks() {
	local format
	if [ "$1" = "--id" ] ; then
		format='{{.ID}}'
		shift
	elif [ "$1" = "--name" ] ; then
		format='{{.Name}}'
		shift
	elif [ "${DOCKER_COMPLETION_SHOW_NETWORK_IDS}" = yes ] ; then
		format='{{.ID}} {{.Name}}'
	else
		format='{{.Name}}'
	fi
	__docker_q network ls --format "$format" "$@"
}

# __docker_complete_networks applies completion of networks based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_networks`.
__docker_complete_networks() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_networks "$@")" -- "$current") )
}

__docker_complete_containers_in_network() {
	local containers=($(__docker_q network inspect -f '{{range $i, $c := .Containers}}{{$i}} {{$c.Name}} {{end}}' "$1"))
	COMPREPLY=( $(compgen -W "${containers[*]}" -- "$cur") )
}

# __docker_volumes returns a list of all volumes. Additional options to
# `docker volume ls` may be specified in order to filter the list, e.g.
# `__docker_volumes --filter dangling=true`
# Because volumes do not have IDs, this function does not distinguish between
# IDs and names.
__docker_volumes() {
	__docker_q volume ls -q "$@"
}

# __docker_complete_volumes applies completion of volumes based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_volumes`.
__docker_complete_volumes() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_volumes "$@")" -- "$current") )
}

# __docker_plugins_bundled returns a list of all plugins of a given type.
# The type has to be specified with the mandatory option `--type`.
# Valid types are: Network, Volume, Authorization.
# Completions may be added or removed with `--add` and `--remove`
# This function only deals with plugins that come bundled with Docker.
# For plugins managed by `docker plugin`, see `__docker_plugins_installed`.
__docker_plugins_bundled() {
	local type add=() remove=()
	while true ; do
		case "$1" in
			--type)
				type="$2"
				shift 2
				;;
			--add)
				add+=("$2")
				shift 2
				;;
			--remove)
				remove+=("$2")
				shift 2
				;;
			*)
				break
				;;
		esac
	done

	local plugins=($(__docker_q info --format "{{range \$i, \$p := .Plugins.$type}}{{.}} {{end}}"))
	for del in "${remove[@]}" ; do
		plugins=(${plugins[@]/$del/})
	done
	echo "${plugins[@]}" "${add[@]}"
}

# __docker_complete_plugins_bundled applies completion of plugins based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# The plugin type has to be specified with the next option `--type`.
# This function only deals with plugins that come bundled with Docker.
# For completion of plugins managed by `docker plugin`, see
# `__docker_complete_plugins_installed`.
__docker_complete_plugins_bundled() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_plugins_bundled "$@")" -- "$current") )
}

# __docker_plugins_installed returns a list of all plugins that were installed with
# the Docker plugin API.
# By default, only names are returned.
# Set DOCKER_COMPLETION_SHOW_PLUGIN_IDS=yes to also complete IDs.
# Additional options to `docker plugin ls` may be specified in order to filter the list,
# e.g. `__docker_plugins_installed --filter enabled=true`
# For built-in pugins, see `__docker_plugins_bundled`.
__docker_plugins_installed() {
	local format
	if [ "$DOCKER_COMPLETION_SHOW_PLUGIN_IDS" = yes ] ; then
		format='{{.ID}} {{.Name}}'
	else
		format='{{.Name}}'
	fi
	__docker_q plugin ls --format "$format" "$@"
}

# __docker_complete_plugins_installed applies completion of plugins that were installed
# with the Docker plugin API, based on the current value of `$cur` or the value of
# the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_plugins_installed`.
# For completion of built-in pugins, see `__docker_complete_plugins_bundled`.
__docker_complete_plugins_installed() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_plugins_installed "$@")" -- "$current") )
}

__docker_runtimes() {
	__docker_q info | sed -n 's/^Runtimes: \(.*\)/\1/p'
}

__docker_complete_runtimes() {
	COMPREPLY=( $(compgen -W "$(__docker_runtimes)" -- "$cur") )
}

# __docker_secrets returns a list of secrets. Additional options to
# `docker secret ls` may be specified in order to filter the list, e.g.
# `__docker_secrets --filter label=stage=production`
# By default, only names are returned.
# Set DOCKER_COMPLETION_SHOW_SECRET_IDS=yes to also complete IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
__docker_secrets() {
	local format
	if [ "$1" = "--id" ] ; then
		format='{{.ID}}'
		shift
	elif [ "$1" = "--name" ] ; then
		format='{{.Name}}'
		shift
	elif [ "$DOCKER_COMPLETION_SHOW_SECRET_IDS" = yes ] ; then
		format='{{.ID}} {{.Name}}'
	else
		format='{{.Name}}'
	fi

	__docker_q secret ls --format "$format" "$@"
}

# __docker_complete_secrets applies completion of secrets based on the current value
# of `$cur` or the value of the optional first option `--cur`, if given.
__docker_complete_secrets() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_secrets "$@")" -- "$current") )
}

# __docker_stacks returns a list of all stacks.
__docker_stacks() {
	__docker_q stack ls | awk 'NR>1 {print $1}'
}

# __docker_complete_stacks applies completion of stacks based on the current value
# of `$cur` or the value of the optional first option `--cur`, if given.
__docker_complete_stacks() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_stacks "$@")" -- "$current") )
}

# __docker_nodes returns a list of all nodes. Additional options to
# `docker node ls` may be specified in order to filter the list, e.g.
# `__docker_nodes --filter role=manager`
# By default, only node names are returned.
# Set DOCKER_COMPLETION_SHOW_NODE_IDS=yes to also complete node IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
# Completions may be added with `--add`, e.g. `--add self`.
__docker_nodes() {
	local format
	if [ "$DOCKER_COMPLETION_SHOW_NODE_IDS" = yes ] ; then
		format='{{.ID}} {{.Hostname}}'
	else
		format='{{.Hostname}}'
	fi

	local add=()

	while true ; do
		case "$1" in
			--id)
				format='{{.ID}}'
				shift
				;;
			--name)
				format='{{.Hostname}}'
				shift
				;;
			--add)
				add+=("$2")
				shift 2
				;;
			*)
				break
				;;
		esac
	done

	echo "$(__docker_q node ls --format "$format" "$@")" "${add[@]}"
}

# __docker_complete_nodes applies completion of nodes based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_nodes`.
__docker_complete_nodes() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_nodes "$@")" -- "$current") )
}

# __docker_services returns a list of all services. Additional options to
# `docker service ls` may be specified in order to filter the list, e.g.
# `__docker_services --filter name=xxx`
# By default, only node names are returned.
# Set DOCKER_COMPLETION_SHOW_SERVICE_IDS=yes to also complete IDs.
# An optional first option `--id|--name` may be used to limit the
# output to the IDs or names of matching items. This setting takes
# precedence over the environment setting.
__docker_services() {
	local fields='$2'  # default: service name only
	[ "${DOCKER_COMPLETION_SHOW_SERVICE_IDS}" = yes ] && fields='$1,$2' # ID & name

	if [ "$1" = "--id" ] ; then
		fields='$1' # IDs only
		shift
	elif [ "$1" = "--name" ] ; then
		fields='$2' # names only
		shift
	fi
        __docker_q service ls "$@" | awk "NR>1 {print $fields}"
}

# __docker_complete_services applies completion of services based on the current
# value of `$cur` or the value of the optional first option `--cur`, if given.
# Additional filters may be appended, see `__docker_services`.
__docker_complete_services() {
	local current="$cur"
	if [ "$1" = "--cur" ] ; then
		current="$2"
		shift 2
	fi
	COMPREPLY=( $(compgen -W "$(__docker_services "$@")" -- "$current") )
}

# __docker_tasks returns a list of all task IDs.
__docker_tasks() {
	__docker_q service ps --format '{{.ID}}' ""
}

# __docker_complete_services_and_tasks applies completion of services and task IDs.
# shellcheck disable=SC2120
__docker_complete_services_and_tasks() {
	COMPREPLY=( $(compgen -W "$(__docker_services "$@") $(__docker_tasks)" -- "$cur") )
}

# __docker_append_to_completions appends the word passed as an argument to every
# word in `$COMPREPLY`.
# Normally you do this with `compgen -S` while generating the completions.
# This function allows you to append a suffix later. It allows you to use
# the __docker_complete_XXX functions in cases where you need a suffix.
__docker_append_to_completions() {
	COMPREPLY=( ${COMPREPLY[@]/%/"$1"} )
}

# __docker_fetch_info fetches information about the configured Docker server and updates
# several variables with the results.
# The result is cached for the duration of one invocation of bash completion.
__docker_fetch_info() {
	if [ -z "$info_fetched" ] ; then
		read -r client_experimental server_experimental server_os <<< "$(__docker_q version -f '{{.Client.Experimental}} {{.Server.Experimental}} {{.Server.Os}}')"
		info_fetched=true
	fi
}

# __docker_client_is_experimental tests whether the Docker cli is configured to support
# experimental features. If so, the function exits with 0 (true).
# Otherwise, or if the result cannot be determined, the exit value is 1 (false).
__docker_client_is_experimental() {
	__docker_fetch_info
	[ "$client_experimental" = "true" ]
}

# __docker_server_is_experimental tests whether the currently configured Docker
# server runs in experimental mode. If so, the function exits with 0 (true).
# Otherwise, or if the result cannot be determined, the exit value is 1 (false).
__docker_server_is_experimental() {
	__docker_fetch_info
	[ "$server_experimental" = "true" ]
}

# __docker_server_os_is tests whether the currently configured Docker server runs
# on the operating system passed in as the first argument.
# Known operating systems: linux, windows.
__docker_server_os_is() {
	local expected_os="$1"
	__docker_fetch_info
	[ "$server_os" = "$expected_os" ]
}

# __docker_stack_orchestrator_is tests whether the client is configured to use
# the orchestrator that is passed in as the first argument.
__docker_stack_orchestrator_is() {
	case "$1" in
		kubernetes)
			if [ -z "$stack_orchestrator_is_kubernetes" ] ; then
				__docker_q stack ls --help | grep -qe --namespace
				stack_orchestrator_is_kubernetes=$?
			fi
			return $stack_orchestrator_is_kubernetes
			;;
		swarm)
			if [ -z "$stack_orchestrator_is_swarm" ] ; then
				__docker_q stack deploy --help | grep -qe "with-registry-auth"
				stack_orchestrator_is_swarm=$?
			fi
			return $stack_orchestrator_is_swarm
			;;
		*)
			return 1
			;;

	esac
}

# __docker_pos_first_nonflag finds the position of the first word that is neither
# option nor an option's argument. If there are options that require arguments,
# you should pass a glob describing those options, e.g. "--option1|-o|--option2"
# Use this function to restrict completions to exact positions after the argument list.
__docker_pos_first_nonflag() {
	local argument_flags=$1

	local counter=$((${subcommand_pos:-${command_pos}} + 1))
	while [ "$counter" -le "$cword" ]; do
		if [ -n "$argument_flags" ] && eval "case '${words[$counter]}' in $argument_flags) true ;; *) false ;; esac"; then
			(( counter++ ))
			# eat "=" in case of --option=arg syntax
			[ "${words[$counter]}" = "=" ] && (( counter++ ))
		else
			case "${words[$counter]}" in
				-*)
					;;
				*)
					break
					;;
			esac
		fi

		# Bash splits words at "=", retaining "=" as a word, examples:
		# "--debug=false" => 3 words, "--log-opt syslog-facility=daemon" => 4 words
		while [ "${words[$counter + 1]}" = "=" ] ; do
			counter=$(( counter + 2))
		done

		(( counter++ ))
	done

	echo $counter
}

# __docker_map_key_of_current_option returns `key` if we are currently completing the
# value of a map option (`key=value`) which matches the extglob given as an argument.
# This function is needed for key-specific completions.
__docker_map_key_of_current_option() {
	local glob="$1"

	local key glob_pos
	if [ "$cur" = "=" ] ; then        # key= case
		key="$prev"
		glob_pos=$((cword - 2))
	elif [[ $cur == *=* ]] ; then     # key=value case (OSX)
		key=${cur%=*}
		glob_pos=$((cword - 1))
	elif [ "$prev" = "=" ] ; then
		key=${words[$cword - 2]}  # key=value case
		glob_pos=$((cword - 3))
	else
		return
	fi

	[ "${words[$glob_pos]}" = "=" ] && ((glob_pos--))  # --option=key=value syntax

	[[ ${words[$glob_pos]} == @($glob) ]] && echo "$key"
}

# __docker_value_of_option returns the value of the first option matching `option_glob`.
# Valid values for `option_glob` are option names like `--log-level` and globs like
# `--log-level|-l`
# Only positions between the command and the current word are considered.
__docker_value_of_option() {
	local option_extglob=$(__docker_to_extglob "$1")

	local counter=$((command_pos + 1))
	while [ "$counter" -lt "$cword" ]; do
		case ${words[$counter]} in
			$option_extglob )
				echo "${words[$counter + 1]}"
				break
				;;
		esac
		(( counter++ ))
	done
}

# __docker_to_alternatives transforms a multiline list of strings into a single line
# string with the words separated by `|`.
# This is used to prepare arguments to __docker_pos_first_nonflag().
__docker_to_alternatives() {
	local parts=( $1 )
	local IFS='|'
	echo "${parts[*]}"
}

# __docker_to_extglob transforms a multiline list of options into an extglob pattern
# suitable for use in case statements.
__docker_to_extglob() {
	local extglob=$( __docker_to_alternatives "$1" )
	echo "@($extglob)"
}

# __docker_subcommands processes subcommands
# Locates the first occurrence of any of the subcommands contained in the
# first argument. In case of a match, calls the corresponding completion
# function and returns 0.
# If no match is found, 1 is returned. The calling function can then
# continue processing its completion.
#
# TODO if the preceding command has options that accept arguments and an
# argument is equal ot one of the subcommands, this is falsely detected as
# a match.
__docker_subcommands() {
	local subcommands="$1"

	local counter=$((command_pos + 1))
	while [ "$counter" -lt "$cword" ]; do
		case "${words[$counter]}" in
			$(__docker_to_extglob "$subcommands") )
				subcommand_pos=$counter
				local subcommand=${words[$counter]}
				local completions_func=_docker_${command}_${subcommand//-/_}
				declare -F "$completions_func" >/dev/null && "$completions_func"
				return 0
				;;
		esac
		(( counter++ ))
	done
	return 1
}

# __docker_nospace suppresses trailing whitespace
__docker_nospace() {
	# compopt is not available in ancient bash versions
	type compopt &>/dev/null && compopt -o nospace
}

__docker_complete_resolved_hostname() {
	command -v host >/dev/null 2>&1 || return
	COMPREPLY=( $(host 2>/dev/null "${cur%:}" | awk '/has address/ {print $4}') )
}

# __docker_local_interfaces returns a list of the names and addresses of all
# local network interfaces.
# If `--ip-only` is passed as a first argument, only addresses are returned.
__docker_local_interfaces() {
	command -v ip >/dev/null 2>&1 || return

	local format
	if [ "$1" = "--ip-only" ] ; then
		format='\1'
		shift
	else
		 format='\1 \2'
	fi

	ip addr show scope global 2>/dev/null | sed -n "s| \+inet \([0-9.]\+\).* \([^ ]\+\)|$format|p"
}

# __docker_complete_local_interfaces applies completion of the names and addresses of all
# local network interfaces based on the current value of `$cur`.
# An additional value can be added to the possible completions with an `--add` argument.
__docker_complete_local_interfaces() {
	local additional_interface
	if [ "$1" = "--add" ] ; then
		additional_interface="$2"
		shift 2
	fi

	COMPREPLY=( $( compgen -W "$(__docker_local_interfaces "$@") $additional_interface" -- "$cur" ) )
}

# __docker_complete_local_ips applies completion of the addresses of all local network
# interfaces based on the current value of `$cur`.
__docker_complete_local_ips() {
	__docker_complete_local_interfaces --ip-only
}

# __docker_complete_capabilities_addable completes Linux capabilities which are
# not granted by default and may be added.
# see https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities
__docker_complete_capabilities_addable() {
	COMPREPLY=( $( compgen -W "
		ALL
		AUDIT_CONTROL
		BLOCK_SUSPEND
		DAC_READ_SEARCH
		IPC_LOCK
		IPC_OWNER
		LEASE
		LINUX_IMMUTABLE
		MAC_ADMIN
		MAC_OVERRIDE
		NET_ADMIN
		NET_BROADCAST
		SYS_ADMIN
		SYS_BOOT
		SYSLOG
		SYS_MODULE
		SYS_NICE
		SYS_PACCT
		SYS_PTRACE
		SYS_RAWIO
		SYS_RESOURCE
		SYS_TIME
		SYS_TTY_CONFIG
		WAKE_ALARM
	" -- "$cur" ) )
}

# __docker_complete_capabilities_droppable completes Linux capability options which are
# allowed by default and can be dropped.
# see https://docs.docker.com/engine/reference/run/#/runtime-privilege-and-linux-capabilities
__docker_complete_capabilities_droppable() {
	COMPREPLY=( $( compgen -W "
		ALL
		AUDIT_WRITE
		CHOWN
		DAC_OVERRIDE
		FOWNER
		FSETID
		KILL
		MKNOD
		NET_BIND_SERVICE
		NET_RAW
		SETFCAP
		SETGID
		SETPCAP
		SETUID
		SYS_CHROOT
	" -- "$cur" ) )
}

__docker_complete_detach_keys() {
	case "$prev" in
		--detach-keys)
			case "$cur" in
				*,)
					COMPREPLY=( $( compgen -W "${cur}ctrl-" -- "$cur" ) )
					;;
				*)
					COMPREPLY=( $( compgen -W "ctrl-" -- "$cur" ) )
					;;
			esac

			__docker_nospace
			return
			;;
	esac
	return 1
}

__docker_complete_isolation() {
	COMPREPLY=( $( compgen -W "default hyperv process" -- "$cur" ) )
}

__docker_complete_log_drivers() {
	COMPREPLY=( $( compgen -W "
		awslogs
		etwlogs
		fluentd
		gcplogs
		gelf
		journald
		json-file
		local
		logentries
		none
		splunk
		syslog
	" -- "$cur" ) )
}

__docker_complete_log_options() {
	# see repository docker/docker.github.io/engine/admin/logging/

	# really global options, defined in https://github.com/moby/moby/blob/master/daemon/logger/factory.go
	local common_options1="max-buffer-size mode"
	# common options defined in https://github.com/moby/moby/blob/master/daemon/logger/loginfo.go
	# but not implemented in all log drivers
	local common_options2="env env-regex labels"

	# awslogs does not implement the $common_options2.
	local awslogs_options="$common_options1 awslogs-create-group awslogs-credentials-endpoint awslogs-datetime-format awslogs-group awslogs-multiline-pattern awslogs-region awslogs-stream tag"

	local fluentd_options="$common_options1 $common_options2 fluentd-address fluentd-async-connect fluentd-buffer-limit fluentd-retry-wait fluentd-max-retries fluentd-sub-second-precision tag"
	local gcplogs_options="$common_options1 $common_options2 gcp-log-cmd gcp-meta-id gcp-meta-name gcp-meta-zone gcp-project"
	local gelf_options="$common_options1 $common_options2 gelf-address gelf-compression-level gelf-compression-type gelf-tcp-max-reconnect gelf-tcp-reconnect-delay tag"
	local journald_options="$common_options1 $common_options2 tag"
	local json_file_options="$common_options1 $common_options2 compress max-file max-size"
	local local_options="$common_options1 compress max-file max-size"
	local logentries_options="$common_options1 $common_options2 line-only logentries-token tag"
	local splunk_options="$common_options1 $common_options2 splunk-caname splunk-capath splunk-format splunk-gzip splunk-gzip-level splunk-index splunk-insecureskipverify splunk-source splunk-sourcetype splunk-token splunk-url splunk-verify-connection tag"
	local syslog_options="$common_options1 $common_options2 syslog-address syslog-facility syslog-format syslog-tls-ca-cert syslog-tls-cert syslog-tls-key syslog-tls-skip-verify tag"

	local all_options="$fluentd_options $gcplogs_options $gelf_options $journald_options $logentries_options $json_file_options $syslog_options $splunk_options"

	case $(__docker_value_of_option --log-driver) in
		'')
			COMPREPLY=( $( compgen -W "$all_options" -S = -- "$cur" ) )
			;;
		awslogs)
			COMPREPLY=( $( compgen -W "$awslogs_options" -S = -- "$cur" ) )
			;;
		fluentd)
			COMPREPLY=( $( compgen -W "$fluentd_options" -S = -- "$cur" ) )
			;;
		gcplogs)
			COMPREPLY=( $( compgen -W "$gcplogs_options" -S = -- "$cur" ) )
			;;
		gelf)
			COMPREPLY=( $( compgen -W "$gelf_options" -S = -- "$cur" ) )
			;;
		journald)
			COMPREPLY=( $( compgen -W "$journald_options" -S = -- "$cur" ) )
			;;
		json-file)
			COMPREPLY=( $( compgen -W "$json_file_options" -S = -- "$cur" ) )
			;;
		local)
			COMPREPLY=( $( compgen -W "$local_options" -S = -- "$cur" ) )
			;;
		logentries)
			COMPREPLY=( $( compgen -W "$logentries_options" -S = -- "$cur" ) )
			;;
		syslog)
			COMPREPLY=( $( compgen -W "$syslog_options" -S = -- "$cur" ) )
			;;
		splunk)
			COMPREPLY=( $( compgen -W "$splunk_options" -S = -- "$cur" ) )
			;;
		*)
			return
			;;
	esac

	__docker_nospace
}

__docker_complete_log_driver_options() {
	local key=$(__docker_map_key_of_current_option '--log-opt')
	case "$key" in
		awslogs-create-group)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		awslogs-credentials-endpoint)
			COMPREPLY=( $( compgen -W "/" -- "${cur##*=}" ) )
			__docker_nospace
			return
			;;
		compress|fluentd-async-connect)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		fluentd-sub-second-precision)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		gelf-address)
			COMPREPLY=( $( compgen -W "tcp udp" -S "://" -- "${cur##*=}" ) )
			__docker_nospace
			return
			;;
		gelf-compression-level)
			COMPREPLY=( $( compgen -W "1 2 3 4 5 6 7 8 9" -- "${cur##*=}" ) )
			return
			;;
		gelf-compression-type)
			COMPREPLY=( $( compgen -W "gzip none zlib" -- "${cur##*=}" ) )
			return
			;;
		line-only)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		mode)
			COMPREPLY=( $( compgen -W "blocking non-blocking" -- "${cur##*=}" ) )
			return
			;;
		syslog-address)
			COMPREPLY=( $( compgen -W "tcp:// tcp+tls:// udp:// unix://" -- "${cur##*=}" ) )
			__docker_nospace
			__ltrim_colon_completions "${cur}"
			return
			;;
		syslog-facility)
			COMPREPLY=( $( compgen -W "
				auth
				authpriv
				cron
				daemon
				ftp
				kern
				local0
				local1
				local2
				local3
				local4
				local5
				local6
				local7
				lpr
				mail
				news
				syslog
				user
				uucp
			" -- "${cur##*=}" ) )
			return
			;;
		syslog-format)
			COMPREPLY=( $( compgen -W "rfc3164 rfc5424 rfc5424micro" -- "${cur##*=}" ) )
			return
			;;
		syslog-tls-ca-cert|syslog-tls-cert|syslog-tls-key)
			_filedir
			return
			;;
		syslog-tls-skip-verify)
			COMPREPLY=( $( compgen -W "true" -- "${cur##*=}" ) )
			return
			;;
		splunk-url)
			COMPREPLY=( $( compgen -W "http:// https://" -- "${cur##*=}" ) )
			__docker_nospace
			__ltrim_colon_completions "${cur}"
			return
			;;
		splunk-gzip|splunk-insecureskipverify|splunk-verify-connection)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		splunk-format)
			COMPREPLY=( $( compgen -W "inline json raw" -- "${cur##*=}" ) )
			return
			;;
	esac
	return 1
}

__docker_complete_log_levels() {
	COMPREPLY=( $( compgen -W "debug info warn error fatal" -- "$cur" ) )
}

__docker_complete_restart() {
	case "$prev" in
		--restart)
			case "$cur" in
				on-failure:*)
					;;
				*)
					COMPREPLY=( $( compgen -W "always no on-failure on-failure: unless-stopped" -- "$cur") )
					;;
			esac
			return
			;;
	esac
	return 1
}

# __docker_complete_signals returns a subset of the available signals that is most likely
# relevant in the context of docker containers
__docker_complete_signals() {
	local signals=(
		SIGCONT
		SIGHUP
		SIGINT
		SIGKILL
		SIGQUIT
		SIGSTOP
		SIGTERM
		SIGUSR1
		SIGUSR2
	)
	COMPREPLY=( $( compgen -W "${signals[*]} ${signals[*]#SIG}" -- "$( echo "$cur" | tr '[:lower:]' '[:upper:]')" ) )
}

__docker_complete_stack_orchestrator_options() {
	case "$prev" in
		--kubeconfig)
			_filedir
			return 0
			;;
		--namespace)
			return 0
			;;
		--orchestrator)
			COMPREPLY=( $( compgen -W "all kubernetes swarm" -- "$cur") )
			return 0
			;;
	esac
	return 1
}

__docker_complete_user_group() {
	if [[ $cur == *:* ]] ; then
		COMPREPLY=( $(compgen -g -- "${cur#*:}") )
	else
		COMPREPLY=( $(compgen -u -S : -- "$cur") )
		__docker_nospace
	fi
}

_docker_docker() {
	# global options that may appear after the docker command
	local boolean_options="
		$global_boolean_options
		--help
		--version -v
	"

	case "$prev" in
		--config)
			_filedir -d
			return
			;;
		--context|-c)
			__docker_complete_contexts
			return
			;;
		--log-level|-l)
			__docker_complete_log_levels
			return
			;;
		$(__docker_to_extglob "$global_options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$boolean_options $global_options_with_args" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "$(__docker_to_extglob "$global_options_with_args")" )
			if [ "$cword" -eq "$counter" ]; then
				__docker_client_is_experimental && commands+=(${experimental_client_commands[*]})
				__docker_server_is_experimental && commands+=(${experimental_server_commands[*]})
				COMPREPLY=( $( compgen -W "${commands[*]} help" -- "$cur" ) )
			fi
			;;
	esac
}

_docker_attach() {
	_docker_container_attach
}

_docker_build() {
	_docker_image_build
}


_docker_builder() {
	local subcommands="
		prune
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_builder_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -S = -W "description id inuse parent private shared type until unused-for" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--keep-storage)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --filter --force -f --help --keep-storage" -- "$cur" ) )
			;;
	esac
}

_docker_checkpoint() {
	local subcommands="
		create
		ls
		rm
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_checkpoint_create() {
	case "$prev" in
		--checkpoint-dir)
			_filedir -d
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--checkpoint-dir --help --leave-running" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--checkpoint-dir')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_checkpoint_ls() {
	case "$prev" in
		--checkpoint-dir)
			_filedir -d
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--checkpoint-dir --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--checkpoint-dir')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_checkpoint_rm() {
	case "$prev" in
		--checkpoint-dir)
			_filedir -d
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--checkpoint-dir --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--checkpoint-dir')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				COMPREPLY=( $( compgen -W "$(__docker_q checkpoint ls "$prev" | sed 1d)" -- "$cur" ) )
			fi
			;;
	esac
}


_docker_config() {
	local subcommands="
		create
		inspect
		ls
		rm
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_config_create() {
	case "$prev" in
		--label|-l)
			return
			;;
		--template-driver)
			COMPREPLY=( $( compgen -W "golang" -- "$cur" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --label -l --template-driver" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--label|-l|--template-driver')
			if [ "$cword" -eq "$((counter + 1))" ]; then
				_filedir
			fi
			;;
	esac
}

_docker_config_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --pretty" -- "$cur" ) )
			;;
		*)
			__docker_complete_configs
			;;
	esac
}

_docker_config_list() {
	_docker_config_ls
}

_docker_config_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		id)
			__docker_complete_configs --cur "${cur##*=}" --id
			return
			;;
		name)
			__docker_complete_configs --cur "${cur##*=}" --name
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "id label name" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format --filter -f --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_config_remove() {
	_docker_config_rm
}

_docker_config_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_configs
			;;
	esac
}


_docker_container() {
	local subcommands="
		attach
		commit
		cp
		create
		diff
		exec
		export
		inspect
		kill
		logs
		ls
		pause
		port
		prune
		rename
		restart
		rm
		run
		start
		stats
		stop
		top
		unpause
		update
		wait
	"
	local aliases="
		list
		ps
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_container_attach() {
	__docker_complete_detach_keys && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach-keys --help --no-stdin --sig-proxy=false" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--detach-keys')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_container_commit() {
	case "$prev" in
		--author|-a|--change|-c|--message|-m)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--author -a --change -c --help --message -m --pause=false -p=false" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--author|-a|--change|-c|--message|-m')

			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
				return
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_images --repo --tag
				return
			fi
			;;
	esac
}

_docker_container_cp() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--archive -a --follow-link -L --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				case "$cur" in
					*:)
						return
						;;
					*)
						# combined container and filename completion
						_filedir
						local files=( ${COMPREPLY[@]} )

						__docker_complete_containers_all
						COMPREPLY=( $( compgen -W "${COMPREPLY[*]}" -S ':' ) )
						local containers=( ${COMPREPLY[@]} )

						COMPREPLY=( $( compgen -W "${files[*]} ${containers[*]}" -- "$cur" ) )
						if [[ "${COMPREPLY[*]}" = *: ]]; then
							__docker_nospace
						fi
						return
						;;
				esac
			fi
			(( counter++ ))

			if [ "$cword" -eq "$counter" ]; then
				if [ -e "$prev" ]; then
					__docker_complete_containers_all
					COMPREPLY=( $( compgen -W "${COMPREPLY[*]}" -S ':' ) )
					__docker_nospace
				else
					_filedir
				fi
				return
			fi
			;;
	esac
}

_docker_container_create() {
	_docker_container_run_and_create
}

_docker_container_diff() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_container_exec() {
	__docker_complete_detach_keys && return

	case "$prev" in
		--env|-e)
			# we do not append a "=" here because "-e VARNAME" is legal syntax, too
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_nospace
			return
			;;
		--user|-u)
			__docker_complete_user_group
			return
			;;
		--workdir|-w)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach -d --detach-keys --env -e --help --interactive -i --privileged -t --tty -u --user --workdir -w" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_container_export() {
	case "$prev" in
		--output|-o)
			_filedir
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --output -o" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_container_inspect() {
	_docker_inspect --type container
}

_docker_container_kill() {
	case "$prev" in
		--signal|-s)
			__docker_complete_signals
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --signal -s" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_container_logs() {
	case "$prev" in
		--since|--tail|--until)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--details --follow -f --help --since --tail --timestamps -t --until" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--since|--tail|--until')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_container_list() {
	_docker_container_ls
}

_docker_container_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		ancestor)
			__docker_complete_images --cur "${cur##*=}" --repo --tag --id
			return
			;;
		before)
			__docker_complete_containers_all --cur "${cur##*=}"
			return
			;;
		expose|publish)
			return
			;;
		id)
			__docker_complete_containers_all --cur "${cur##*=}" --id
			return
			;;
		health)
			COMPREPLY=( $( compgen -W "healthy starting none unhealthy" -- "${cur##*=}" ) )
			return
			;;
		is-task)
			COMPREPLY=( $( compgen -W "true false" -- "${cur##*=}" ) )
			return
			;;
		name)
			__docker_complete_containers_all --cur "${cur##*=}" --name
			return
			;;
		network)
			__docker_complete_networks --cur "${cur##*=}"
			return
			;;
		since)
			__docker_complete_containers_all --cur "${cur##*=}"
			return
			;;
		status)
			COMPREPLY=( $( compgen -W "created dead exited paused restarting running removing" -- "${cur##*=}" ) )
			return
			;;
		volume)
			__docker_complete_volumes --cur "${cur##*=}"
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "ancestor before exited expose health id is-task label name network publish since status volume" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format|--last|-n)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --filter -f --format --help --last -n --latest -l --no-trunc --quiet -q --size -s" -- "$cur" ) )
			;;
	esac
}

_docker_container_pause() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_container_port() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_container_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "label label! until" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --filter --help" -- "$cur" ) )
			;;
	esac
}

_docker_container_ps() {
	_docker_container_ls
}

_docker_container_rename() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_container_restart() {
	case "$prev" in
		--time|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --time -t" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_all
			;;
	esac
}

_docker_container_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help --link -l --volumes -v" -- "$cur" ) )
			;;
		*)
			for arg in "${COMP_WORDS[@]}"; do
				case "$arg" in
					--force|-f)
						__docker_complete_containers_all
						return
						;;
				esac
			done
			__docker_complete_containers_removable
			;;
	esac
}

_docker_container_run() {
	_docker_container_run_and_create
}

# _docker_container_run_and_create is the combined completion for `_docker_container_run`
# and `_docker_container_create`
_docker_container_run_and_create() {
	local options_with_args="
		--add-host
		--attach -a
		--blkio-weight
		--blkio-weight-device
		--cap-add
		--cap-drop
		--cgroup-parent
		--cidfile
		--cpu-period
		--cpu-quota
		--cpu-rt-period
		--cpu-rt-runtime
		--cpuset-cpus
		--cpus
		--cpuset-mems
		--cpu-shares -c
		--device
		--device-cgroup-rule
		--device-read-bps
		--device-read-iops
		--device-write-bps
		--device-write-iops
		--dns
		--dns-option
		--dns-search
		--domainname
		--entrypoint
		--env -e
		--env-file
		--expose
		--group-add
		--health-cmd
		--health-interval
		--health-retries
		--health-start-period
		--health-timeout
		--hostname -h
		--ip
		--ip6
		--ipc
		--kernel-memory
		--label-file
		--label -l
		--link
		--link-local-ip
		--log-driver
		--log-opt
		--mac-address
		--memory -m
		--memory-swap
		--memory-swappiness
		--memory-reservation
		--mount
		--name
		--network
		--network-alias
		--oom-score-adj
		--pid
		--pids-limit
		--publish -p
		--restart
		--runtime
		--security-opt
		--shm-size
		--stop-signal
		--stop-timeout
		--storage-opt
		--tmpfs
		--sysctl
		--ulimit
		--user -u
		--userns
		--uts
		--volume-driver
		--volumes-from
		--volume -v
		--workdir -w
	"
	__docker_server_os_is windows && options_with_args+="
		--cpu-count
		--cpu-percent
		--io-maxbandwidth
		--io-maxiops
		--isolation
	"
	__docker_server_is_experimental && options_with_args+="
		--platform
	"

	local boolean_options="
		--disable-content-trust=false
		--help
		--init
		--interactive -i
		--no-healthcheck
		--oom-kill-disable
		--privileged
		--publish-all -P
		--read-only
		--tty -t
	"

	if [ "$command" = "run" ] || [ "$subcommand" = "run" ] ; then
		options_with_args="$options_with_args
			--detach-keys
		"
		boolean_options="$boolean_options
			--detach -d
			--rm
			--sig-proxy=false
		"
		__docker_complete_detach_keys && return
	fi

	local all_options="$options_with_args $boolean_options"


	__docker_complete_log_driver_options && return
	__docker_complete_restart && return

	local key=$(__docker_map_key_of_current_option '--security-opt')
	case "$key" in
		label)
			[[ $cur == *: ]] && return
			COMPREPLY=( $( compgen -W "user: role: type: level: disable" -- "${cur##*=}") )
			if [ "${COMPREPLY[*]}" != "disable" ] ; then
				__docker_nospace
			fi
			return
			;;
		seccomp)
			local cur=${cur##*=}
			_filedir
			COMPREPLY+=( $( compgen -W "unconfined" -- "$cur" ) )
			return
			;;
	esac

	case "$prev" in
		--add-host)
			case "$cur" in
				*:)
					__docker_complete_resolved_hostname
					return
					;;
			esac
			;;
		--attach|-a)
			COMPREPLY=( $( compgen -W 'stdin stdout stderr' -- "$cur" ) )
			return
			;;
		--cap-add)
			__docker_complete_capabilities_addable
			return
			;;
		--cap-drop)
			__docker_complete_capabilities_droppable
			return
			;;
		--cidfile|--env-file|--label-file)
			_filedir
			return
			;;
		--device|--tmpfs|--volume|-v)
			case "$cur" in
				*:*)
					# TODO somehow do _filedir for stuff inside the image, if it's already specified (which is also somewhat difficult to determine)
					;;
				'')
					COMPREPLY=( $( compgen -W '/' -- "$cur" ) )
					__docker_nospace
					;;
				/*)
					_filedir
					__docker_nospace
					;;
			esac
			return
			;;
		--env|-e)
			# we do not append a "=" here because "-e VARNAME" is legal syntax, too
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_nospace
			return
			;;
		--ipc)
			case "$cur" in
				*:*)
					cur="${cur#*:}"
					__docker_complete_containers_running
					;;
				*)
					COMPREPLY=( $( compgen -W 'none host private shareable container:' -- "$cur" ) )
					if [ "${COMPREPLY[*]}" = "container:" ]; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
		--isolation)
			if __docker_server_os_is windows ; then
				__docker_complete_isolation
				return
			fi
			;;
		--link)
			case "$cur" in
				*:*)
					;;
				*)
					__docker_complete_containers_running
					COMPREPLY=( $( compgen -W "${COMPREPLY[*]}" -S ':' ) )
					__docker_nospace
					;;
			esac
			return
			;;
		--log-driver)
			__docker_complete_log_drivers
			return
			;;
		--log-opt)
			__docker_complete_log_options
			return
			;;
		--network)
			case "$cur" in
				container:*)
					__docker_complete_containers_all --cur "${cur#*:}"
					;;
				*)
					COMPREPLY=( $( compgen -W "$(__docker_plugins_bundled --type Network) $(__docker_networks) container:" -- "$cur") )
					if [ "${COMPREPLY[*]}" = "container:" ] ; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
		--pid)
			case "$cur" in
				*:*)
					__docker_complete_containers_running --cur "${cur#*:}"
					;;
				*)
					COMPREPLY=( $( compgen -W 'host container:' -- "$cur" ) )
					if [ "${COMPREPLY[*]}" = "container:" ]; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
		--runtime)
			__docker_complete_runtimes
			return
			;;
		--security-opt)
			COMPREPLY=( $( compgen -W "apparmor= label= no-new-privileges seccomp=" -- "$cur") )
			if [ "${COMPREPLY[*]}" != "no-new-privileges" ] ; then
				__docker_nospace
			fi
			return
			;;
		--stop-signal)
			__docker_complete_signals
			return
			;;
		--storage-opt)
			COMPREPLY=( $( compgen -W "size" -S = -- "$cur") )
			__docker_nospace
			return
			;;
		--user|-u)
			__docker_complete_user_group
			return
			;;
		--userns)
			COMPREPLY=( $( compgen -W "host" -- "$cur" ) )
			return
			;;
		--volume-driver)
			__docker_complete_plugins_bundled --type Volume
			return
			;;
		--volumes-from)
			__docker_complete_containers_all
			return
			;;
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$all_options" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "$( __docker_to_alternatives "$options_with_args" )" )
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --repo --tag --id
			fi
			;;
	esac
}

_docker_container_start() {
	__docker_complete_detach_keys && return
	case "$prev" in
		--checkpoint)
			if __docker_server_is_experimental ; then
				return
			fi
			;;
		--checkpoint-dir)
			if __docker_server_is_experimental ; then
				_filedir -d
				return
			fi
			;;
	esac

	case "$cur" in
		-*)
			local options="--attach -a --detach-keys --help --interactive -i"
			__docker_server_is_experimental && options+=" --checkpoint --checkpoint-dir"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_stopped
			;;
	esac
}

_docker_container_stats() {
	case "$prev" in
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --format --help --no-stream --no-trunc" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_container_stop() {
	case "$prev" in
		--time|-t)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --time -t" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_stoppable
			;;
	esac
}

_docker_container_top() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_container_unpause() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_containers_unpauseable
			fi
			;;
	esac
}

_docker_container_update() {
	local options_with_args="
		--blkio-weight
		--cpu-period
		--cpu-quota
		--cpu-rt-period
		--cpu-rt-runtime
		--cpus
		--cpuset-cpus
		--cpuset-mems
		--cpu-shares -c
		--kernel-memory
		--memory -m
		--memory-reservation
		--memory-swap
		--pids-limit
		--restart
	"

	local boolean_options="
		--help
	"

	local all_options="$options_with_args $boolean_options"

	__docker_complete_restart && return

	case "$prev" in
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$all_options" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_all
			;;
	esac
}

_docker_container_wait() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_all
			;;
	esac
}


_docker_context() {
	local subcommands="
		create
		export
		import
		inspect
		ls
		rm
		update
		use
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_context_create() {
	case "$prev" in
		--default-stack-orchestrator)
			COMPREPLY=( $( compgen -W "all kubernetes swarm" -- "$cur" ) )
			return
			;;
		--description|--docker|--kubernetes)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--default-stack-orchestrator --description --docker --help --kubernetes" -- "$cur" ) )
			;;
	esac
}

_docker_context_export() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --kubeconfig" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_contexts
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				_filedir
			fi
			;;
	esac
}

_docker_context_import() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				:
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				_filedir
			fi
			;;
	esac
}

_docker_context_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_contexts
			;;
	esac
}

_docker_context_list() {
	_docker_context_ls
}

_docker_context_ls() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_context_remove() {
	_docker_context_rm
}

_docker_context_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_contexts
			;;
	esac
}

_docker_context_update() {
	case "$prev" in
		--default-stack-orchestrator)
			COMPREPLY=( $( compgen -W "all kubernetes swarm" -- "$cur" ) )
			return
			;;
		--description|--docker|--kubernetes)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--default-stack-orchestrator --description --docker --help --kubernetes" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_contexts
			fi
			;;
	esac
}

_docker_context_use() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_contexts --add default
			fi
			;;
	esac
}


_docker_commit() {
	_docker_container_commit
}

_docker_cp() {
	_docker_container_cp
}

_docker_create() {
	_docker_container_create
}

_docker_daemon() {
	local boolean_options="
		$global_boolean_options
		--experimental
		--help
		--icc=false
		--init
		--ip-forward=false
		--ip-masq=false
		--iptables=false
		--ipv6
		--live-restore
		--no-new-privileges
		--raw-logs
		--selinux-enabled
		--userland-proxy=false
		--version -v
	"
	local options_with_args="
		$global_options_with_args
		--add-runtime
		--allow-nondistributable-artifacts
		--api-cors-header
		--authorization-plugin
		--bip
		--bridge -b
		--cgroup-parent
		--cluster-advertise
		--cluster-store
		--cluster-store-opt
		--config-file
		--containerd
		--cpu-rt-period
		--cpu-rt-runtime
		--data-root
		--default-address-pool
		--default-gateway
		--default-gateway-v6
		--default-runtime
		--default-shm-size
		--default-ulimit
		--dns
		--dns-search
		--dns-opt
		--exec-opt
		--exec-root
		--fixed-cidr
		--fixed-cidr-v6
		--group -G
		--init-path
		--insecure-registry
		--ip
		--label
		--log-driver
		--log-opt
		--max-concurrent-downloads
		--max-concurrent-uploads
		--metrics-addr
		--mtu
		--network-control-plane-mtu
		--node-generic-resource
		--oom-score-adjust
		--pidfile -p
		--registry-mirror
		--seccomp-profile
		--shutdown-timeout
		--storage-driver -s
		--storage-opt
		--swarm-default-advertise-addr
		--userland-proxy-path
		--userns-remap
	"

	__docker_complete_log_driver_options && return

 	key=$(__docker_map_key_of_current_option '--cluster-store-opt')
 	case "$key" in
 		kv.*file)
			cur=${cur##*=}
 			_filedir
 			return
 			;;
 	esac

 	local key=$(__docker_map_key_of_current_option '--storage-opt')
 	case "$key" in
 		dm.blkdiscard|dm.override_udev_sync_check|dm.use_deferred_removal|dm.use_deferred_deletion)
 			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
 			return
 			;;
		dm.directlvm_device|dm.thinpooldev)
			cur=${cur##*=}
			_filedir
			return
			;;
		dm.fs)
			COMPREPLY=( $( compgen -W "ext4 xfs" -- "${cur##*=}" ) )
			return
			;;
		dm.libdm_log_level)
			COMPREPLY=( $( compgen -W "2 3 4 5 6 7" -- "${cur##*=}" ) )
			return
			;;
 	esac

	case "$prev" in
		--authorization-plugin)
			__docker_complete_plugins_bundled --type Authorization
			return
			;;
		--cluster-store)
			COMPREPLY=( $( compgen -W "consul etcd zk" -S "://" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--cluster-store-opt)
			COMPREPLY=( $( compgen -W "discovery.heartbeat discovery.ttl kv.cacertfile kv.certfile kv.keyfile kv.path" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--config-file|--containerd|--init-path|--pidfile|-p|--tlscacert|--tlscert|--tlskey|--userland-proxy-path)
			_filedir
			return
			;;
		--exec-root|--data-root)
			_filedir -d
			return
			;;
		--log-driver)
			__docker_complete_log_drivers
			return
			;;
		--storage-driver|-s)
			COMPREPLY=( $( compgen -W "aufs btrfs devicemapper overlay overlay2 vfs zfs" -- "$(echo "$cur" | tr '[:upper:]' '[:lower:]')" ) )
			return
			;;
		--storage-opt)
			local btrfs_options="btrfs.min_space"
			local devicemapper_options="
				dm.basesize
				dm.blkdiscard
				dm.blocksize
				dm.directlvm_device
				dm.fs
				dm.libdm_log_level
				dm.loopdatasize
				dm.loopmetadatasize
				dm.min_free_space
				dm.mkfsarg
				dm.mountopt
				dm.override_udev_sync_check
				dm.thinpooldev
				dm.thinp_autoextend_percent
				dm.thinp_autoextend_threshold
				dm.thinp_metapercent
				dm.thinp_percent
				dm.use_deferred_deletion
				dm.use_deferred_removal
			"
			local overlay2_options="overlay2.size"
			local zfs_options="zfs.fsname"

			local all_options="$btrfs_options $devicemapper_options $overlay2_options $zfs_options"

			case $(__docker_value_of_option '--storage-driver|-s') in
				'')
					COMPREPLY=( $( compgen -W "$all_options" -S = -- "$cur" ) )
					;;
				btrfs)
					COMPREPLY=( $( compgen -W "$btrfs_options" -S = -- "$cur" ) )
					;;
				devicemapper)
					COMPREPLY=( $( compgen -W "$devicemapper_options" -S = -- "$cur" ) )
					;;
				overlay2)
					COMPREPLY=( $( compgen -W "$overlay2_options" -S = -- "$cur" ) )
					;;
				zfs)
					COMPREPLY=( $( compgen -W "$zfs_options" -S = -- "$cur" ) )
					;;
				*)
					return
					;;
			esac
			__docker_nospace
			return
			;;
		--log-level|-l)
			__docker_complete_log_levels
			return
			;;
		--log-opt)
			__docker_complete_log_options
			return
			;;
		--metrics-addr)
			__docker_complete_local_ips
			__docker_append_to_completions ":"
			__docker_nospace
			return
			;;
		--seccomp-profile)
			_filedir json
			return
			;;
		--swarm-default-advertise-addr)
			__docker_complete_local_interfaces
			return
			;;
		--userns-remap)
			__docker_complete_user_group
			return
			;;
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$boolean_options $options_with_args" -- "$cur" ) )
			;;
	esac
}

_docker_deploy() {
	__docker_server_is_experimental && _docker_stack_deploy
}

_docker_diff() {
	_docker_container_diff
}


_docker_engine() {
	local subcommands="
		activate
		check
		update
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_engine_activate() {
	case "$prev" in
		--containerd|--engine-image|--format|--license|--registry-prefix|--version)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--containerd --display-only --engine-image --format --help --license --quiet --registry-prefix --version" -- "$cur" ) )
			;;
	esac
}

_docker_engine_check() {
	case "$prev" in
		--containerd|--engine-image|--format|--registry-prefix)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--containerd --downgrades --engine-image --format --help --pre-releases --quiet -q --registry-prefix --upgrades" -- "$cur" ) )
			;;
	esac
}

_docker_engine_update() {
	case "$prev" in
		--containerd|--engine-image|--registry-prefix|--version)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--containerd --engine-image --help --registry-prefix --version" -- "$cur" ) )
			;;
	esac
}


_docker_events() {
	_docker_system_events
}

_docker_exec() {
	_docker_container_exec
}

_docker_export() {
	_docker_container_export
}

_docker_help() {
	local counter=$(__docker_pos_first_nonflag)
	if [ "$cword" -eq "$counter" ]; then
		COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
	fi
}

_docker_history() {
	_docker_image_history
}


_docker_image() {
	local subcommands="
		build
		history
		import
		inspect
		load
		ls
		prune
		pull
		push
		rm
		save
		tag
	"
	local aliases="
		images
		list
		remove
		rmi
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_image_build() {
	local options_with_args="
		--add-host
		--build-arg
		--cache-from
		--cgroup-parent
		--cpuset-cpus
		--cpuset-mems
		--cpu-shares -c
		--cpu-period
		--cpu-quota
		--file -f
		--iidfile
		--label
		--memory -m
		--memory-swap
		--network
		--shm-size
		--tag -t
		--target
		--ulimit
	"
	__docker_server_os_is windows && options_with_args+="
		--isolation
	"

	local boolean_options="
		--compress
		--disable-content-trust=false
		--force-rm
		--help
		--no-cache
		--pull
		--quiet -q
		--rm
	"
	if __docker_server_is_experimental ; then
		options_with_args+="
			--platform
		"
		boolean_options+="
			--squash
			--stream
		"
	fi

	local all_options="$options_with_args $boolean_options"

	case "$prev" in
		--add-host)
			case "$cur" in
				*:)
					__docker_complete_resolved_hostname
					return
					;;
			esac
			;;
		--build-arg)
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_nospace
			return
			;;
		--cache-from)
			__docker_complete_images --repo --tag --id
			return
			;;
		--file|-f|--iidfile)
			_filedir
			return
			;;
		--isolation)
			if __docker_server_os_is windows ; then
				__docker_complete_isolation
				return
			fi
			;;
		--network)
			case "$cur" in
				container:*)
					__docker_complete_containers_all --cur "${cur#*:}"
					;;
				*)
					COMPREPLY=( $( compgen -W "$(__docker_plugins_bundled --type Network) $(__docker_networks) container:" -- "$cur") )
					if [ "${COMPREPLY[*]}" = "container:" ] ; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
		--tag|-t)
			__docker_complete_images --repo --tag
			return
			;;
		--target)
			local context_pos=$( __docker_pos_first_nonflag "$( __docker_to_alternatives "$options_with_args" )" )
			local context="${words[$context_pos]}"
			context="${context:-.}"

			local file="$( __docker_value_of_option '--file|f' )"
			local default_file="${context%/}/Dockerfile"
			local dockerfile="${file:-$default_file}"

			local targets="$( sed -n 's/^FROM .\+ AS \(.\+\)/\1/p' "$dockerfile" 2>/dev/null )"
			COMPREPLY=( $( compgen -W "$targets" -- "$cur" ) )
			return
			;;
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$all_options" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "$( __docker_to_alternatives "$options_with_args" )" )
			if [ "$cword" -eq "$counter" ]; then
				_filedir -d
			fi
			;;
	esac
}

_docker_image_history() {
	case "$prev" in
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format --help --human=false -H=false --no-trunc --quiet -q" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--format')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --force-tag --id
			fi
			;;
	esac
}

_docker_image_images() {
	_docker_image_ls
}

_docker_image_import() {
	case "$prev" in
		--change|-c|--message|-m|--platform)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--change -c --help --message -m"
			__docker_server_is_experimental && options+=" --platform"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--change|-c|--message|-m')
			if [ "$cword" -eq "$counter" ]; then
				_filedir
				return
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_images --repo --tag
				return
			fi
			;;
	esac
}

_docker_image_inspect() {
	_docker_inspect --type image
}

_docker_image_load() {
	case "$prev" in
		--input|-i|"<")
			_filedir
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --input -i --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_image_list() {
	_docker_image_ls
}

_docker_image_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		before|since)
			__docker_complete_images --cur "${cur##*=}" --force-tag --id
			return
			;;
		dangling)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		label)
			return
			;;
		reference)
			__docker_complete_images --cur "${cur##*=}" --repo --tag
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "before dangling label reference since" -- "$cur" ) )
			__docker_nospace
			return
			;;
                --format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --digests --filter -f --format --help --no-trunc --quiet -q" -- "$cur" ) )
			;;
		=)
			return
			;;
		*)
			__docker_complete_images --repo --tag
			;;
	esac
}

_docker_image_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "label label! until" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --force -f --filter --help" -- "$cur" ) )
			;;
	esac
}

_docker_image_pull() {
	case "$prev" in
		--platform)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--all-tags -a --disable-content-trust=false --help --quiet -q"
			__docker_server_is_experimental && options+=" --platform"

			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag --platform)
			if [ "$cword" -eq "$counter" ]; then
				for arg in "${COMP_WORDS[@]}"; do
					case "$arg" in
						--all-tags|-a)
							__docker_complete_images --repo
							return
							;;
					esac
				done
				__docker_complete_images --repo --tag
			fi
			;;
	esac
}

_docker_image_push() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--disable-content-trust=false --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --repo --tag
			fi
			;;
	esac
}

_docker_image_remove() {
	_docker_image_rm
}

_docker_image_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help --no-prune" -- "$cur" ) )
			;;
		*)
			__docker_complete_images --force-tag --id
			;;
	esac
}

_docker_image_rmi() {
	_docker_image_rm
}

_docker_image_save() {
	case "$prev" in
		--output|-o|">")
			_filedir
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --output -o" -- "$cur" ) )
			;;
		*)
			__docker_complete_images --repo --tag --id
			;;
	esac
}

_docker_image_tag() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)

			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --force-tag --id
				return
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_images --repo --tag
				return
			fi
			;;
	esac
}


_docker_images() {
	_docker_image_ls
}

_docker_import() {
	_docker_image_import
}

_docker_info() {
	_docker_system_info
}

_docker_inspect() {
	local preselected_type
	local type

	if [ "$1" = "--type" ] ; then
		preselected_type=yes
		type="$2"
	else
		type=$(__docker_value_of_option --type)
	fi

	case "$prev" in
		--format|-f)
			return
			;;
		--type)
			if [ -z "$preselected_type" ] ; then
				COMPREPLY=( $( compgen -W "container image network node plugin secret service volume" -- "$cur" ) )
				return
			fi
			;;
	esac

	case "$cur" in
		-*)
			local options="--format -f --help --size -s"
			if [ -z "$preselected_type" ] ; then
				options+=" --type"
			fi
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			case "$type" in
				'')
					COMPREPLY=( $( compgen -W "
						$(__docker_containers --all)
						$(__docker_images --force-tag --id)
						$(__docker_networks)
						$(__docker_nodes)
						$(__docker_plugins_installed)
						$(__docker_secrets)
						$(__docker_services)
						$(__docker_volumes)
					" -- "$cur" ) )
					__ltrim_colon_completions "$cur"
					;;
				container)
					__docker_complete_containers_all
					;;
				image)
					__docker_complete_images --force-tag --id
					;;
				network)
					__docker_complete_networks
					;;
				node)
					__docker_complete_nodes
					;;
				plugin)
					__docker_complete_plugins_installed
					;;
				secret)
					__docker_complete_secrets
					;;
				service)
					__docker_complete_services
					;;
				volume)
					__docker_complete_volumes
					;;
			esac
	esac
}

_docker_kill() {
	_docker_container_kill
}

_docker_load() {
	_docker_image_load
}

_docker_login() {
	case "$prev" in
		--password|-p|--username|-u)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --password -p --password-stdin --username -u" -- "$cur" ) )
			;;
	esac
}

_docker_logout() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
	esac
}

_docker_logs() {
	_docker_container_logs
}

_docker_network_connect() {
	local options_with_args="
		--alias
		--ip
		--ip6
		--link
		--link-local-ip
	"

	local boolean_options="
		--help
	"

	case "$prev" in
		--link)
			case "$cur" in
				*:*)
					;;
				*)
					__docker_complete_containers_running
					COMPREPLY=( $( compgen -W "${COMPREPLY[*]}" -S ':' ) )
					__docker_nospace
					;;
			esac
			return
			;;
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$boolean_options $options_with_args" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "$( __docker_to_alternatives "$options_with_args" )" )
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_networks
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_network_create() {
	case "$prev" in
		--aux-address|--gateway|--ip-range|--ipam-opt|--ipv6|--opt|-o|--subnet)
			return
			;;
		--config-from)
			__docker_complete_networks
			return
			;;
		--driver|-d)
			# remove drivers that allow one instance only, add drivers missing in `docker info`
			__docker_complete_plugins_bundled --type Network --remove host --remove null --add macvlan
			return
			;;
		--ipam-driver)
			COMPREPLY=( $( compgen -W "default" -- "$cur" ) )
			return
			;;
		--label)
			return
			;;
		--scope)
			COMPREPLY=( $( compgen -W "local swarm" -- "$cur" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--attachable --aux-address --config-from --config-only --driver -d --gateway --help --ingress --internal --ip-range --ipam-driver --ipam-opt --ipv6 --label --opt -o --scope --subnet" -- "$cur" ) )
			;;
	esac
}

_docker_network_disconnect() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_networks
			elif [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_containers_in_network "$prev"
			fi
			;;
	esac
}

_docker_network_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --verbose" -- "$cur" ) )
			;;
		*)
			__docker_complete_networks
	esac
}

_docker_network_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		dangling)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		driver)
			__docker_complete_plugins_bundled --cur "${cur##*=}" --type Network --add macvlan
			return
			;;
		id)
			__docker_complete_networks --cur "${cur##*=}" --id
			return
			;;
		name)
			__docker_complete_networks --cur "${cur##*=}" --name
			return
			;;
		scope)
			COMPREPLY=( $( compgen -W "global local swarm" -- "${cur##*=}" ) )
			return
			;;
		type)
			COMPREPLY=( $( compgen -W "builtin custom" -- "${cur##*=}" ) )
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "dangling driver id label name scope type" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --no-trunc --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_network_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "label label! until" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --filter --help" -- "$cur" ) )
			;;
	esac
}

_docker_network_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_networks --filter type=custom
	esac
}

_docker_network() {
	local subcommands="
		connect
		create
		disconnect
		inspect
		ls
		prune
		rm
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_service() {
	local subcommands="
		create
		inspect
		logs
		ls
		rm
		rollback
		scale
		ps
		update
	"

	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_service_create() {
	_docker_service_update_and_create
}

_docker_service_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --pretty" -- "$cur" ) )
			;;
		*)
			__docker_complete_services
	esac
}

_docker_service_logs() {
	case "$prev" in
		--since|--tail)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--details --follow -f --help --no-resolve --no-task-ids --no-trunc --raw --since --tail --timestamps -t" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--since|--tail')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_services_and_tasks
			fi
			;;
	esac
}

_docker_service_list() {
	_docker_service_ls
}

_docker_service_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		id)
			__docker_complete_services --cur "${cur##*=}" --id
			return
			;;
		mode)
			COMPREPLY=( $( compgen -W "global replicated" -- "${cur##*=}" ) )
			return
			;;
		name)
			__docker_complete_services --cur "${cur##*=}" --name
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "id label mode name" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_service_remove() {
	_docker_service_rm
}

_docker_service_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_services
	esac
}

_docker_service_rollback() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach -d --help --quit -q" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag )
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_services
			fi
			;;
	esac
}

_docker_service_scale() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach -d --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_services
			__docker_append_to_completions "="
			__docker_nospace
			;;
	esac
}

_docker_service_ps() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		desired-state)
			COMPREPLY=( $( compgen -W "accepted running shutdown" -- "${cur##*=}" ) )
			return
			;;
		name)
			__docker_complete_services --cur "${cur##*=}" --name
			return
			;;
		node)
			__docker_complete_nodes --cur "${cur##*=}" --add self
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "desired-state id name node" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --no-resolve --no-trunc --quiet -q" -- "$cur" ) )
			;;
		*)
			__docker_complete_services
			;;
	esac
}

_docker_service_update() {
	_docker_service_update_and_create
}

# _docker_service_update_and_create is the combined completion for `docker service create`
# and `docker service update`
_docker_service_update_and_create() {
	local options_with_args="
		--endpoint-mode
		--entrypoint
		--health-cmd
		--health-interval
		--health-retries
		--health-start-period
		--health-timeout
		--hostname
		--isolation
		--limit-cpu
		--limit-memory
		--log-driver
		--log-opt
		--replicas
		--replicas-max-per-node
		--reserve-cpu
		--reserve-memory
		--restart-condition
		--restart-delay
		--restart-max-attempts
		--restart-window
		--rollback-delay
		--rollback-failure-action
		--rollback-max-failure-ratio
		--rollback-monitor
		--rollback-order
		--rollback-parallelism
		--stop-grace-period
		--stop-signal
		--update-delay
		--update-failure-action
		--update-max-failure-ratio
		--update-monitor
		--update-order
		--update-parallelism
		--user -u
		--workdir -w
	"
	__docker_server_os_is windows && options_with_args+="
		--credential-spec
	"

	local boolean_options="
		--detach -d
		--help
		--init
		--no-healthcheck
		--no-resolve-image
		--read-only
		--tty -t
		--with-registry-auth
	"

	__docker_complete_log_driver_options && return

	if [ "$subcommand" = "create" ] ; then
		options_with_args="$options_with_args
			--config
			--constraint
			--container-label
			--dns
			--dns-option
			--dns-search
			--env -e
			--env-file
			--generic-resource
			--group
			--host
			--label -l
			--mode
			--mount
			--name
			--network
			--placement-pref
			--publish -p
			--secret
			--sysctl
		"

		case "$prev" in
			--env-file)
				_filedir
				return
				;;
			--mode)
				COMPREPLY=( $( compgen -W "global replicated" -- "$cur" ) )
				return
				;;
		esac
	fi
	if [ "$subcommand" = "update" ] ; then
		options_with_args="$options_with_args
			--args
			--config-add
			--config-rm
			--constraint-add
			--constraint-rm
			--container-label-add
			--container-label-rm
			--dns-add
			--dns-option-add
			--dns-option-rm
			--dns-rm
			--dns-search-add
			--dns-search-rm
			--env-add
			--env-rm
			--generic-resource-add
			--generic-resource-rm
			--group-add
			--group-rm
			--host-add
			--host-rm
			--image
			--label-add
			--label-rm
			--mount-add
			--mount-rm
			--network-add
			--network-rm
			--placement-pref-add
			--placement-pref-rm
			--publish-add
			--publish-rm
			--rollback
			--secret-add
			--secret-rm
			--sysctl-add
			--sysctl-rm
		"

		boolean_options="$boolean_options
			--force
		"

		case "$prev" in
			--env-rm)
				COMPREPLY=( $( compgen -e -- "$cur" ) )
				return
				;;
			--image)
				__docker_complete_images --repo --tag --id
				return
				;;
		esac
	fi

	local strategy=$(__docker_map_key_of_current_option '--placement-pref|--placement-pref-add|--placement-pref-rm')
	case "$strategy" in
		spread)
			COMPREPLY=( $( compgen -W "engine.labels node.labels" -S . -- "${cur##*=}" ) )
			__docker_nospace
			return
			;;
	esac

	case "$prev" in
		--config|--config-add|--config-rm)
			__docker_complete_configs
			return
			;;
		--endpoint-mode)
			COMPREPLY=( $( compgen -W "dnsrr vip" -- "$cur" ) )
			return
			;;
		--env|-e|--env-add)
			# we do not append a "=" here because "-e VARNAME" is legal systax, too
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_nospace
			return
			;;
		--group|--group-add|--group-rm)
			COMPREPLY=( $(compgen -g -- "$cur") )
			return
			;;
		--host|--host-add|--host-rm)
			case "$cur" in
				*:)
					__docker_complete_resolved_hostname
					return
					;;
			esac
			;;
		--isolation)
			__docker_complete_isolation
			return
			;;
		--log-driver)
			__docker_complete_log_drivers
			return
			;;
		--log-opt)
			__docker_complete_log_options
			return
			;;
		--network|--network-add|--network-rm)
			__docker_complete_networks
			return
			;;
		--placement-pref|--placement-pref-add|--placement-pref-rm)
			COMPREPLY=( $( compgen -W "spread" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--restart-condition)
			COMPREPLY=( $( compgen -W "any none on-failure" -- "$cur" ) )
			return
			;;
		--rollback-failure-action)
			COMPREPLY=( $( compgen -W "continue pause" -- "$cur" ) )
			return
			;;
		--secret|--secret-add|--secret-rm)
			__docker_complete_secrets
			return
			;;
		--stop-signal)
			__docker_complete_signals
			return
			;;
		--update-failure-action)
			COMPREPLY=( $( compgen -W "continue pause rollback" -- "$cur" ) )
			return
			;;
		--update-order|--rollback-order)
			COMPREPLY=( $( compgen -W "start-first stop-first" -- "$cur" ) )
			return
			;;
		--user|-u)
			__docker_complete_user_group
			return
			;;
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$boolean_options $options_with_args" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "$( __docker_to_alternatives "$options_with_args" )" )
			if [ "$subcommand" = "update" ] ; then
				if [ "$cword" -eq "$counter" ]; then
					__docker_complete_services
				fi
			else
				if [ "$cword" -eq "$counter" ]; then
					__docker_complete_images --repo --tag --id
				fi
			fi
			;;
	esac
}

_docker_swarm() {
	local subcommands="
		ca
		init
		join
		join-token
		leave
		unlock
		unlock-key
		update
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_swarm_ca() {
	case "$prev" in
		--ca-cert|--ca-key)
			_filedir
			return
			;;
		--cert-expiry|--external-ca)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--ca-cert --ca-key --cert-expiry --detach -d --external-ca --help --quiet -q --rotate" -- "$cur" ) )
			;;
	esac
}

_docker_swarm_init() {
	case "$prev" in
		--advertise-addr)
			if [[ $cur == *: ]] ; then
				COMPREPLY=( $( compgen -W "2377" -- "${cur##*:}" ) )
			else
				__docker_complete_local_interfaces
				__docker_nospace
			fi
			return
			;;
		--availability)
			COMPREPLY=( $( compgen -W "active drain pause" -- "$cur" ) )
			return
			;;
		--cert-expiry|--data-path-port|--default-addr-pool|--default-addr-pool-mask-length|--dispatcher-heartbeat|--external-ca|--max-snapshots|--snapshot-interval|--task-history-limit )
			return
			;;
		--data-path-addr)
			__docker_complete_local_interfaces
			return
			;;
		--listen-addr)
			if [[ $cur == *: ]] ; then
				COMPREPLY=( $( compgen -W "2377" -- "${cur##*:}" ) )
			else
				__docker_complete_local_interfaces --add 0.0.0.0
				__docker_nospace
			fi
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--advertise-addr --autolock --availability --cert-expiry --data-path-addr --data-path-port --default-addr-pool --default-addr-pool-mask-length --dispatcher-heartbeat --external-ca --force-new-cluster --help --listen-addr --max-snapshots --snapshot-interval --task-history-limit " -- "$cur" ) )
			;;
	esac
}

_docker_swarm_join() {
	case "$prev" in
		--advertise-addr)
			if [[ $cur == *: ]] ; then
				COMPREPLY=( $( compgen -W "2377" -- "${cur##*:}" ) )
			else
				__docker_complete_local_interfaces
				__docker_nospace
			fi
			return
			;;
		--availability)
			COMPREPLY=( $( compgen -W "active drain pause" -- "$cur" ) )
			return
			;;
		--data-path-addr)
			__docker_complete_local_interfaces
			return
			;;
		--listen-addr)
			if [[ $cur == *: ]] ; then
				COMPREPLY=( $( compgen -W "2377" -- "${cur##*:}" ) )
			else
				__docker_complete_local_interfaces --add 0.0.0.0
				__docker_nospace
			fi
			return
			;;
		--token)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--advertise-addr --availability --data-path-addr --help --listen-addr --token" -- "$cur" ) )
			;;
		*:)
			COMPREPLY=( $( compgen -W "2377" -- "${cur##*:}" ) )
			;;
	esac
}

_docker_swarm_join_token() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --quiet -q --rotate" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag )
			if [ "$cword" -eq "$counter" ]; then
				COMPREPLY=( $( compgen -W "manager worker" -- "$cur" ) )
			fi
			;;
	esac
}

_docker_swarm_leave() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
	esac
}

_docker_swarm_unlock() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
	esac
}

_docker_swarm_unlock_key() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --quiet -q --rotate" -- "$cur" ) )
			;;
	esac
}

_docker_swarm_update() {
	case "$prev" in
		--cert-expiry|--dispatcher-heartbeat|--external-ca|--max-snapshots|--snapshot-interval|--task-history-limit)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--autolock --cert-expiry --dispatcher-heartbeat --external-ca --help --max-snapshots --snapshot-interval --task-history-limit" -- "$cur" ) )
			;;
	esac
}

_docker_manifest() {
	local subcommands="
		annotate
		create
		inspect
		push
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_manifest_annotate() {
	case "$prev" in
		--arch)
			COMPREPLY=( $( compgen -W "
				386
				amd64
				arm
				arm64
				mips64
				mips64le
				ppc64le
				s390x" -- "$cur" ) )
			return
			;;
		--os)
			COMPREPLY=( $( compgen -W "
				darwin
				dragonfly
				freebsd
				linux
				netbsd
				openbsd
				plan9
				solaris
				windows" -- "$cur" ) )
			return
			;;
		--os-features|--variant)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--arch --help --os --os-features --variant" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag "--arch|--os|--os-features|--variant" )
			if [ "$cword" -eq "$counter" ] || [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_images --force-tag --id
			fi
			;;
	esac
}

_docker_manifest_create() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--amend -a --help --insecure" -- "$cur" ) )
			;;
		*)
			__docker_complete_images --force-tag --id
			;;
	esac
}

_docker_manifest_inspect() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --insecure --verbose -v" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag )
			if [ "$cword" -eq "$counter" ] || [ "$cword" -eq "$((counter + 1))" ]; then
				__docker_complete_images --force-tag --id
			fi
			;;
	esac
}

_docker_manifest_push() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --insecure --purge -p" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag )
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --force-tag --id
			fi
			;;
	esac
}

_docker_node() {
	local subcommands="
		demote
		inspect
		ls
		promote
		rm
		ps
		update
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_node_demote() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_nodes --filter role=manager
	esac
}

_docker_node_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --pretty" -- "$cur" ) )
			;;
		*)
			__docker_complete_nodes --add self
	esac
}

_docker_node_list() {
	_docker_node_ls
}

_docker_node_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		id)
			__docker_complete_nodes --cur "${cur##*=}" --id
			return
			;;
		membership)
			COMPREPLY=( $( compgen -W "accepted pending" -- "${cur##*=}" ) )
			return
			;;
		name)
			__docker_complete_nodes --cur "${cur##*=}" --name
			return
			;;
		role)
			COMPREPLY=( $( compgen -W "manager worker" -- "${cur##*=}" ) )
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "id label membership name role" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_node_promote() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_nodes --filter role=worker
	esac
}

_docker_node_remove() {
	_docker_node_rm
}

_docker_node_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_nodes
	esac
}

_docker_node_ps() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		desired-state)
			COMPREPLY=( $( compgen -W "accepted running shutdown" -- "${cur##*=}" ) )
			return
			;;
		name)
			__docker_complete_services --cur "${cur##*=}" --name
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "desired-state id label name" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --no-resolve --no-trunc --quiet -q" -- "$cur" ) )
			;;
		*)
			__docker_complete_nodes --add self
			;;
	esac
}

_docker_node_update() {
	case "$prev" in
		--availability)
			COMPREPLY=( $( compgen -W "active drain pause" -- "$cur" ) )
			return
			;;
		--role)
			COMPREPLY=( $( compgen -W "manager worker" -- "$cur" ) )
			return
			;;
		--label-add|--label-rm)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--availability --help --label-add --label-rm --role" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--availability|--label-add|--label-rm|--role')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_nodes
			fi
			;;
	esac
}

_docker_pause() {
	_docker_container_pause
}

_docker_plugin() {
	local subcommands="
		create
		disable
		enable
		inspect
		install
		ls
		push
		rm
		set
		upgrade
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_plugin_create() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--compress --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				# reponame
				return
			elif [ "$cword" -eq  "$((counter + 1))" ]; then
				_filedir -d
			fi
			;;
	esac
}

_docker_plugin_disable() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_plugins_installed --filter enabled=true
			fi
			;;
	esac
}

_docker_plugin_enable() {
	case "$prev" in
		--timeout)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --timeout" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--timeout')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_plugins_installed --filter enabled=false
			fi
			;;
	esac
}

_docker_plugin_inspect() {
	case "$prev" in
		--format|f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_plugins_installed
			;;
	esac
}

_docker_plugin_install() {
	case "$prev" in
		--alias)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--alias --disable --disable-content-trust=false --grant-all-permissions --help" -- "$cur" ) )
			;;
	esac
}

_docker_plugin_list() {
	_docker_plugin_ls
}

_docker_plugin_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		capability)
			COMPREPLY=( $( compgen -W "authz ipamdriver logdriver metricscollector networkdriver volumedriver" -- "${cur##*=}" ) )
			return
			;;
		enabled)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "capability enabled" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --no-trunc --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_plugin_push() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_plugins_installed
			fi
			;;
	esac
}

_docker_plugin_remove() {
	_docker_plugin_rm
}

_docker_plugin_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_plugins_installed
			;;
	esac
}

_docker_plugin_set() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_plugins_installed
			fi
			;;
	esac
}

_docker_plugin_upgrade() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--disable-content-trust --grant-all-permissions --help --skip-remote-check" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_plugins_installed
				__ltrim_colon_completions "$cur"
			elif [ "$cword" -eq  "$((counter + 1))" ]; then
				local plugin_images="$(__docker_plugins_installed)"
				COMPREPLY=( $(compgen -S : -W "${plugin_images%:*}" -- "$cur") )
				__docker_nospace
			fi
			;;
	esac
}


_docker_port() {
	_docker_container_port
}

_docker_ps() {
	_docker_container_ls
}

_docker_pull() {
	_docker_image_pull
}

_docker_push() {
	_docker_image_push
}

_docker_rename() {
	_docker_container_rename
}

_docker_restart() {
	_docker_container_restart
}

_docker_rm() {
	_docker_container_rm
}

_docker_rmi() {
	_docker_image_rm
}

_docker_run() {
	_docker_container_run
}

_docker_save() {
	_docker_image_save
}


_docker_secret() {
	local subcommands="
		create
		inspect
		ls
		rm
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_secret_create() {
	case "$prev" in
		--driver|-d|--label|-l)
			return
			;;
		--template-driver)
			COMPREPLY=( $( compgen -W "golang" -- "$cur" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--driver -d --help --label -l --template-driver" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--driver|-d|--label|-l|--template-driver')
			if [ "$cword" -eq "$((counter + 1))" ]; then
				_filedir
			fi
			;;
	esac
}

_docker_secret_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --pretty" -- "$cur" ) )
			;;
		*)
			__docker_complete_secrets
			;;
	esac
}

_docker_secret_list() {
	_docker_secret_ls
}

_docker_secret_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		id)
			__docker_complete_secrets --cur "${cur##*=}" --id
			return
			;;
		name)
			__docker_complete_secrets --cur "${cur##*=}" --name
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "id label name" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format --filter -f --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_secret_remove() {
	_docker_secret_rm
}

_docker_secret_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_secrets
			;;
	esac
}



_docker_search() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		is-automated)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
		is-official)
			COMPREPLY=( $( compgen -W "false true" -- "${cur##*=}" ) )
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "is-automated is-official stars" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format|--limit)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --limit --no-trunc" -- "$cur" ) )
			;;
	esac
}


_docker_stack() {
	local subcommands="
		deploy
		ls
		ps
		rm
		services
	"
	local aliases="
		down
		list
		remove
		up
	"

	__docker_complete_stack_orchestrator_options && return
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			local options="--help --orchestrator"
			__docker_stack_orchestrator_is kubernetes && options+=" --kubeconfig"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_stack_deploy() {
	__docker_complete_stack_orchestrator_options && return

	case "$prev" in
		--bundle-file)
			_filedir dab
			return
			;;
		--compose-file|-c)
			_filedir yml
			return
			;;
		--resolve-image)
			COMPREPLY=( $( compgen -W "always changed never" -- "$cur" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--compose-file -c --help --orchestrator"
			__docker_server_is_experimental && __docker_stack_orchestrator_is swarm && options+=" --bundle-file"
			__docker_stack_orchestrator_is kubernetes && options+=" --kubeconfig --namespace"
			__docker_stack_orchestrator_is swarm && options+=" --prune --resolve-image --with-registry-auth"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--bundle-file|--compose-file|-c|--kubeconfig|--namespace|--orchestrator|--resolve-image')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_stacks
			fi
			;;
	esac
}

_docker_stack_down() {
	_docker_stack_rm
}

_docker_stack_list() {
	_docker_stack_ls
}

_docker_stack_ls() {
	__docker_complete_stack_orchestrator_options && return

	case "$prev" in
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--format --help --orchestrator"
			__docker_stack_orchestrator_is kubernetes && options+=" --all-namespaces --kubeconfig --namespace"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
	esac
}

_docker_stack_ps() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		desired-state)
			COMPREPLY=( $( compgen -W "accepted running shutdown" -- "${cur##*=}" ) )
			return
			;;
		id)
			__docker_complete_stacks --cur "${cur##*=}" --id
			return
			;;
		name)
			__docker_complete_stacks --cur "${cur##*=}" --name
			return
			;;
	esac

	__docker_complete_stack_orchestrator_options && return

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "id name desired-state" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--filter -f --format --help --no-resolve --no-trunc --orchestrator --quiet -q"
			__docker_stack_orchestrator_is kubernetes && options+=" --all-namespaces --kubeconfig --namespace"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--all-namespaces|--filter|-f|--format|--kubeconfig|--namespace')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_stacks
			fi
			;;
	esac
}

_docker_stack_remove() {
	_docker_stack_rm
}

_docker_stack_rm() {
	__docker_complete_stack_orchestrator_options && return

	case "$cur" in
		-*)
			local options="--help --orchestrator"
			__docker_stack_orchestrator_is kubernetes && options+=" --kubeconfig --namespace"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			__docker_complete_stacks
			;;
	esac
}

_docker_stack_services() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		id)
			__docker_complete_services --cur "${cur##*=}" --id
			return
			;;
		label)
			return
			;;
		name)
			__docker_complete_services --cur "${cur##*=}" --name
			return
			;;
	esac

	__docker_complete_stack_orchestrator_options && return

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "id label name" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--filter -f --format --help --orchestrator --quiet -q"
			__docker_stack_orchestrator_is kubernetes && options+=" --kubeconfig --namespace"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--filter|-f|--format|--kubeconfig|--namespace|--orchestrator')
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_stacks
			fi
			;;
	esac
}

_docker_stack_up() {
	_docker_stack_deploy
}


_docker_start() {
	_docker_container_start
}

_docker_stats() {
	_docker_container_stats
}

_docker_stop() {
	_docker_container_stop
}


_docker_system() {
	local subcommands="
		df
		events
		info
		prune
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_system_df() {
	case "$prev" in
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format --help --verbose -v" -- "$cur" ) )
			;;
	esac
}

_docker_system_events() {
	local key=$(__docker_map_key_of_current_option '-f|--filter')
	case "$key" in
		container)
			__docker_complete_containers_all --cur "${cur##*=}"
			return
			;;
		daemon)
			local name=$(__docker_q info | sed -n 's/^\(ID\|Name\): //p')
			COMPREPLY=( $( compgen -W "$name" -- "${cur##*=}" ) )
			return
			;;
		event)
			COMPREPLY=( $( compgen -W "
				attach
				commit
				connect
				copy
				create
				delete
				destroy
				detach
				die
				disable
				disconnect
				enable
				exec_create
				exec_detach
				exec_die
				exec_start
				export
				health_status
				import
				install
				kill
				load
				mount
				oom
				pause
				pull
				push
				reload
				remove
				rename
				resize
				restart
				save
				start
				stop
				tag
				top
				unmount
				unpause
				untag
				update
			" -- "${cur##*=}" ) )
			return
			;;
		image)
			__docker_complete_images --cur "${cur##*=}" --repo --tag
			return
			;;
		network)
			__docker_complete_networks --cur "${cur##*=}"
			return
			;;
		scope)
			COMPREPLY=( $( compgen -W "local swarm" -- "${cur##*=}" ) )
			return
			;;
		type)
			COMPREPLY=( $( compgen -W "config container daemon image network plugin secret service volume" -- "${cur##*=}" ) )
			return
			;;
		volume)
			__docker_complete_volumes --cur "${cur##*=}"
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "container daemon event image label network scope type volume" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--since|--until)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --help --since --until --format" -- "$cur" ) )
			;;
	esac
}

_docker_system_info() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help" -- "$cur" ) )
			;;
	esac
}

_docker_system_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "label label! until" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --force -f --filter --help --volumes" -- "$cur" ) )
			;;
	esac
}


_docker_tag() {
	_docker_image_tag
}


_docker_trust() {
	local subcommands="
		inspect
		revoke
		sign
	"
	__docker_subcommands "$subcommands" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_trust_inspect() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --pretty" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --repo --tag
			fi
			;;
	esac
}

_docker_trust_revoke() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --yes -y" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --repo --tag
			fi
			;;
	esac
}

_docker_trust_sign() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --local" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ "$cword" -eq "$counter" ]; then
				__docker_complete_images --force-tag --id
			fi
			;;
	esac
}


_docker_unpause() {
	_docker_container_unpause
}

_docker_update() {
	_docker_container_update
}

_docker_top() {
	_docker_container_top
}

_docker_version() {
	__docker_complete_stack_orchestrator_options && return

	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			local options="--format -f --help"
			__docker_stack_orchestrator_is kubernetes && options+=" --kubeconfig"
			COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
			;;
	esac
}

_docker_volume_create() {
	case "$prev" in
		--driver|-d)
			__docker_complete_plugins_bundled --type Volume
			return
			;;
		--label|--opt|-o)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--driver -d --help --label --opt -o" -- "$cur" ) )
			;;
	esac
}

_docker_volume_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_volumes
			;;
	esac
}

_docker_volume_list() {
	_docker_volume_ls
}

_docker_volume_ls() {
	local key=$(__docker_map_key_of_current_option '--filter|-f')
	case "$key" in
		dangling)
			COMPREPLY=( $( compgen -W "true false" -- "${cur##*=}" ) )
			return
			;;
		driver)
			__docker_complete_plugins_bundled --cur "${cur##*=}" --type Volume
			return
			;;
		name)
			__docker_complete_volumes --cur "${cur##*=}"
			return
			;;
	esac

	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "dangling driver label name" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --format --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_volume_prune() {
	case "$prev" in
		--filter)
			COMPREPLY=( $( compgen -W "label label!" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter --force -f --help" -- "$cur" ) )
			;;
	esac
}

_docker_volume_remove() {
	_docker_volume_rm
}

_docker_volume_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_volumes
			;;
	esac
}

_docker_volume() {
	local subcommands="
		create
		inspect
		ls
		prune
		rm
	"
	local aliases="
		list
		remove
	"
	__docker_subcommands "$subcommands $aliases" && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			COMPREPLY=( $( compgen -W "$subcommands" -- "$cur" ) )
			;;
	esac
}

_docker_wait() {
	_docker_container_wait
}

_docker() {
	local previous_extglob_setting=$(shopt -p extglob)
	shopt -s extglob

	local management_commands=(
		builder
		config
		container
		context
		engine
		image
		network
		node
		plugin
		secret
		service
		stack
		swarm
		system
		trust
		volume
	)

	local top_level_commands=(
		build
		login
		logout
		run
		search
		version
	)

	local legacy_commands=(
		attach
		commit
		cp
		create
		diff
		events
		exec
		export
		history
		images
		import
		info
		inspect
		kill
		load
		logs
		pause
		port
		ps
		pull
		push
		rename
		restart
		rm
		rmi
		save
		start
		stats
		stop
		tag
		top
		unpause
		update
		wait
	)

	local experimental_client_commands=(
		manifest
	)

	local experimental_server_commands=(
		checkpoint
		deploy
	)

	local commands=(${management_commands[*]} ${top_level_commands[*]})
	[ -z "$DOCKER_HIDE_LEGACY_COMMANDS" ] && commands+=(${legacy_commands[*]})

	# These options are valid as global options for all client commands
	# and valid as command options for `docker daemon`
	local global_boolean_options="
		--debug -D
		--tls
		--tlsverify
	"
	local global_options_with_args="
		--config
		--context -c
		--host -H
		--log-level -l
		--tlscacert
		--tlscert
		--tlskey
	"

	# variables to cache server info, populated on demand for performance reasons
	local info_fetched server_experimental server_os
	# variables to cache client info, populated on demand for performance reasons
	local client_experimental stack_orchestrator_is_kubernetes stack_orchestrator_is_swarm

	local host config context

	COMPREPLY=()
	local cur prev words cword
	_get_comp_words_by_ref -n : cur prev words cword

	local command='docker' command_pos=0 subcommand_pos
	local counter=1
	while [ "$counter" -lt "$cword" ]; do
		case "${words[$counter]}" in
			docker)
				return 0
				;;
			# save host so that completion can use custom daemon
			--host|-H)
				(( counter++ ))
				host="${words[$counter]}"
				;;
			# save config so that completion can use custom configuration directories
			--config)
				(( counter++ ))
				config="${words[$counter]}"
				;;
			# save context so that completion can use custom daemon
			--context|-c)
				(( counter++ ))
				context="${words[$counter]}"
				;;
			$(__docker_to_extglob "$global_options_with_args") )
				(( counter++ ))
				;;
			-*)
				;;
			=)
				(( counter++ ))
				;;
			*)
				command="${words[$counter]}"
				command_pos=$counter
				break
				;;
		esac
		(( counter++ ))
	done

	local binary="${words[0]}"
	if [[ $binary == ?(*/)dockerd ]] ; then
		# for the dockerd binary, we reuse completion of `docker daemon`.
		# dockerd does not have subcommands and global options.
		command=daemon
		command_pos=0
	fi

	local completions_func=_docker_${command//-/_}
	declare -F $completions_func >/dev/null && $completions_func

	eval "$previous_extglob_setting"
	return 0
}

eval "$__docker_previous_extglob_setting"
unset __docker_previous_extglob_setting

complete -F _docker docker docker.exe dockerd dockerd.exe
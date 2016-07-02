#!/bin/bash
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
# DOCKER_COMPLETION_SHOW_NETWORK_IDS
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
	docker ${host:+-H "$host"} ${config:+--config "$config"} 2>/dev/null "$@"
}

__docker_complete_containers_all() {
	local IFS=$'\n'
	local containers=( $(__docker_q ps -aq --no-trunc) )
	if [ "$1" ]; then
		containers=( $(__docker_q inspect --format "{{if $1}}{{.Id}}{{end}}" "${containers[@]}") )
	fi
	local names=( $(__docker_q inspect --format '{{.Name}}' "${containers[@]}") )
	names=( "${names[@]#/}" ) # trim off the leading "/" from the container names
	unset IFS
	COMPREPLY=( $(compgen -W "${names[*]} ${containers[*]}" -- "$cur") )
}

__docker_complete_containers_running() {
	__docker_complete_containers_all '.State.Running'
}

__docker_complete_containers_stopped() {
	__docker_complete_containers_all 'not .State.Running'
}

__docker_complete_containers_pauseable() {
	__docker_complete_containers_all 'and .State.Running (not .State.Paused)'
}

__docker_complete_containers_unpauseable() {
	__docker_complete_containers_all '.State.Paused'
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

__docker_complete_images() {
	local images_args=""

	case "$DOCKER_COMPLETION_SHOW_IMAGE_IDS" in
		all)
			images_args="--no-trunc -a"
			;;
		non-intermediate)
			images_args="--no-trunc"
			;;
	esac

	local repo_print_command
	if [ "${DOCKER_COMPLETION_SHOW_TAGS:-yes}" = "yes" ]; then
		repo_print_command='print $1; print $1":"$2'
	else
		repo_print_command='print $1'
	fi

	local awk_script
	case "$DOCKER_COMPLETION_SHOW_IMAGE_IDS" in
		all|non-intermediate)
			awk_script='NR>1 { print $3; if ($1 != "<none>") { '"$repo_print_command"' } }'
			;;
		none|*)
			awk_script='NR>1 && $1 != "<none>" { '"$repo_print_command"' }'
			;;
	esac

	local images=$(__docker_q images $images_args | awk "$awk_script")
	COMPREPLY=( $(compgen -W "$images" -- "$cur") )
	__ltrim_colon_completions "$cur"
}

__docker_complete_image_repos() {
	local repos="$(__docker_q images | awk 'NR>1 && $1 != "<none>" { print $1 }')"
	COMPREPLY=( $(compgen -W "$repos" -- "$cur") )
}

__docker_complete_image_repos_and_tags() {
	local reposAndTags="$(__docker_q images | awk 'NR>1 && $1 != "<none>" { print $1; print $1":"$2 }')"
	COMPREPLY=( $(compgen -W "$reposAndTags" -- "$cur") )
	__ltrim_colon_completions "$cur"
}

__docker_complete_containers_and_images() {
	__docker_complete_containers_all
	local containers=( "${COMPREPLY[@]}" )
	__docker_complete_images
	COMPREPLY+=( "${containers[@]}" )
}

__docker_networks() {
	# By default, only network names are completed.
	# Set DOCKER_COMPLETION_SHOW_NETWORK_IDS=yes to also complete network IDs.
	local fields='$2'
	[ "${DOCKER_COMPLETION_SHOW_NETWORK_IDS}" = yes ] && fields='$1,$2'
	__docker_q network ls --no-trunc | awk "NR>1 {print $fields}"
}

__docker_complete_networks() {
	COMPREPLY=( $(compgen -W "$(__docker_networks)" -- "$cur") )
}

__docker_complete_network_ids() {
	COMPREPLY=( $(compgen -W "$(__docker_q network ls -q --no-trunc)" -- "$cur") )
}

__docker_complete_network_names() {
	COMPREPLY=( $(compgen -W "$(__docker_q network ls | awk 'NR>1 {print $2}')" -- "$cur") )
}

__docker_complete_containers_in_network() {
	local containers=$(__docker_q network inspect -f '{{range $i, $c := .Containers}}{{$i}} {{$c.Name}} {{end}}' "$1")
	COMPREPLY=( $(compgen -W "$containers" -- "$cur") )
}

__docker_complete_volumes() {
	COMPREPLY=( $(compgen -W "$(__docker_q volume ls -q)" -- "$cur") )
}

__docker_plugins() {
	__docker_q info | sed -n "/^Plugins/,/^[^ ]/s/ $1: //p"
}

__docker_complete_plugins() {
	COMPREPLY=( $(compgen -W "$(__docker_plugins $1)" -- "$cur") )
}

# Finds the position of the first word that is neither option nor an option's argument.
# If there are options that require arguments, you should pass a glob describing those
# options, e.g. "--option1|-o|--option2"
# Use this function to restrict completions to exact positions after the argument list.
__docker_pos_first_nonflag() {
	local argument_flags=$1

	local counter=$((${subcommand_pos:-${command_pos}} + 1))
	while [ $counter -le $cword ]; do
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

# Returns the value of the first option matching option_glob.
# Valid values for option_glob are option names like '--log-level' and
# globs like '--log-level|-l'
# Only positions between the command and the current word are considered.
__docker_value_of_option() {
	local option_extglob=$(__docker_to_extglob "$1")

	local counter=$((command_pos + 1))
	while [ $counter -lt $cword ]; do
		case ${words[$counter]} in
			$option_extglob )
				echo ${words[$counter + 1]}
				break
				;;
		esac
		(( counter++ ))
	done
}

# Transforms a multiline list of strings into a single line string
# with the words separated by "|".
# This is used to prepare arguments to __docker_pos_first_nonflag().
__docker_to_alternatives() {
	local parts=( $1 )
	local IFS='|'
	echo "${parts[*]}"
}

# Transforms a multiline list of options into an extglob pattern
# suitable for use in case statements.
__docker_to_extglob() {
	local extglob=$( __docker_to_alternatives "$1" )
	echo "@($extglob)"
}

# Subcommand processing.
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

	local counter=$(($command_pos + 1))
	while [ $counter -lt $cword ]; do
		case "${words[$counter]}" in
			$(__docker_to_extglob "$subcommands") )
				subcommand_pos=$counter
				local subcommand=${words[$counter]}
				local completions_func=_docker_${command}_${subcommand}
				declare -F $completions_func >/dev/null && $completions_func
				return 0
				;;
		esac
		(( counter++ ))
	done
	return 1
}

# suppress trailing whitespace
__docker_nospace() {
	# compopt is not available in ancient bash versions
	type compopt &>/dev/null && compopt -o nospace
}

__docker_complete_resolved_hostname() {
	command -v host >/dev/null 2>&1 || return
	COMPREPLY=( $(host 2>/dev/null "${cur%:}" | awk '/has address/ {print $4}') )
}

__docker_complete_capabilities() {
	# The list of capabilities is defined in types.go, ALL was added manually.
	COMPREPLY=( $( compgen -W "
		ALL
		AUDIT_CONTROL
		AUDIT_WRITE
		AUDIT_READ
		BLOCK_SUSPEND
		CHOWN
		DAC_OVERRIDE
		DAC_READ_SEARCH
		FOWNER
		FSETID
		IPC_LOCK
		IPC_OWNER
		KILL
		LEASE
		LINUX_IMMUTABLE
		MAC_ADMIN
		MAC_OVERRIDE
		MKNOD
		NET_ADMIN
		NET_BIND_SERVICE
		NET_BROADCAST
		NET_RAW
		SETFCAP
		SETGID
		SETPCAP
		SETUID
		SYS_ADMIN
		SYS_BOOT
		SYS_CHROOT
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

__docker_complete_isolation() {
	COMPREPLY=( $( compgen -W "default hyperv process" -- "$cur" ) )
}

__docker_complete_log_drivers() {
	COMPREPLY=( $( compgen -W "
		awslogs
		fluentd
		gelf
		journald
		json-file
		none
		splunk
		syslog
	" -- "$cur" ) )
}

__docker_complete_log_options() {
	# see docs/reference/logging/index.md
	local awslogs_options="awslogs-region awslogs-group awslogs-stream"
	local fluentd_options="env fluentd-address labels tag"
	local gelf_options="env gelf-address labels tag"
	local journald_options="env labels"
	local json_file_options="env labels max-file max-size"
	local syslog_options="syslog-address syslog-facility tag"
	local splunk_options="env labels splunk-caname splunk-capath splunk-index splunk-insecureskipverify splunk-source splunk-sourcetype splunk-token splunk-url tag"

	local all_options="$fluentd_options $gelf_options $journald_options $json_file_options $syslog_options $splunk_options"

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
		gelf)
			COMPREPLY=( $( compgen -W "$gelf_options" -S = -- "$cur" ) )
			;;
		journald)
			COMPREPLY=( $( compgen -W "$journald_options" -S = -- "$cur" ) )
			;;
		json-file)
			COMPREPLY=( $( compgen -W "$json_file_options" -S = -- "$cur" ) )
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
	# "=" gets parsed to a word and assigned to either $cur or $prev depending on whether
	# it is the last character or not. So we search for "xxx=" in the the last two words.
	case "${words[$cword-2]}$prev=" in
		*gelf-address=*)
			COMPREPLY=( $( compgen -W "udp" -S "://" -- "${cur#=}" ) )
			__docker_nospace
			return
			;;
		*syslog-address=*)
			COMPREPLY=( $( compgen -W "tcp udp unix" -S "://" -- "${cur#=}" ) )
			__docker_nospace
			return
			;;
		*syslog-facility=*)
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
			" -- "${cur#=}" ) )
			return
			;;
		*splunk-url=*)
			COMPREPLY=( $( compgen -W "http:// https://" -- "${cur#=}" ) )
			compopt -o nospace
			__ltrim_colon_completions "${cur}"
			return
			;;
		*splunk-insecureskipverify=*)
			COMPREPLY=( $( compgen -W "true false" -- "${cur#=}" ) )
			compopt -o nospace
			return
			;;
	esac
	return 1
}

__docker_complete_log_levels() {
	COMPREPLY=( $( compgen -W "debug info warn error fatal" -- "$cur" ) )
}

# a selection of the available signals that is most likely of interest in the
# context of docker containers.
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
	COMPREPLY=( $( compgen -W "${signals[*]} ${signals[*]#SIG}" -- "$( echo $cur | tr '[:lower:]' '[:upper:]')" ) )
}

# global options that may appear after the docker command
_docker_docker() {
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
			local counter=$( __docker_pos_first_nonflag $(__docker_to_extglob "$global_options_with_args") )
			if [ $cword -eq $counter ]; then
				COMPREPLY=( $( compgen -W "${commands[*]} help" -- "$cur" ) )
			fi
			;;
	esac
}

_docker_attach() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --no-stdin --sig-proxy" -- "$cur" ) )
			;;
		*)
			local counter="$(__docker_pos_first_nonflag)"
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_build() {
	local options_with_args="
		--build-arg
		--cgroup-parent
		--cpuset-cpus
		--cpuset-mems
		--cpu-shares
		--cpu-period
		--cpu-quota
		--file -f
		--isolation
		--memory -m
		--memory-swap
		--tag -t
		--ulimit
	"

	local boolean_options="
		--disable-content-trust=false
		--force-rm
		--help
		--no-cache
		--pull
		--quiet -q
		--rm
	"

	local all_options="$options_with_args $boolean_options"

	case "$prev" in
		--build-arg)
			COMPREPLY=( $( compgen -e -- "$cur" ) )
			__docker_nospace
			return
			;;
		--file|-f)
			_filedir
			return
			;;
		--isolation)
			__docker_complete_isolation
			return
			;;
		--tag|-t)
			__docker_complete_image_repos_and_tags
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
			local counter=$( __docker_pos_first_nonflag $( __docker_to_alternatives "$options_with_args" ) )
			if [ $cword -eq $counter ]; then
				_filedir -d
			fi
			;;
	esac
}

_docker_commit() {
	case "$prev" in
		--author|-a|--change|-c|--message|-m)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--author -a --change -c --help --message -m --pause -p" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--author|-a|--change|-c|--message|-m')

			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
				return
			fi
			(( counter++ ))

			if [ $cword -eq $counter ]; then
				__docker_complete_image_repos_and_tags
				return
			fi
			;;
	esac
}

_docker_cp() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
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
						if [[ "$COMPREPLY" == *: ]]; then
							__docker_nospace
						fi
						return
						;;
				esac
			fi
			(( counter++ ))

			if [ $cword -eq $counter ]; then
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

_docker_create() {
	_docker_run
}

_docker_daemon() {
	local boolean_options="
		$global_boolean_options
		--disable-legacy-registry
		--help
		--icc=false
		--ip-forward=false
		--ip-masq=false
		--iptables=false
		--ipv6
		--selinux-enabled
		--userland-proxy=false
	"
	local options_with_args="
		$global_options_with_args
		--api-cors-header
		--authz-plugin
		--bip
		--bridge -b
		--cgroup-parent
		--cluster-advertise
		--cluster-store
		--cluster-store-opt
		--default-gateway
		--default-gateway-v6
		--default-ulimit
		--dns
		--dns-search
		--dns-opt
		--exec-opt
		--exec-root
		--fixed-cidr
		--fixed-cidr-v6
		--graph -g
		--group -G
		--insecure-registry
		--ip
		--label
		--log-driver
		--log-opt
		--mtu
		--pidfile -p
		--registry-mirror
		--storage-driver -s
		--storage-opt
	"

	case "$prev" in
		--authz-plugin)
			__docker_complete_plugins Authorization
			return
			;;
		--cluster-store)
			COMPREPLY=( $( compgen -W "consul etcd zk" -S "://" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--cluster-store-opt)
			COMPREPLY=( $( compgen -W "kv.cacertfile kv.certfile kv.keyfile" -S = -- "$cur" ) )
			__docker_nospace
			return
			;;
		--exec-root|--graph|-g)
			_filedir -d
			return
			;;
		--log-driver)
			__docker_complete_log_drivers
			return
			;;
		--pidfile|-p|--tlscacert|--tlscert|--tlskey)
			_filedir
			return
			;;
		--storage-driver|-s)
			COMPREPLY=( $( compgen -W "aufs btrfs devicemapper overlay vfs zfs" -- "$(echo $cur | tr '[:upper:]' '[:lower:]')" ) )
			return
			;;
		--storage-opt)
			local devicemapper_options="
				dm.basesize
				dm.blkdiscard
				dm.blocksize
				dm.fs
				dm.loopdatasize
				dm.loopmetadatasize
				dm.mkfsarg
				dm.mountopt
				dm.override_udev_sync_check
				dm.thinpooldev
				dm.use_deferred_deletion
				dm.use_deferred_removal
			"
			local zfs_options="zfs.fsname"

			case $(__docker_value_of_option '--storage-driver|-s') in
				'')
					COMPREPLY=( $( compgen -W "$devicemapper_options $zfs_options" -S = -- "$cur" ) )
					;;
				devicemapper)
					COMPREPLY=( $( compgen -W "$devicemapper_options" -S = -- "$cur" ) )
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
		$(__docker_to_extglob "$options_with_args") )
			return
			;;
	esac

	__docker_complete_log_driver_options && return

	case "${words[$cword-2]}$prev=" in
		# completions for --storage-opt
		*dm.@(blkdiscard|override_udev_sync_check|use_deferred_@(removal|deletion))=*)
			COMPREPLY=( $( compgen -W "false true" -- "${cur#=}" ) )
			return
			;;
		*dm.fs=*)
			COMPREPLY=( $( compgen -W "ext4 xfs" -- "${cur#=}" ) )
			return
			;;
		*dm.thinpooldev=*)
			_filedir
			return
			;;
		# completions for --cluster-store-opt
		*kv.*file=*)
			_filedir
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$boolean_options $options_with_args" -- "$cur" ) )
			;;
	esac
}

_docker_diff() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_events() {
	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "container event image" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--since|--until)
			return
			;;
	esac

	case "${words[$cword-2]}$prev=" in
		*container=*)
			cur="${cur#=}"
			__docker_complete_containers_all
			return
			;;
		*event=*)
			COMPREPLY=( $( compgen -W "
				attach
				commit
				copy
				create
				delete
				destroy
				die
				exec_create
				exec_start
				export
				import
				kill
				oom
				pause
				pull
				push
				rename
				resize
				restart
				start
				stop
				tag
				top
				unpause
				untag
			" -- "${cur#=}" ) )
			return
			;;
		*image=*)
			cur="${cur#=}"
			__docker_complete_images
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --help --since --until" -- "$cur" ) )
			;;
	esac
}

_docker_exec() {
	case "$prev" in
		--user|-u)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--detach -d --help --interactive -i --privileged -t --tty -u --user" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_export() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_help() {
	local counter=$(__docker_pos_first_nonflag)
	if [ $cword -eq $counter ]; then
		COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
	fi
}

_docker_history() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --no-trunc --quiet -q" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_images
			fi
			;;
	esac
}

_docker_images() {
	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "dangling=true label=" -- "$cur" ) )
			if [ "$COMPREPLY" = "label=" ]; then
				__docker_nospace
			fi
			return
			;;
                --format)
			return
			;;
	esac

	case "${words[$cword-2]}$prev=" in
		*dangling=*)
			COMPREPLY=( $( compgen -W "true false" -- "${cur#=}" ) )
			return
			;;
		*label=*)
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
			__docker_complete_image_repos
			;;
	esac
}

_docker_import() {
	case "$prev" in
		--change|-c|--message|-m)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--change -c --help --message -m" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--change|-c|--message|-m')
			if [ $cword -eq $counter ]; then
				return
			fi
			(( counter++ ))

			if [ $cword -eq $counter ]; then
				__docker_complete_image_repos_and_tags
				return
			fi
			;;
	esac
}

_docker_info() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
	esac
}

_docker_inspect() {
	case "$prev" in
		--format|-f)
			return
			;;
		--type)
                     COMPREPLY=( $( compgen -W "image container" -- "$cur" ) )
                     return
                        ;;

	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--format -f --help --size -s --type" -- "$cur" ) )
			;;
		*)
			case $(__docker_value_of_option --type) in
				'')
					__docker_complete_containers_and_images
					;;
				container)
					__docker_complete_containers_all
					;;
				image)
					__docker_complete_images
					;;
			esac
	esac
}

_docker_kill() {
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

_docker_load() {
	case "$prev" in
		--input|-i)
			_filedir
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help --input -i" -- "$cur" ) )
			;;
	esac
}

_docker_login() {
	case "$prev" in
		--email|-e|--password|-p|--username|-u)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--email -e --help --password -p --username -u" -- "$cur" ) )
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
	case "$prev" in
		--since|--tail)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--follow -f --help --since --tail --timestamps -t" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag '--tail')
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_network_connect() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_networks
			elif [ $cword -eq $(($counter + 1)) ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_network_create() {
	case "$prev" in
		--aux-address|--gateway|--ip-range|--opt|-o|--subnet)
			return
			;;
		--ipam-driver)
			COMPREPLY=( $( compgen -W "default" -- "$cur" ) )
			return
			;;
		--driver|-d)
			local plugins=" $(__docker_plugins Network) "
			# remove drivers that allow one instance only
			plugins=${plugins/ host / }
			plugins=${plugins/ null / }
			COMPREPLY=( $(compgen -W "$plugins" -- "$cur") )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--aux-address --driver -d --gateway --help --ip-range --ipam-driver --opt -o --subnet" -- "$cur" ) )
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
			if [ $cword -eq $counter ]; then
				__docker_complete_networks
			elif [ $cword -eq $(($counter + 1)) ]; then
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
			COMPREPLY=( $( compgen -W "--format -f --help" -- "$cur" ) )
			;;
		*)
			__docker_complete_networks
	esac
}

_docker_network_ls() {
	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "id name type" -- "$cur" ) )
			__docker_nospace
			return
			;;
	esac

	case "${words[$cword-2]}$prev=" in
		*id=*)
			cur="${cur#=}"
			__docker_complete_network_ids
			return
			;;
		*name=*)
			cur="${cur#=}"
			__docker_complete_network_names
			return
			;;
		*type=*)
			COMPREPLY=( $( compgen -W "builtin custom" -- "${cur#=}" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --help --no-trunc --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_network_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_networks
	esac
}

_docker_network() {
	local subcommands="
		connect
		create
		disconnect
		inspect
		ls
		rm
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

_docker_pause() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_pauseable
			fi
			;;
	esac
}

_docker_port() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_ps() {
	case "$prev" in
		--before|--since)
			__docker_complete_containers_all
			;;
		--filter|-f)
			COMPREPLY=( $( compgen -S = -W "ancestor exited id label name status" -- "$cur" ) )
			__docker_nospace
			return
			;;
		--format|-n)
			return
			;;
	esac

	case "${words[$cword-2]}$prev=" in
		*ancestor=*)
			cur="${cur#=}"
			__docker_complete_images
			return
			;;
		*id=*)
			cur="${cur#=}"
			__docker_complete_container_ids
			return
			;;
		*name=*)
			cur="${cur#=}"
			__docker_complete_container_names
			return
			;;
		*status=*)
			COMPREPLY=( $( compgen -W "exited paused restarting running" -- "${cur#=}" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --before --filter -f --format --help --latest -l -n --no-trunc --quiet -q --size -s --since" -- "$cur" ) )
			;;
	esac
}

_docker_pull() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all-tags -a --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				for arg in "${COMP_WORDS[@]}"; do
					case "$arg" in
						--all-tags|-a)
							__docker_complete_image_repos
							return
							;;
					esac
				done
				__docker_complete_image_repos_and_tags
			fi
			;;
	esac
}

_docker_push() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_image_repos_and_tags
			fi
			;;
	esac
}

_docker_rename() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_all
			fi
			;;
	esac
}

_docker_restart() {
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

_docker_rm() {
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
			__docker_complete_containers_stopped
			;;
	esac
}

_docker_rmi() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help --no-prune" -- "$cur" ) )
			;;
		*)
			__docker_complete_images
			;;
	esac
}

_docker_run() {
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
		--cpuset-cpus
		--cpuset-mems
		--cpu-shares
		--device
		--device-read-bps
		--device-read-iops
		--device-write-bps
		--device-write-iops
		--dns
		--dns-opt
		--dns-search
		--entrypoint
		--env -e
		--env-file
		--expose
		--group-add
		--hostname -h
		--ipc
		--isolation
		--kernel-memory
		--label-file
		--label -l
		--link
		--log-driver
		--log-opt
		--mac-address
		--memory -m
		--memory-swap
		--memory-swappiness
		--memory-reservation
		--name
		--net
		--oom-score-adj
		--pid
		--publish -p
		--restart
		--security-opt
		--stop-signal
		--tmpfs
		--ulimit
		--user -u
		--uts
		--volume-driver
		--volumes-from
		--volume -v
		--workdir -w
	"

	local boolean_options="
		--disable-content-trust=false
		--help
		--interactive -i
		--oom-kill-disable
		--privileged
		--publish-all -P
		--read-only
		--tty -t
	"

	local all_options="$options_with_args $boolean_options"

	[ "$command" = "run" ] && all_options="$all_options
		--detach -d
		--rm
		--sig-proxy=false
	"

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
		--cap-add|--cap-drop)
			__docker_complete_capabilities
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
					COMPREPLY=( $( compgen -W 'host container:' -- "$cur" ) )
					if [ "$COMPREPLY" = "container:" ]; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
		--isolation)
			__docker_complete_isolation
			return
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
		--net)
			case "$cur" in
				container:*)
					local cur=${cur#*:}
					__docker_complete_containers_all
					;;
				*)
					COMPREPLY=( $( compgen -W "$(__docker_plugins Network) $(__docker_networks) container:" -- "$cur") )
					if [ "${COMPREPLY[*]}" = "container:" ] ; then
						__docker_nospace
					fi
					;;
			esac
			return
			;;
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
		--security-opt)
			case "$cur" in
				label:*:*)
					;;
				label:*)
					local cur=${cur##*:}
					COMPREPLY=( $( compgen -W "user: role: type: level: disable" -- "$cur") )
					if [ "${COMPREPLY[*]}" != "disable" ] ; then
						__docker_nospace
					fi
					;;
				*)
					COMPREPLY=( $( compgen -W "label apparmor seccomp" -S ":" -- "$cur") )
					__docker_nospace
					;;
			esac
			return
			;;
		--volume-driver)
			__docker_complete_plugins Volume
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

	__docker_complete_log_driver_options && return

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "$all_options" -- "$cur" ) )
			;;
		*)
			local counter=$( __docker_pos_first_nonflag $( __docker_to_alternatives "$options_with_args" ) )
			if [ $cword -eq $counter ]; then
				__docker_complete_images
			fi
			;;
	esac
}

_docker_save() {
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
			__docker_complete_images
			;;
	esac
}

_docker_search() {
	case "$prev" in
		--stars|-s)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--automated --help --no-trunc --stars -s" -- "$cur" ) )
			;;
	esac
}

_docker_start() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--attach -a --help --interactive -i" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_stopped
			;;
	esac
}

_docker_stats() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--all -a --help --no-stream" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_running
			;;
	esac
}

_docker_stop() {
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
			__docker_complete_containers_running
			;;
	esac
}

_docker_tag() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--force -f --help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)

			if [ $cword -eq $counter ]; then
				__docker_complete_image_repos_and_tags
				return
			fi
			(( counter++ ))

			if [ $cword -eq $counter ]; then
				__docker_complete_image_repos_and_tags
				return
			fi
			;;
	esac
}

_docker_unpause() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_unpauseable
			fi
			;;
	esac
}

_docker_update() {
	local options_with_args="
		--blkio-weight
		--cpu-period
		--cpu-quota
		--cpuset-cpus
		--cpuset-mems
		--cpu-shares
		--kernel-memory
		--memory -m
		--memory-reservation
		--memory-swap
	"

	local boolean_options="
		--help
	"

	local all_options="$options_with_args $boolean_options"

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

_docker_top() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			local counter=$(__docker_pos_first_nonflag)
			if [ $cword -eq $counter ]; then
				__docker_complete_containers_running
			fi
			;;
	esac
}

_docker_version() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
	esac
}

_docker_volume_create() {
	case "$prev" in
		--driver|-d)
			__docker_complete_plugins Volume
			return
			;;
		--name|--opt|-o)
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--driver -d --help --name --opt -o" -- "$cur" ) )
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

_docker_volume_ls() {
	case "$prev" in
		--filter|-f)
			COMPREPLY=( $( compgen -W "dangling=true" -- "$cur" ) )
			return
			;;
	esac

	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--filter -f --help --quiet -q" -- "$cur" ) )
			;;
	esac
}

_docker_volume_rm() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
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
		rm
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

_docker_wait() {
	case "$cur" in
		-*)
			COMPREPLY=( $( compgen -W "--help" -- "$cur" ) )
			;;
		*)
			__docker_complete_containers_all
			;;
	esac
}

_docker() {
	local previous_extglob_setting=$(shopt -p extglob)
	shopt -s extglob

	local commands=(
		attach
		build
		commit
		cp
		create
		daemon
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
		login
		logout
		logs
		network
		pause
		port
		ps
		pull
		push
		rename
		restart
		rm
		rmi
		run
		save
		search
		start
		stats
		stop
		tag
		top
		unpause
		update
		version
		volume
		wait
	)

	# These options are valid as global options for all client commands
	# and valid as command options for `docker daemon`
	local global_boolean_options="
		--debug -D
		--tls
		--tlsverify
	"
	local global_options_with_args="
		--config
		--host -H
		--log-level -l
		--tlscacert
		--tlscert
		--tlskey
	"

	local host config

	COMPREPLY=()
	local cur prev words cword
	_get_comp_words_by_ref -n : cur prev words cword

	local command='docker' command_pos=0 subcommand_pos
	local counter=1
	while [ $counter -lt $cword ]; do
		case "${words[$counter]}" in
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

	local completions_func=_docker_${command}
	declare -F $completions_func >/dev/null && $completions_func

	eval "$previous_extglob_setting"
	return 0
}

eval "$__docker_previous_extglob_setting"
unset __docker_previous_extglob_setting

complete -F _docker docker

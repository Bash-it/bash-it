# shellcheck shell=bash disable=2207
# vim: set fdm=syntax fdl=0:
#
# Version: 0.17.0
# Yarn Version: 1.22.11
#
# bash completion for Yarn (https://github.com/yarnpkg/yarn)
#
# To enable on-demand completion loading, copy this file to one of the following locations:
#  - $BASH_COMPLETION_USER_DIR/completions/yarn
#  or
#  - $XDG_DATA_HOME/bash-completion/completions/yarn
#  or
#  - ~/.local/share/bash-completion/completions/yarn
#

###
# Parses and extracts data from package.json files.
#
# Usage:
#	__yarn_get_package_fields [-g] [-t FIELDTYPE] <field-key>
#
# Options:
#   -g			  Parse global package.json file, if available
#   -t FIELDTYPE  The field type being parsed (array|boolean|number|object|string) [default: object]
#
# Notes:
#	If FIELDTYPE is object, then the object keys are returned.
#	If FIELDTYPE is array, boolean, number, or string, then the field values are returned.
#	<field-key> must be a first-level field in the json file.
##
__yarn_get_package_fields() {
	declare cwd=$PWD field_type=object field_key opt package_dot_json OPTIND OPTARG

	while [[ -n $cwd ]]; do
		if [[ -f "$cwd/package.json" ]]; then
			package_dot_json="$cwd/package.json"
			break
		fi
		cwd="${cwd%/*}"
	done

	while getopts ":gt:" opt; do
		case $opt in
			g)
				if [[ -f $HOME/.config/yarn/global/package.json ]]; then
					package_dot_json="$HOME/.config/yarn/global/package.json"
				elif [[ -f $HOME/.local/share/yarn/global/package.json ]]; then
					package_dot_json="$HOME/.local/share/yarn/global/package.json"
				elif [[ -f $HOME/.yarn/global/package.json ]]; then
					package_dot_json="$HOME/.yarn/global/package.json"
				else
					package_dot_json=""
				fi
				;;
			t)
				case "$OPTARG" in
					array | boolean | number | object | string)
						field_type="$OPTARG"
						;;
				esac
				;;
			*) ;;

		esac
	done
	shift $((OPTIND - 1))

	field_key='"'$1'"'

	[[ ! -f $package_dot_json || ! $field_key ]] && return

	case "$field_type" in
		object)
			sed -n '/'"$field_key"':[[:space:]]*{/,/^[[:space:]]*}/{
				# exclude start and end patterns
				//!{
					# extract the text between the first pair of double quotes
					s/^[[:space:]]*"\([^"]*\).*/\1/p
				}
			}' "$package_dot_json"
			;;
		array)
			sed -n '/'"$field_key"':[[:space:]]*\[/,/^[[:space:]]*]/{
				# exclude start and end patterns
				//!{
					# extract the text between the first pair of double quotes
					s/^[[:space:]]*"\([^"]*\).*/\1/p
				}
			}' "$package_dot_json"
			;;
		boolean | number)
			sed -n 's/[[:space:]]*'"$field_key"':[[:space:]]*\([a-z0-9]*\)/\1/p' "$package_dot_json"
			;;
		string)
			sed -n 's/[[:space:]]*'"$field_key"':[[:space:]]*"\(.*\)".*/\1/p' "$package_dot_json"
			;;
	esac
}

###
# Count all command arguments starting at a given depth, excluding flags and
# flag arguments.
#
# Usage:
#	__yarn_count_args [-d INT]
#
# Options:
#   -d INT  The start depth to begin counting [default: 0]
#
# Globals:
#  *args
#   cword
##
__yarn_count_args() {
	args=0
	declare -i counter=0 depth=0
	declare arg_flag_pattern opt OPTIND
	arg_flag_pattern="@($(tr ' ' '|' <<< "${arg_flags[*]}"))"

	while getopts ":d:" opt; do
		case $opt in
			d)
				depth=$OPTARG
				;;
			*) ;;
		esac
	done
	shift $((OPTIND - 1))

	while ((counter < cword)); do
		case ${words[counter]} in
			-* | =) ;;
			*)
				# shellcheck disable=SC2053
				if [[ ${words[counter - 1]} != $arg_flag_pattern ]]; then
					if ((depth-- <= 0)); then
						((args++))
					fi
				fi
				;;
		esac
		((counter++))
	done
}

###
# Retrieves the command or subcommand at a given depth, or the last occurring
# command or subcommand before the cursor location if no depth is given, or if
# depth exceeds cursor location.
#
# Usage:
#   __yarn_get_command [-d INT]
#
# Options:
#   -d INT  Depth of command to retrieve.
#
# Globals:
#  *cmd
#   commands
#   cword
#   subcommands
#   words
##
__yarn_get_command() {
	declare -i counter=0 cmd_depth=0 OPTIND
	declare cmdlist word opt

	while getopts ":d:" opt; do
		case $opt in
			d)
				cmd_depth="$OPTARG"
				;;
			*) ;;
		esac
	done
	shift $((OPTIND - 1))

	cmdlist="@($(tr ' ' '|' <<< "${commands[*]} ${subcommands[*]}"))"
	cmd=yarn

	while ((counter < cword)); do
		word="${words[counter]}"
		case "$word" in
			$cmdlist)
				cmd="$word"
				((--cmd_depth == 0)) && break
				;;
		esac
		((counter++))
	done
}

###
# Global fallback completion generator if all else fails.
#
# Usage:
#   __yarn_fallback
#
# Globals:
#   cur
##
__yarn_fallback() {
	case "$cur" in
		-*)
			COMPREPLY=($(compgen -W "$(__yarn_flags)" -- "$cur"))
			;;
		*)
			COMPREPLY=($(compgen -o plusdirs -f -- "$cur"))
			;;
	esac
}

###
# Process and merge local and global flags after removing the flags that
# have already been used.
#
# Usage:
#   __yarn_flags
#
# Globals:
#   flags
#   global_flags
#   words
##
__yarn_flags() {
	declare word
	declare -a existing_flags=()

	for word in "${words[@]}"; do
		case "$word" in
			-*)
				existing_flags+=("$word")
				;;
		esac
	done

	LC_ALL=C comm -23 \
		<(echo "${flags[@]}" "${global_flags[@]}" | tr ' ' '\n' | LC_ALL=C sort -u) \
		<(echo "${existing_flags[@]}" | tr ' ' '\n' | LC_ALL=C sort -u)
}

###
# Handles completions for flags that require, or optionally take, arguments.
#
# Usage:
#   __yarn_flag_args
#
# Globals:
#   cur
#   prev
##
__yarn_flag_args() {
	declare {arg,bool,dir,file,int,special}_flag_pattern
	arg_flag_pattern="@($(tr ' ' '|' <<< "${arg_flags[*]}"))"

	# shellcheck disable=SC2053
	if [[ $prev != $arg_flag_pattern ]]; then
		return 1
	fi

	bool_flag_pattern="@($(tr ' ' '|' <<< "${bool_arg_flags[*]}"))"
	dir_flag_pattern="@($(tr ' ' '|' <<< "${dir_arg_flags[*]}"))"
	file_flag_pattern="@($(tr ' ' '|' <<< "${file_arg_flags[*]}"))"
	int_flag_pattern="@($(tr ' ' '|' <<< "${int_arg_flags[*]}"))"
	special_flag_pattern="@($(tr ' ' '|' <<< "${special_arg_flags[*]}"))"

	case "$prev" in
		$bool_flag_pattern)
			COMPREPLY=($(compgen -W 'true false' -- "$cur"))
			;;
		$dir_flag_pattern)
			compopt -o dirnames
			;;
		$file_flag_pattern)
			compopt -o default -o filenames
			;;
		$int_flag_pattern)
			compopt -o nospace
			COMPREPLY=($(compgen -W '{0..9}' -- "$cur"))
			;;
		$special_flag_pattern)
			case "$prev" in
				--access)
					COMPREPLY=($(compgen -W 'public restricted' -- "$cur"))
					;;
				--groups)
					COMPREPLY=($(compgen -W 'dependencies devDependencies optionalDependencies' -- "$cur"))
					;;
				--level)
					COMPREPLY=($(compgen -W 'info low moderate high critical' -- "$cur"))
					;;
				--network-timeout)
					compopt -o nospace
					COMPREPLY=($(compgen -W '{1000..10000..1000}' -- "$cur"))
					;;
			esac
			;;
	esac
	return 0
}

_yarn_add() {
	((depth++))
	flags=(
		--audit -A
		--dev -D
		--exact -E
		--optional -O
		--peer -P
		--tilde -T
		--ignore-workspace-root-check -W
	)
	return 1
}

_yarn_audit() {
	((depth++))
	flags=(
		--groups
		--level
		--summary
	)
	return 1
}

_yarn_autoclean() {
	((depth++))
	flags=(
		--force -F
		--init -I
	)
	return 1
}

_yarn_cache() {
	((depth++))
	declare cmd
	flags=(
		--pattern
	)
	subcommands=(
		clean
		dir
		list
	)
	__yarn_get_command

	case "$cmd" in
		cache)
			case "$cur" in
				-*)
					return 1
					;;
				*)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
		*)
			return 1
			;;
	esac
}

_yarn_check() {
	((depth++))
	flags=(
		--integrity
		--verify-tree
	)
	return 1
}

_yarn_config() {
	((depth++))
	declare cmd
	declare subcommands=(
		delete
		get
		list
		set
	)
	declare known_keys=(
		ignore-optional
		ignore-platform
		ignore-scripts
		init-author-email
		init-author-name
		init-author-url
		init-license
		init-version
		no-progress
		prefix
		registry
		save-prefix
		user-agent
		version-git-message
		version-git-sign
		version-git-tag
		version-tag-prefix
	)
	__yarn_get_command

	case "$cmd" in
		get | delete)
			case "$cur" in
				-*) ;;
				*)
					if [[ $prev == @(get|delete) ]]; then
						COMPREPLY=($(compgen -W "${known_keys[*]}" -- "$cur"))
						return 0
					fi
					;;
			esac
			;;
		set)
			case "$cur" in
				-*)
					flags=(
						--global
					)
					;;
				*)
					if [[ $prev == set ]]; then
						COMPREPLY=($(compgen -W "${known_keys[*]}" -- "$cur"))
						return 0
					fi
					;;
			esac
			;;
		config)
			case "$cur" in
				-*) ;;
				*)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_create() {
	((depth++))
	declare -i args
	case "$cur" in
		-*) ;;
		*)
			__yarn_count_args -d $depth
			((args == 0)) && return 0
			;;
	esac
	return 1
}

_yarn_generate_lock_entry() {
	((depth++))
	flags=(
		--resolved
		--use-manifest
	)
	return 1
}

_yarn_global() {
	((depth++))
	declare cmd cmdlist
	flags=(
		--latest
		--prefix
	)
	subcommands=(
		add
		bin
		list
		remove
		upgrade
		upgrade-interactive
	)
	cmdlist="@($(tr ' ' '|' <<< "${subcommands[*]}"))"

	__yarn_get_command -d 3

	case "$cur" in
		-*) ;;
		*)
			case "$cmd" in
				$cmdlist)
					"_yarn_${cmd//-/_}" 2> /dev/null
					return $?
					;;
				global)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac

	return 1
}

_yarn_help() {
	((depth++))
	declare -i args
	case "$cur" in
		-*) ;;
		*)
			__yarn_count_args -d $depth
			if ((args == 0)); then
				COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
				return 0
			fi
			;;
	esac
	return 1
}

_yarn_info() {
	((depth++))
	flags=(
		--json
	)
	declare standard_fields=(
		author
		bin
		bugs
		contributors
		dependencies
		description
		devDependencies
		dist-tags
		engines
		files
		homepage
		keywords
		license
		main
		maintainers
		name
		optionalDependencies
		peerDependencies
		repository
		version
		versions
	)

	declare -i args
	__yarn_count_args -d $depth

	case "$cur" in
		-*) ;;
		*)
			case "$args" in
				0)
					COMPREPLY=(
						$(compgen -W "
							$(__yarn_get_package_fields dependencies)
							$(__yarn_get_package_fields devDependencies)
							" -- "$cur")
					)
					return 0
					;;
				1)
					COMPREPLY=($(compgen -W "${standard_fields[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_init() {
	((depth++))
	flags=(
		--yes -y
		--private -p
		--install -i
	)
	return 1
}

_yarn_install() {
	((depth++))
	flags=(
		--audit -A
	)
	return 1
}

_yarn_licenses() {
	((depth++))
	declare cmd
	subcommands=(
		list
		generate-disclaimer
	)
	case "$cur" in
		-*) ;;
		*)
			__yarn_get_command
			case "$cmd" in
				licenses)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_list() {
	((depth++))
	flags=(
		--depth
		--pattern
	)
	return 1
}

_yarn_node() {
	((depth++))
	flags=(
		--into
	)
	return 1
}

_yarn_outdated() {
	((depth++))
	case "$cur" in
		-*) ;;
		*)
			COMPREPLY=(
				$(compgen -W "
					$(__yarn_get_package_fields dependencies)
					$(__yarn_get_package_fields devDependencies)
					" -- "$cur")
			)
			return 0
			;;
	esac
	return 1
}

_yarn_owner() {
	((depth++))
	declare cmd
	subcommands=(
		add
		list
		remove
	)
	__yarn_get_command
	if [[ $cmd == owner ]]; then
		case "$cur" in
			-*) ;;
			*)
				COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
				return 0
				;;
		esac
	fi
	return 1
}

_yarn_pack() {
	((depth++))
	flags=(
		--filename -f
	)
	return 1
}

_yarn_policies() {
	((depth++))
	declare standard_policies=(
		latest
		nightly
		rc
	)

	declare -i args
	__yarn_count_args -d $depth

	case "$cur" in
		-*) ;;
		*)
			case "$args" in
				0)
					COMPREPLY=($(compgen -W "${standard_policies[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_publish() {
	((depth++))
	flags=(
		--access
		--major
		--message
		--minor
		--new-version
		--no-commit-hooks
		--no-git-tag-version
		--patch
		--preid
		--premajor
		--preminor
		--prepatch
		--prerelease
		--tag
	)
	return 1
}

_yarn_remove() {
	((depth++))
	declare cmd dependencies devDependencies
	flags=(
		--ignore-workspace-root-check -W
	)
	__yarn_get_command -d 1
	case "$cmd" in
		global)
			dependencies=$(__yarn_get_package_fields -g dependencies)
			devDependencies=''
			;;
		remove)
			dependencies=$(__yarn_get_package_fields dependencies)
			devDependencies=$(__yarn_get_package_fields devDependencies)
			;;
		*)
			return 1
			;;
	esac
	case "$cur" in
		-*) ;;
		*)
			COMPREPLY=($(compgen -W "$dependencies $devDependencies" -- "$cur"))
			return 0
			;;
	esac
	return 1
}

_yarn_run() {
	((depth++))
	declare cmd
	subcommands=(
		env
		$(__yarn_get_package_fields scripts)
	)
	__yarn_get_command
	if [[ $cmd == run ]]; then
		case "$cur" in
			-*) ;;
			*)
				COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
				return 0
				;;
		esac
	fi
	return 1
}

_yarn_tag() {
	((depth++))
	declare cmd
	subcommands=(
		add
		list
		remove
	)
	__yarn_get_command
	case "$cmd" in
		tag)
			case "$cur" in
				-*) ;;
				*)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_team() {
	((depth++))
	declare cmd
	subcommands=(
		add
		create
		destroy
		list
		remove
	)
	__yarn_get_command
	case "$cmd" in
		team)
			case "$cur" in
				-*) ;;
				*)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
	esac
	return 1
}

_yarn_unplug() {
	((depth++))
	flags=(
		--clear
		--clear-all
	)
	case "$cur" in
		-*) ;;
		*)
			COMPREPLY=(
				$(compgen -W "
					$(__yarn_get_package_fields dependencies)
					$(__yarn_get_package_fields devDependencies)
					" -- "$cur")
			)
			return 0
			;;

	esac
	return 1
}

_yarn_upgrade() {
	((depth++))
	declare cmd dependencies devDependencies
	flags=(
		--audit -A
		--caret -C
		--exact -E
		--latest -L
		--pattern -P
		--scope -S
		--tilde -T
	)
	__yarn_get_command -d 1
	case "$cmd" in
		global)
			dependencies=$(__yarn_get_package_fields -g dependencies)
			devDependencies=''
			;;
		upgrade)
			dependencies=$(__yarn_get_package_fields dependencies)
			devDependencies=$(__yarn_get_package_fields devDependencies)
			;;
		*)
			return 1
			;;
	esac
	case "$cur" in
		-*) ;;
		*)
			COMPREPLY=($(compgen -W "$dependencies $devDependencies" -- "$cur"))
			return 0
			;;
	esac
	return 1
}

_yarn_upgrade_interactive() {
	((depth++))
	flags=(
		--caret -C
		--exact -E
		--latest
		--scope -S
		--tilde -T
	)
	return 1
}

_yarn_version() {
	((depth++))
	flags=(
		--major
		--message
		--minor
		--new-version
		--no-commit-hooks
		--no-git-tag-version
		--patch
		--preid
		--premajor
		--preminor
		--prepatch
		--prerelease
	)
	return 1
}

_yarn_workspace() {
	((depth++))
	declare -i args
	declare workspaces_info

	case "$cur" in
		-*) ;;
		*)
			__yarn_count_args
			case "$args" in
				[0-2])
					workspaces_info=$(yarn workspaces info -s 2> /dev/null)
					if [[ -n $workspaces_info ]]; then
						mapfile -t < <(
							sed -n 's/^ \{2\}"\([^"]*\)": {$/\1/p' <<< "$workspaces_info"
						)
						COMPREPLY=($(compgen -W "${MAPFILE[*]}" -- "$cur"))
					fi
					return 0
					;;
				3)
					COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
					return 0
					;;
				*)
					declare cmd
					workspaces_info=$(yarn workspaces info -s 2> /dev/null)

					if [[ -n $workspaces_info ]]; then
						PWD=$(
							sed -n '/^ \{2\}"'"${COMP_WORDS[2]}"'": {$/,/^ \{2\}},\{0,1\}$/{
								s/^ \{4\}"location": "\([^"]*\)",$/\1/p
							}' <<< "$workspaces_info"
						)
					fi

					__yarn_get_command -d 3
					"_yarn_${cmd//-/_}" 2> /dev/null
					return $?
					;;
			esac
			;;
	esac
	return 1
}

_yarn_workspaces() {
	((depth++))
	declare cmd
	subcommands=(
		info
		run
	)
	__yarn_get_command -d 4
	case "$cmd" in
		workspaces)
			case "$cur" in
				-*) ;;
				*)
					COMPREPLY=($(compgen -W "${subcommands[*]}" -- "$cur"))
					return 0
					;;
			esac
			;;
		info)
			return 0
			;;
		run)
			__yarn_run
			return 0
			;;
	esac
	return 1
}

_yarn_why() {
	((depth++))
	case "$cur" in
		-*) ;;
		./*)
			compopt -o filenames
			;;
		*)
			declare modules
			modules=$(yarn list --depth 0 | sed -n 's/.* \([a-zA-Z0-9@].*\)@.*/\1/p') || return 1
			COMPREPLY=($(compgen -W "$modules" -- "$cur"))
			return 0
			;;
	esac
	return 1
}

_yarn_yarn() {
	((depth++))
	case "$cur" in
		-*) ;;
		*)
			COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
			return 0
			;;
	esac
	return 1
}

_yarn() {
	# shellcheck disable=SC2064
	trap "
		PWD=$PWD
		$(shopt -p extglob)
		set +o pipefail
	" RETURN

	shopt -s extglob
	set -o pipefail

	declare cur cmd prev
	declare -a words
	declare -i cword counter=1 depth=1
	declare -ar commands=(
		access
		add
		audit
		autoclean
		bin
		cache
		check
		config
		create
		exec
		generate-lock-entry
		global
		help
		import
		info
		init
		install
		licenses
		link
		list
		login
		logout
		node
		outdated
		owner
		pack
		policies
		publish
		remove
		run
		tag
		team
		unlink
		unplug
		upgrade
		upgrade-interactive
		version
		versions
		why
		workspace
		workspaces
		$(__yarn_get_package_fields scripts)
	)
	declare -a subcommands=()

	declare -ar bool_arg_flags=(
		--emoji
		--production --prod
		--scripts-prepend-node-path
	)
	declare -ar dir_arg_flags=(
		--cache-folder
		--cwd
		--global-folder
		--into
		--link-folder
		--modules-folder
		--preferred-cache-folder
		--prefix
	)
	declare -ar file_arg_flags=(
		--filename -f
		--use-manifest
		--use-yarnrc
	)
	declare -ar int_arg_flags=(
		--depth
		--network-concurrency
	)
	declare -ar special_arg_flags=(
		--access
		--groups
		--level
		--network-timeout
	)
	declare -ar optional_arg_flags=(
		--emoji
		--prod
		--production
		--scripts-prepend-node-path
	)
	declare -ar skipped_arg_flags=(
		--https-proxy
		--message
		--mutex
		--new-version
		--otp
		--pattern -P
		--proxy
		--registry
		--resolved
		--scope -S
		--tag
	)
	declare -ar arg_flags=(
		"${bool_arg_flags[@]}"
		"${dir_arg_flags[@]}"
		"${file_arg_flags[@]}"
		"${int_arg_flags[@]}"
		"${special_arg_flags[@]}"
		"${optional_arg_flags[@]}"
		"${skipped_arg_flags[@]}"
	)

	declare -ar global_flags=(
		--cache-folder
		--check-files
		--cwd
		--disable-pnp
		--emoji
		--enable-pnp --pnp
		--flat
		--focus
		--force
		--frozen-lockfile
		--global-folder
		--har
		--help -h
		--https-proxy
		--ignore-engines
		--ignore-optional
		--ignore-platform
		--ignore-scripts
		--json
		--link-duplicates
		--link-folder
		--modules-folder
		--mutex
		--network-concurrency
		--network-timeout
		--no-bin-links
		--no-default-rc
		--no-lockfile
		--non-interactive
		--no-node-version-check
		--no-progress
		--offline
		--otp
		--prefer-offline
		--preferred-cache-folder
		--prod
		--production
		--proxy
		--pure-lockfile
		--registry
		--scripts-prepend-node-path
		--silent -s
		--skip-integrity-check
		--strict-semver
		--update-checksums
		--use-yarnrc
		--verbose
		--version -v
	)
	declare -a flags=()

	COMPREPLY=()
	if command -v _get_comp_words_by_ref > /dev/null; then
		_get_comp_words_by_ref -n = -n @ -n : cur prev words cword
	elif command -v _init_completion > /dev/null; then
		_init_completion
	fi

	__yarn_get_command -d 1

	__yarn_flag_args || "_yarn_${cmd//-/_}" 2> /dev/null || __yarn_fallback

	if command -v __ltrim_colon_completions > /dev/null; then
		__ltrim_colon_completions "$cur"
	fi
}

if [[ ${BASH_VERSINFO[0]} -ge 4 && ${BASH_VERSINFO[1]} -ge 4 ]]; then
	complete -o nosort -F _yarn yarn
else
	complete -F _yarn yarn
fi
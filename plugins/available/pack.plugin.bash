# shellcheck shell=bash
# bash completion for pack                                 -*- shell-script -*-

cite about-plugin
about-plugin 'CNB pack cli aliases'

__pack_debug() {
	if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
		echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
	fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__pack_init_completion() {
	COMPREPLY=()
	_get_comp_words_by_ref "$@" cur prev words cword
}

__pack_index_of_word() {
	local w word=$1
	shift
	index=0
	for w in "$@"; do
		[[ $w = "$word" ]] && return
		index=$((index + 1))
	done
	index=-1
}

__pack_contains_word() {
	local w word=$1
	shift
	for w in "$@"; do
		[[ $w = "$word" ]] && return
	done
	return 1
}

__pack_handle_reply() {
	__pack_debug "${FUNCNAME[0]}"
	case $cur in
		-*)
			if [[ $(type -t compopt) = "builtin" ]]; then
				compopt -o nospace
			fi
			local allflags line
			if [ ${#must_have_one_flag[@]} -ne 0 ]; then
				allflags=("${must_have_one_flag[@]}")
			else
				allflags=("${flags[*]} ${two_word_flags[*]}")
			fi
			COMPREPLY=()
			while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "${allflags[*]}" -- "$cur")
			if [[ $(type -t compopt) = "builtin" ]]; then
				[[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
			fi

			# complete after --flag=abc
			if [[ $cur == *=* ]]; then
				if [[ $(type -t compopt) = "builtin" ]]; then
					compopt +o nospace
				fi

				local index flag
				flag="${cur%=*}"
				__pack_index_of_word "${flag}" "${flags_with_completion[@]}"
				COMPREPLY=()
				if [[ ${index} -ge 0 ]]; then
					# PREFIX=""
					cur="${cur#*=}"
					${flags_completion[${index}]}
					if [ -n "${ZSH_VERSION}" ]; then
						# zsh completion needs --flag= prefix
						eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
					fi
				fi
			fi
			return 0
			;;
	esac

	# check if we are handling a flag with special work handling
	local index completions line
	__pack_index_of_word "${prev}" "${flags_with_completion[@]}"
	if [[ ${index} -ge 0 ]]; then
		${flags_completion[${index}]}
		return
	fi

	# we are parsing a flag and don't have a special handler, no completion
	if [[ ${cur} != "${words[cword]}" ]]; then
		return
	fi

	completions=("${commands[@]}")
	if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
		completions=("${must_have_one_noun[@]}")
	fi
	if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
		completions+=("${must_have_one_flag[@]}")
	fi
	COMPREPLY=()
	while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "${completions[*]}" -- "$cur")

	if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
		COMPREPLY=()
		while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
	fi

	if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		declare -F __custom_func > /dev/null && __custom_func
	fi

	# available in bash-completion >= 2, not always present on macOS
	if declare -F __ltrim_colon_completions > /dev/null; then
		__ltrim_colon_completions "$cur"
	fi

	# If there is only 1 completion and it is a flag with an = it will be completed
	# but we don't want a space after the =
	if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
		compopt -o nospace
	fi
}

# The arguments should be in the form "ext1|ext2|extn"
__pack_handle_filename_extension_flag() {
	local ext="$1"
	_filedir "@(${ext})"
}

__pack_handle_subdirs_in_dir_flag() {
	local dir="$1"
	pushd "${dir}" > /dev/null 2>&1 && _filedir -d && popd > /dev/null 2>&1 || return 1
}

__pack_handle_flag() {
	__pack_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

	# if a command required a flag, and we found it, unset must_have_one_flag()
	local flagname=${words[c]}
	local flagvalue
	# if the word contained an =
	if [[ ${words[c]} == *"="* ]]; then
		flagvalue=${flagname#*=} # take in as flagvalue after the =
		flagname=${flagname%=*}  # strip everything after the =
		flagname="${flagname}="  # but put the = back
	fi
	__pack_debug "${FUNCNAME[0]}: looking for ${flagname}"
	if __pack_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
		must_have_one_flag=()
	fi

	# if you set a flag which only applies to this command, don't show subcommands
	if __pack_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
		commands=()
	fi

	# keep flag value with flagname as flaghash
	# flaghash variable is an associative array which is only supported in bash > 3.
	if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
		if [ -n "${flagvalue}" ]; then
			flaghash[${flagname}]=${flagvalue}
		elif [ -n "${words[$((c + 1))]}" ]; then
			flaghash[${flagname}]=${words[$((c + 1))]}
		else
			flaghash[${flagname}]="true" # pad "true" for bool flag
		fi
	fi

	# skip the argument to a two word flag
	if __pack_contains_word "${words[c]}" "${two_word_flags[@]}"; then
		c=$((c + 1))
		# if we are looking for a flags value, don't show commands
		if [[ $c -eq $cword ]]; then
			commands=()
		fi
	fi

	c=$((c + 1))

}

__pack_handle_noun() {
	__pack_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

	if __pack_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
		must_have_one_noun=()
	elif __pack_contains_word "${words[c]}" "${noun_aliases[@]}"; then
		must_have_one_noun=()
	fi

	nouns+=("${words[c]}")
	c=$((c + 1))
}

__pack_handle_command() {
	__pack_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

	local next_command
	if [[ -n ${last_command} ]]; then
		next_command="_${last_command}_${words[c]//:/__}"
	else
		if [[ $c -eq 0 ]]; then
			next_command="_pack_root_command"
		else
			next_command="_${words[c]//:/__}"
		fi
	fi
	c=$((c + 1))
	__pack_debug "${FUNCNAME[0]}: looking for ${next_command}"
	declare -F "$next_command" > /dev/null && $next_command
}

__pack_handle_word() {
	if [[ $c -ge $cword ]]; then
		__pack_handle_reply
		return
	fi
	__pack_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
	if [[ "${words[c]}" == -* ]]; then
		__pack_handle_flag
	elif __pack_contains_word "${words[c]}" "${commands[@]}"; then
		__pack_handle_command
	elif [[ $c -eq 0 ]]; then
		__pack_handle_command
	elif __pack_contains_word "${words[c]}" "${command_aliases[@]}"; then
		# aliashash variable is an associative array which is only supported in bash > 3.
		if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
			words[c]=${aliashash[${words[c]}]}
			__pack_handle_command
		else
			__pack_handle_noun
		fi
	else
		__pack_handle_noun
	fi
	__pack_handle_word
}

_pack_build() {
	last_command="pack_build"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--builder=")
	local_nonpersistent_flags+=("--builder=")
	flags+=("--buildpack=")
	local_nonpersistent_flags+=("--buildpack=")
	flags+=("--clear-cache")
	local_nonpersistent_flags+=("--clear-cache")
	flags+=("--env=")
	two_word_flags+=("-e")
	local_nonpersistent_flags+=("--env=")
	flags+=("--env-file=")
	local_nonpersistent_flags+=("--env-file=")
	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-pull")
	local_nonpersistent_flags+=("--no-pull")
	flags+=("--path=")
	two_word_flags+=("-p")
	local_nonpersistent_flags+=("--path=")
	flags+=("--publish")
	local_nonpersistent_flags+=("--publish")
	flags+=("--run-image=")
	local_nonpersistent_flags+=("--run-image=")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_run() {
	last_command="pack_run"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--builder=")
	local_nonpersistent_flags+=("--builder=")
	flags+=("--buildpack=")
	local_nonpersistent_flags+=("--buildpack=")
	flags+=("--clear-cache")
	local_nonpersistent_flags+=("--clear-cache")
	flags+=("--env=")
	two_word_flags+=("-e")
	local_nonpersistent_flags+=("--env=")
	flags+=("--env-file=")
	local_nonpersistent_flags+=("--env-file=")
	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-pull")
	local_nonpersistent_flags+=("--no-pull")
	flags+=("--path=")
	two_word_flags+=("-p")
	local_nonpersistent_flags+=("--path=")
	flags+=("--port=")
	local_nonpersistent_flags+=("--port=")
	flags+=("--run-image=")
	local_nonpersistent_flags+=("--run-image=")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_rebase() {
	last_command="pack_rebase"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-pull")
	local_nonpersistent_flags+=("--no-pull")
	flags+=("--publish")
	local_nonpersistent_flags+=("--publish")
	flags+=("--run-image=")
	local_nonpersistent_flags+=("--run-image=")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_create-builder() {
	last_command="pack_create-builder"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--builder-config=")
	two_word_flags+=("-b")
	local_nonpersistent_flags+=("--builder-config=")
	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-pull")
	local_nonpersistent_flags+=("--no-pull")
	flags+=("--publish")
	local_nonpersistent_flags+=("--publish")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_flag+=("--builder-config=")
	must_have_one_flag+=("-b")
	must_have_one_noun=()
	noun_aliases=()
}

_pack_set-run-image-mirrors() {
	last_command="pack_set-run-image-mirrors"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--mirror=")
	two_word_flags+=("-m")
	local_nonpersistent_flags+=("--mirror=")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_flag+=("--mirror=")
	must_have_one_flag+=("-m")
	must_have_one_noun=()
	noun_aliases=()
}

_pack_inspect-builder() {
	last_command="pack_inspect-builder"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_set-default-builder() {
	last_command="pack_set-default-builder"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_version() {
	last_command="pack_version"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_completion() {
	last_command="pack_completion"

	command_aliases=()

	commands=()

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

_pack_root_command() {
	last_command="pack"

	command_aliases=()

	commands=()
	commands+=("build")
	commands+=("run")
	commands+=("rebase")
	commands+=("create-builder")
	commands+=("set-run-image-mirrors")
	commands+=("inspect-builder")
	commands+=("set-default-builder")
	commands+=("version")
	commands+=("completion")

	flags=()
	two_word_flags=()
	local_nonpersistent_flags=()
	flags_with_completion=()
	flags_completion=()

	flags+=("--help")
	flags+=("-h")
	local_nonpersistent_flags+=("--help")
	flags+=("--no-color")
	flags+=("--quiet")
	flags+=("-q")
	flags+=("--timestamps")

	must_have_one_flag=()
	must_have_one_noun=()
	noun_aliases=()
}

__start_pack() {
	local cur prev words cword
	#shellcheck disable=SC2034
	declare -A flaghash 2> /dev/null || :
	declare -A aliashash 2> /dev/null || :
	if declare -F _init_completion > /dev/null 2>&1; then
		_init_completion -s || return
	else
		__pack_init_completion -n "=" || return
	fi

	local c=0
	local flags=()
	local two_word_flags=()
	local local_nonpersistent_flags=()
	local flags_with_completion=()
	local flags_completion=()
	local commands=("pack")
	local must_have_one_flag=()
	local must_have_one_noun=()
	local last_command
	local nouns=()

	__pack_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
	complete -o default -F __start_pack pack
else
	complete -o default -o nospace -F __start_pack pack
fi

# ex: ts=4 sw=4 et filetype=sh

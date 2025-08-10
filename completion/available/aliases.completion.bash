# shellcheck shell=bash
about-plugin 'Automatic completion of aliases'
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# References:
# http://superuser.com/a/437508/119764
# http://stackoverflow.com/a/1793178/1228454

# Automatically add completion for all aliases to commands having completion functions
function _bash-it-component-completion-callback-on-init-aliases() {
	local aliasCommandFunction namespace="alias_completion"
	local tmp_file completion_loader alias_name line completions chars
	local alias_arg_words new_completion compl_func compl_wrapper alias_defn

	# create array of function completion triggers, keeping multi-word triggers together
	IFS=$'\n' read -d '' -ra completions < <(complete -p)
	((${#completions[@]} == 0)) && return 0

	completions=("${completions[@]##complete -* * -}") # strip all but last option plus trigger(s)
	completions=("${completions[@]#complete -}")       # strip anything missed
	completions=("${completions[@]#? * }")             # strip last option and arg, leaving only trigger(s)
	completions=("${completions[@]#? }")               # strip anything missed
	#TODO: this will fail on some completions...

	# create temporary file for wrapper functions and completions
	tmp_file="$(mktemp -t "${namespace}-${RANDOM}XXXXXX")" || return 1

	IFS=$'\n' read -r completion_loader < <(complete -p -D 2> /dev/null)
	if [[ "${completion_loader#complete }" =~ '-F'[[:space:]]([[:alnum:]_]+)[[:space:]] ]]; then
		completion_loader="${BASH_REMATCH[1]}"
	else
		completion_loader=""
	fi

	# read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
	# some aliases do have backslashes that needs to be interpreted
	# shellcheck disable=SC2162
	while read line; do
		line="${line#alias -- }"
		line="${line#alias }"
		alias_name="${line%%=*}"

		# Skip aliases not added by this script that already have completion functions.
		# This allows users to define their own alias completion functions.
		# For aliases added by this script, we do want to replace them in case the
		# alias getting the completion added has changed.
		if complete -p "$alias_name" &> /dev/null; then
			# Get the -F argument from the existing completion for this alias.
			aliasCommandFunction=$(complete -p "$alias_name" | rev | cut -d " " -f 2 | rev)
			# Check if aliasCommandFunction starts with our namespace.
			if [[ "$aliasCommandFunction" != "_${namespace}::"* ]]; then
				continue
			fi

			# Remove existing completion. It will be replaced by the new one. We need to
			# delete it in case the new alias does not support having completion added.
			complete -r "$alias_name"
		fi

		alias_defn="${line#*=\'}" # alias definition
		alias_defn="${alias_defn%\'}"
		alias_cmd="${alias_defn%%[[:space:]]*}" # first word of alias
		if [[ ${alias_defn} == "${alias_cmd}" ]]; then
			alias_args=''
		else
			alias_args="${alias_defn#*[[:space:]]}" # everything after first word
		fi

		# skip aliases to pipes, boolean control structures and other command lists
		chars=$'|&;()<>\n'
		if [[ "${alias_defn}" =~ [$chars] ]]; then
			continue
		fi
		# avoid expanding wildcards
		read -ra alias_arg_words <<< "$alias_args"

		# skip alias if there is no completion function triggered by the aliased command
		if ! _bash-it-array-contains-element "$alias_cmd" "${completions[@]}"; then
			if [[ -n "$completion_loader" ]]; then
				# force loading of completions for the aliased command
				"${completion_loader:?}" "${alias_cmd}"
				# 124 means completion loader was successful
				[[ $? -eq 124 ]] || continue
				completions+=("$alias_cmd")
			else
				continue
			fi
		fi
		new_completion="$(complete -p "$alias_cmd" 2> /dev/null)"

		compl_func="${new_completion/#* -F /}"
		compl_func="${compl_func%% *}"
		# avoid recursive call loops by ignoring our own functions
		if [[ "${compl_func#_"$namespace"::}" == "$compl_func" ]]; then
			compl_wrapper="_${namespace}::${alias_name}"

			if [[ -z $alias_args ]]; then
				# Create a wrapper without arguments.
				# This allows identifying the completions added by this script on reload.
				echo "function $compl_wrapper {
				$compl_func \"\$@\"
				}" >> "$tmp_file"
			else
				# Create a wrapper inserting the alias arguments
				# The use of printf on alias_arg_words is needed to ensure each element of
				# the array is quoted. E.X. (one two three) -> ('one' 'two' 'three')
				echo "function $compl_wrapper {
                        local compl_word=\${2?}
                        local prec_word=\${3?}
                        # check if prec_word is the alias itself. if so, replace it
                        # with the last word in the unaliased form, i.e.,
                        # alias_cmd + ' ' + alias_args.
                        if [[ \$COMP_LINE == \"\$prec_word \$compl_word\" ]]; then
                            prec_word='$alias_cmd $alias_args'
                            prec_word=\${prec_word#* }
                        fi
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=(\"$alias_cmd\" $(printf "%q " "${alias_arg_words[@]}") \"\${COMP_WORDS[@]:1}\")
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        \"$compl_func\" \"$alias_cmd\" \"\$compl_word\" \"\$prec_word\"
                    }" >> "$tmp_file"
			fi
			new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
		fi

		# replace completion trigger by alias
		if [[ -n $new_completion ]]; then
			new_completion="${new_completion% *} $alias_name"
			echo "$new_completion" >> "$tmp_file"
		fi
	done < <(alias -p)
	# shellcheck source=/dev/null
	source "$tmp_file" && command rm -f "$tmp_file"
}

_bash-it-component-completion-callback-on-init-aliases

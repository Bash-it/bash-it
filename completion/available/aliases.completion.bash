# shellcheck shell=bash
about-plugin 'Automatic completion of aliases'
# Load after all aliases and completions to understand what needs to be completed
# BASH_IT_LOAD_PRIORITY: 800

# References:
# http://superuser.com/a/437508/119764
# http://stackoverflow.com/a/1793178/1228454

# Automatically add completion for all aliases to commands having completion functions
function _bash-it-component-completion-callback-on-init-aliases() {
	local namespace="alias_completion"
	local tmp_file completion_loader alias_name line completions
	local alias_arg_words new_completion compl_func compl_wrapper alias_defn

	# create array of function completion triggers, keeping multi-word triggers together
	IFS=$'\n' read -d '' -ra completions < <(complete -p)
	((${#completions[@]} == 0)) && return 0

	completions=("${completions[@]##complete -* * -}") # strip all but last option plus trigger(s)
	completions=("${completions[@]#complete -}")       # strip anything missed
	completions=("${completions[@]#? * }")             # strip last option and arg, leaving only trigger(s)

	# create temporary file for wrapper functions and completions
	tmp_file="$(mktemp -t "${namespace}-${RANDOM}XXXXXX")" || return 1

	completion_loader="$(complete -p -D 2> /dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

	# read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
	# some aliases do have backslashes that needs to be interpreted
	# shellcheck disable=SC2162
	while read line; do
		line="${line#alias }"
		alias_name="${line%%=*}"
		alias_defn="${line#*=}"                 # alias definition
		alias_cmd="${alias_defn%%[[:space:]]*}" # first word of alias
		alias_cmd="${alias_cmd:1}"              # lose opening quotation mark
		alias_args="${alias_defn#*[[:space:]]}" # everything after first word
		alias_args="${alias_args%\'}"           # lose ending quotation mark

		# skip aliases to pipes, boolean control structures and other command lists
		[[ "${alias_args}" =~ [\|\&\;\)\(\n] ]] && continue
		# avoid expanding wildcards
		read -a alias_arg_words <<< "$alias_args"

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

		# create a wrapper inserting the alias arguments if any
		if [[ -n $alias_args ]]; then
			compl_func="${new_completion/#* -F /}"
			compl_func="${compl_func%% *}"
			# avoid recursive call loops by ignoring our own functions
			if [[ "${compl_func#_"$namespace"::}" == "$compl_func" ]]; then
				compl_wrapper="_${namespace}::${alias_name}"
				echo "function $compl_wrapper {
                        local compl_word=\$2
                        local prec_word=\$3
                        # check if prec_word is the alias itself. if so, replace it
                        # with the last word in the unaliased form, i.e.,
                        # alias_cmd + ' ' + alias_args.
                        if [[ \$COMP_LINE == \"\$prec_word \$compl_word\" ]]; then
                            prec_word='$alias_cmd $alias_args'
                            prec_word=\${prec_word#* }
                        fi
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func \"$alias_cmd\" \"\$compl_word\" \"\$prec_word\"
                    }" >> "$tmp_file"
				new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
			fi
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

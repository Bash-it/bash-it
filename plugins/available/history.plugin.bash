# shellcheck shell=bash
cite about-plugin
about-plugin 'improve history handling with sane defaults'

# append to bash_history if Terminal.app quits
shopt -s histappend

# erase duplicates; alternative option: export HISTCONTROL=ignoredups
export HISTCONTROL=${HISTCONTROL:-ignorespace:erasedups}

# resize history to 100x the default (500)
export HISTSIZE=${HISTSIZE:-50000}

top-history() {
	about 'print the name and count of the most commonly run tools'

	if [[ -n $HISTTIMEFORMAT ]]; then
		# To parse history we need a predictable format, which HISTTIMEFORMAT
		# gets in the way of. So we unset it and set a trap to guarantee the
		# user's environment returns to normal even if the pipeline below fails.
		# shellcheck disable=SC2064
		trap "export HISTTIMEFORMAT='$HISTTIMEFORMAT'" RETURN
		unset HISTTIMEFORMAT
	fi

	history \
		| awk '{
				a[$2]++
			}END{
				for(i in a)
				printf("%s\t%s\n", a[i], i)
			}' \
		| sort --reverse --numeric-sort \
		| head \
		| column \
			--table \
			--table-columns 'Command Count,Command Name' \
			--output-separator ' | '
}

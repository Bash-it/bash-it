# shellcheck shell=bash
about-plugin 'improve history handling with sane defaults'

# Append the history list to the file named by the value of the HISTFILE
# variable when the shell exits, rather than overwriting the file.
shopt -s histappend

# erase duplicates; alternative option: export HISTCONTROL=ignoredups
export HISTCONTROL=${HISTCONTROL:-ignorespace:erasedups}

# resize history to 100x the default (500)
export HISTSIZE=${HISTSIZE:-50000}

# Flush history to disk after each command.
export PROMPT_COMMAND="history -a;${PROMPT_COMMAND}"

function top-history() {
	about 'print the name and count of the most commonly run tools'

	# - Make sure formatting doesn't interfer with our parsing
	# - Use awk to count how many times the first command on each line has been called
	# - Truncate to 10 lines
	# - Print in column format
	HISTTIMEFORMAT='' history \
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

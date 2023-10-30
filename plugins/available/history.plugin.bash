# shellcheck shell=bash
about-plugin 'improve history handling with sane defaults'

# Append the history list to the file named by the value of the HISTFILE
# variable when the shell exits, rather than overwriting the file.
shopt -s histappend

# 'ignorespace': don't save command lines which begin with a space to history
# 'erasedups' (alternative 'ignoredups'): don't save duplicates to history
# 'autoshare': automatically share history between multiple running shells
: "${HISTCONTROL:=ignorespace:erasedups:autoshare}"

# resize history to 100x the default (500)
: "${HISTSIZE:=50000}"

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

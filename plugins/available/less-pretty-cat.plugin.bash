# shellcheck shell=bash
cite about-plugin
about-plugin 'pygmentize instead of cat to terminal if possible'

_command_exists pygmentize || return

# pigmentize cat and less outputs - call them ccat and cless to avoid that
# especially cat'ed output in scripts gets mangled with pygemtized meta characters
function ccat() {
	about 'runs either pygmentize or cat on each file passed in'
	param '*: files to concatenate (as normally passed to cat)'
	example 'ccat mysite/manage.py dir/text-file.txt'

	local file
	: "${BASH_IT_CCAT_STYLE:=default}"

	for file in "$@"; do
		pygmentize -f 256 -O style="$BASH_IT_CCAT_STYLE" -g "$file" 2> /dev/null || command cat "$file"
	done
}

function cless() {
	about 'pigments the file passed in and passes it to less for pagination'
	param '1: the file to paginate with less'
	example 'cless mysite/manage.py'

	: "${BASH_IT_CLESS_STYLE:=default}"

	pygmentize -f 256 -O style="$BASH_IT_CLESS_STYLE" -g "$@" | command less -R
}

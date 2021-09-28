# shellcheck shell=bash
cite about-plugin
about-plugin 'pygmentize instead of cat to terminal if possible'

_command_exists pygmentize || return

# pigmentize cat and less outputs - call them ccat and cless to avoid that
# especially cat'ed output in scripts gets mangled with pygemtized meta characters
function ccat() {
	about 'runs pygmentize on each file passed in'
	param '*: files to concatenate (as normally passed to cat)'
	example 'ccat mysite/manage.py dir/text-file.txt'

	pygmentize -f 256 -O style="${BASH_IT_CCAT_STYLE:-default}" -g "$@"
}

function cless() {
	about 'pigments the files passed in and passes to less for pagination'
	param '*: the files to paginate with less'
	example 'cless mysite/manage.py'

	pygmentize -f 256 -O style="${BASH_IT_CLESS_STYLE:-default}" -g "$@" | command less -R
}

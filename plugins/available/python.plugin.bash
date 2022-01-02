# shellcheck shell=bash
about-plugin 'alias "shttp" to SimpleHTTPServer'

if _command_exists python2; then
	alias shttp='python2 -m SimpleHTTPServer'
elif _command_exists python; then
	alias shttp='python -m SimpleHTTPServer'
else
	return 1
fi

function pyedit() {
	about 'opens python module in your EDITOR'
	param '1: python module to open'
	example '$ pyedit requests'
	group 'python'

	xpyc="$(python -c "import os, sys; f = open(os.devnull, 'w'); sys.stderr = f; module = __import__('$1'); sys.stdout.write(module.__file__)")"

	if [[ "$xpyc" == "" ]]; then
		echo "Python module $1 not found"
		return 1
	elif [[ "$xpyc" == *__init__.py* ]]; then
		xpydir="${xpyc%/*}"
		echo "$EDITOR $xpydir"
		${VISUAL:-${EDITOR:-${ALTERNATE_EDITOR:-nano}}} "$xpydir"
	else
		echo "$EDITOR ${xpyc%.*}.py"
		${VISUAL:-${EDITOR:-${ALTERNATE_EDITOR:-nano}}} "${xpyc%.*}.py"
	fi
}

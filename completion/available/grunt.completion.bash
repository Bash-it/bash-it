# shellcheck shell=bash

# grunt-cli
# http://gruntjs.com/
#
# Copyright jQuery Foundation and other contributors, https://jquery.org/

# This software consists of voluntary contributions made by many
# individuals. For exact contribution history, see the revision history
# available at https://github.com/gruntjs/grunt .

# The following license applies to all parts of this software except as
# documented below:

# ====

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Usage:
#
# To enable bash <tab> completion for grunt, add the following line (minus the
# leading #, which is the bash comment character) to your ~/.bashrc file:
#
# eval "$(grunt --completion=bash)"

# Search the current directory and all parent directories for a gruntfile.
function _grunt_gruntfile() {
	local curpath="$PWD"
	while [[ "$curpath" ]]; do
		for gruntfile in "$curpath/"{G,g}runtfile.{js,coffee}; do
			if [[ -e "$gruntfile" ]]; then
				echo "$gruntfile"
				return
			fi
		done
		curpath="${curpath%/*}"
	done
	return 1
}

# Enable bash autocompletion.
function _grunt_completions() {
	local cur gruntfile gruntinfo opts compls line
	# The currently-being-completed word.
	cur="${COMP_WORDS[COMP_CWORD]}"
	# The current gruntfile, if it exists.
	gruntfile="$(_grunt_gruntfile)"
	# The current grunt version, available tasks, options, etc.
	gruntinfo="$(grunt --version --verbose 2> /dev/null)"
	# Options and tasks.
	opts="$(echo "$gruntinfo" | awk '/Available options: / {$1=$2=""; print $0}')"
	compls="$(echo "$gruntinfo" | awk '/Available tasks: / {$1=$2=""; print $0}')"
	# Only add -- or - options if the user has started typing -
	[[ "$cur" == -* ]] && compls="$compls $opts"
	# Tell complete what stuff to show.

	while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$compls" -- "$cur")
}

complete -o default -F _grunt_completions grunt

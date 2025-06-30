# shellcheck shell=bash
# Borrowed from grunt-cli
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
# To enable bash <tab> completion for gulp, add the following line (minus the
# leading #, which is the bash comment character) to your ~/.bashrc file:
#
# eval "$(gulp --completion=bash)"
# Enable bash autocompletion.
function _gulp_completions() {
	# The currently-being-completed word.
	local cur="${COMP_WORDS[COMP_CWORD]}"
	#Grab tasks
	local line compls
	compls=$(gulp --tasks-simple)
	# Tell complete what stuff to show.
	while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$compls" -- "$cur")
}
complete -o default -F _gulp_completions gulp

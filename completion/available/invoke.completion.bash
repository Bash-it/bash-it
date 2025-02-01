# shellcheck shell=bash
# Invoke (pyinvoke.org) tab-completion script to be sourced with Bash shell.

# Copyright (c) 2020 Jeff Forcier.
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# https://github.com/pyinvoke/invoke/blob/master/completion/bash

_complete_invoke() {
	local candidates line

	# COMP_WORDS contains the entire command string up til now (including
	# program name).
	# We hand it to Invoke so it can figure out the current context: spit back
	# core options, task names, the current task's options, or some combo.
	candidates=$(invoke --complete -- "${COMP_WORDS[@]}")

	# `compgen -W` takes list of valid options & a partial word & spits back
	# possible matches. Necessary for any partial word completions (vs
	# completions performed when no partial words are present).
	#
	# $2 is the current word or token being tabbed on, either empty string or a
	# partial word, and thus wants to be compgen'd to arrive at some subset of
	# our candidate list which actually matches.
	#
	# COMPREPLY is the list of valid completions handed back to `complete`.
	while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "${candidates}" -- "$2")
}

# Tell shell builtin to use the above for completing 'inv'/'invoke':
# * -F: use given function name to generate completions.
# * -o default: when function generates no results, use filenames.
# * positional args: program names to complete for.
complete -F _complete_invoke -o default invoke inv

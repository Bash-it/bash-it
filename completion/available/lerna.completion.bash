# shellcheck shell=bash
cite "about-completion"
about-completion "lerna(javascript project manager tool) completion"

function __lerna_completion() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local cur compls

	# The currently-being-completed word.
	cur="${COMP_WORDS[COMP_CWORD]}"

	# Options
	compls="add bootstrap changed clean create diff exec \
	import init link list publish run version    \
	--loglevel --concurrency --reject-cycles    \
	--progress --sort --no-sort --help          \
	--version"

	# Tell complete what stuff to show.
	# shellcheck disable=2207
	COMPREPLY=($(compgen -W "$compls" -- "$cur"))
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}
complete -o default -F __lerna_completion lerna

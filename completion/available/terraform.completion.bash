# shellcheck shell=bash

if _command_exists terraform; then

	# Don't handle completion if it's already managed
	complete -p terraform &> /dev/null && return

	# Terraform completes itself
	complete -C terraform terraform

elif _command_exists tofu; then

	# Don't handle completion if it's already managed
	complete -p tofu &> /dev/null && return

	# OpenTofu completes itself
	complete -C tofu tofu

fi



## TODO: change the logic to the new way of doing things?
## Make sure terraform is installed
#_bash-it-completion-helper-necessary terraform || return

## Don't handle completion if it's already managed
#_bash-it-completion-helper-sufficient terraform || return
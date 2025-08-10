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

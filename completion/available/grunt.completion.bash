# shellcheck shell=bash

# Search the current directory and all parent directories for a gruntfile.
if _command_exists grunt; then
	eval "$(grunt --completion=bash)"
fi

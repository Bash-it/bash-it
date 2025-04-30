# shellcheck shell=bash

# nvm (Node Version Manager) completion

if [ "$NVM_DIR" ] && [ -r "$NVM_DIR"/bash_completion ]; then
	. "$NVM_DIR"/bash_completion
fi

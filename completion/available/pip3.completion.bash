# shellcheck shell=bash

# https://pip.pypa.io/en/stable/user_guide/#command-completion
# Of course, you should first install pip, say on Debian:
# sudo apt-get install python3-pip
# If the pip package is installed within virtual environments, say, python managed by pyenv,
# you should first initialize the corresponding environment.
# So that pip3 is in the system's path.
if _command_exists pip3; then
	eval "$(pip3 completion --bash)"
fi

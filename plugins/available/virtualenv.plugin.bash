# shellcheck shell=bash
#
# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'virtualenvwrapper and pyenv-virtualenvwrapper helper functions'

# Check for whole command instead of just pyenv
if [ -n "$(command pyenv virtualenvwrapper --help 2> /dev/null)" ]; then
	pyenv virtualenvwrapper
elif _command_exists virtualenvwrapper.sh; then
	# shellcheck disable=SC1091
	source virtualenvwrapper.sh
else
	_log_debug "${2:-'virtualenvwrapper' was not found}"
fi

function mkvenv {
	about 'create a new virtualenv for this directory'
	group 'virtualenv'

	local cwd="${PWD##*/}"
	mkvirtualenv --distribute "$cwd"
}

function mkvbranch {
	about 'create a new virtualenv for the current branch'
	group 'virtualenv'

	local cwd="${PWD##*/}"
	mkvirtualenv --distribute "${cwd}@${SCM_BRANCH}"
}

function wovbranch {
	about 'sets workon branch'
	group 'virtualenv'

	local cwd="${PWD##*/}"
	workon "${cwd}@${SCM_BRANCH}"
}

function wovenv {
	about 'works on the virtualenv for this directory'
	group 'virtualenv'

	workon "${PWD##*/}"
}

# shellcheck shell=bash

if _command_exists travis
then
  if [[ -s "${__TRAVIS_COMPLETION_SCRIPT:=${TRAVIS_CONFIG_PATH:-${HOME}/.travis}/travis.sh}" ]]
	then
		source "${__TRAVIS_COMPLETION_SCRIPT}"
	fi
  unset __TRAVIS_COMPLETION_SCRIPT
fi

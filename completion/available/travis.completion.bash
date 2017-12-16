if [[ -x "$(which travis)" ]]; then
  __TRAVIS_COMPLETION_SCRIPT="${TRAVIS_CONFIG_PATH:-${HOME}/.travis}/travis.sh"
  [[ -f "${__TRAVIS_COMPLETION_SCRIPT}" ]] && source "${__TRAVIS_COMPLETION_SCRIPT}"
  unset __TRAVIS_COMPLETION_SCRIPT
fi

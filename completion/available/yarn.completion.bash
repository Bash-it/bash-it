# shellcheck shell=bash
about-completion "yarn cli completions"

# shellcheck disable=SC1090 source=../../vendor/github.com/dsifford/yarn-completion/yarn
source "${BASH_IT}/vendor/github.com/dsifford/yarn-completion/yarn"

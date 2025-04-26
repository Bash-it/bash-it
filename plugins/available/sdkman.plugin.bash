# shellcheck shell=bash
cite about-plugin
about-plugin 'Load Software Development Kit Manager'

# Use $SDKMAN_DIR if defined,
# otherwise default to ~/.sdkman
export SDKMAN_DIR=${SDKMAN_DIR:-$HOME/.sdkman}

# shellcheck disable=SC1091
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

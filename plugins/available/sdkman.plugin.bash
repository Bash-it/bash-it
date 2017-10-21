cite about-plugin
about-plugin 'Load Software Development Kit Manager'

# Use $SDKMAN_DIR if defined,
# otherwise default to ~/.sdkman
export SDKMAN_DIR=${SDKMAN_DIR:-$HOME/.sdkman}

[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"


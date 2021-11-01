# shellcheck shell=bash
# shellcheck disable=SC2034
#
# Load the `bash-preexec.sh` library, and define helper functions

## Prepare, load, fix, and install `bash-preexec.sh`

# Disable immediate `$PROMPT_COMMAND` modification
__bp_delay_install="delayed"

# shellcheck source-path=SCRIPTDIR/../github.com/rcaloras/bash-preexec
source "${BASH_IT?}/vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh"

# Block damanaging user's `$HISTCONTROL`
function __bp_adjust_histcontrol() { :; }

# Don't fail on readonly variables
function __bp_require_not_readonly() { :; }

# Disable trap DEBUG on subshells - https://github.com/Bash-it/bash-it/pull/1040
__bp_enable_subshells= # blank
set +T

# Modify `$PROMPT_COMMAND` now
__bp_install_after_session_init

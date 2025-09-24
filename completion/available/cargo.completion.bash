# shellcheck shell=bash
about-completion "cargo (Rust package manager) completion"

# Make sure cargo is installed
_bash-it-completion-helper-necessary rustup cargo || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient cargo || return

eval "$(rustup completions bash cargo)"

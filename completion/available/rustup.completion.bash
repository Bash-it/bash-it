# shellcheck shell=bash
about-completion "rustup (Rust toolchain installer) completion"

# Make sure rustup is installed
_bash-it-completion-helper-necessary rustup || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient rustup || return

eval "$(rustup completions bash)"

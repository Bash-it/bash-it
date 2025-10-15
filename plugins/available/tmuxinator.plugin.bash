# shellcheck shell=bash
cite about-plugin
about-plugin 'sources tmuxinator script if available'
url "https://github.com/tmuxinator/tmuxinator"

# shellcheck disable=SC1091
[[ -s "$HOME/.tmuxinator/scripts/tmuxinator" ]] && . "$HOME/.tmuxinator/scripts/tmuxinator"

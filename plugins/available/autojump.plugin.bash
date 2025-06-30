# shellcheck shell=bash
cite about-plugin
about-plugin 'Autojump configuration, see https://github.com/wting/autojump for more details'

# Only supports the Homebrew variant, Debian and Arch at the moment.
# Feel free to provide a PR to support other install locations
# shellcheck disable=SC1090
if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX}/etc/profile.d/autojump.sh" ]]; then
	# shellcheck disable=SC1091
	source "${BASH_IT_HOMEBREW_PREFIX}/etc/profile.d/autojump.sh"
elif _command_exists dpkg && dpkg -s autojump &> /dev/null; then
	source "$(dpkg-query -S autojump.sh | cut -d' ' -f2)"
elif _command_exists pacman && pacman -Q autojump &> /dev/null; then
	source "$(pacman -Ql autojump | grep autojump.sh | cut -d' ' -f2)"
fi

cite about-plugin
about-plugin 'Autojump configuration, see https://github.com/wting/autojump for more details'

# Only supports the Homebrew variant, Debian and Arch at the moment.
# Feel free to provide a PR to support other install locations
if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX}/etc/profile.d/autojump.sh" ]]; then
  . "${BASH_IT_HOMEBREW_PREFIX}/etc/profile.d/autojump.sh"
elif command -v dpkg &>/dev/null && dpkg -s autojump &>/dev/null ; then
  . "$(dpkg-query -S autojump.sh | cut -d' ' -f2)"
elif command -v pacman &>/dev/null && pacman -Q autojump &>/dev/null ; then
  . "$(pacman -Ql autojump | grep autojump.sh | cut -d' ' -f2)"
fi

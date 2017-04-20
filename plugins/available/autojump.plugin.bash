cite about-plugin
about-plugin 'Autojump configuration, see https://github.com/wting/autojump for more details'

# Only supports the Homebrew variant and Debian at the moment.
# Feel free to provide a PR to support other install locations
if command -v brew &>/dev/null && [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]]; then
  . $(brew --prefix)/etc/profile.d/autojump.sh
elif command -v dpkg &>/dev/null && dpkg -s autojump &>/dev/null ; then
  . "$(dpkg-query -S autojump.sh | cut -d' ' -f2)"
fi

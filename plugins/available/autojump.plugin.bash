cite about-plugin
about-plugin 'Autojump configuration, see https://github.com/wting/autojump for more details'

# Only supports the Homebrew variant, Debian and Arch at the moment.
# Feel free to provide a PR to support other install locations
if command -v brew &>/dev/null && [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]]; then
  . $(brew --prefix)/etc/profile.d/autojump.sh
elif command -v dpkg &>/dev/null && dpkg -s autojump &>/dev/null ; then
  . "$(dpkg-query -S autojump.sh | cut -d' ' -f2)"
elif command -v pacman &>/dev/null && pacman -Q autojump &>/dev/null ; then
  . "$(pacman -Ql autojump | grep autojump.sh | cut -d' ' -f2)"  
fi

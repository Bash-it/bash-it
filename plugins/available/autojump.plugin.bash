cite about-plugin
about-plugin 'Autojump configuration, see https://github.com/wting/autojump for more details'

# Only covers MacOS brew and Debian installs
# Feel free to provide a PR to support other install locations
if command -v brew &>/dev/null && [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]]; then
  source $(brew --prefix)/etc/profile.d/autojump.sh
fi

# Debian / Ubuntu - install it via apt-get install autojump
if [[ -s /usr/share/doc/autojump/README.Debian ]]; then
  source /usr/share/autojump/autojump.sh
fi

# ATTN https://github.com/Bash-it/bash-it/issues/731
# until the issue is fixed, you need to create ~/.bash_it/custom/autojump.sh with this snippet
#
# case $PROMPT_COMMAND in
#     *autojump*)
#         ;;
#     *)
#         PROMPT_COMMAND="${PROMPT_COMMAND:+$(echo "${PROMPT_COMMAND}" | awk '{gsub(/; *$/,"")}1') ; }autojump_add_to_database"
#         ;;
# esac

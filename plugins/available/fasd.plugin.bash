# shellcheck shell=bash
cite about-plugin
about-plugin 'load fasd, if you are using it'
url "https://github.com/clvv/fasd"

_command_exists fasd || return

eval "$(fasd --init auto)"

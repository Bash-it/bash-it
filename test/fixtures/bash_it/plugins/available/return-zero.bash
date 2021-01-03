# shellcheck shell=bash
about-plugin 'fixture plugin for testing plugins that return with a 0 return code'

printf 'return-zero: stdout message\n'
printf 'return-zero: stderr message\n' >&2

return 0

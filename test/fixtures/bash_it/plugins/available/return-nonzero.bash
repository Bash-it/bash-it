# shellcheck shell=bash
about-plugin 'fixture plugin for testing plugins that return with a non-0 return code'

printf 'return-nonzero: stdout message\n'
printf 'return-nonzero: stderr message\n' >&2

return 123

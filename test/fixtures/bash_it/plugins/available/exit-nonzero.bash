# shellcheck shell=bash
about-plugin 'fixture plugin for testing plugins that exit with non-0 exit codes'

printf 'exit-nonzero: stdout message\n'
printf 'exit-nonzero: stderr message\n' >&2

exit 123

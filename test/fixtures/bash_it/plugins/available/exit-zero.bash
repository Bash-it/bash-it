# shellcheck shell=bash
about-plugin 'fixture plugin for testing plugins that exit with a 0 exit code'

printf 'exit-zero: stdout message\n'
printf 'exit-zero: stderr message\n' >&2

exit 0

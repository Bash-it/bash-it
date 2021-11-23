__getopt() {
  local OPTIONS=('-a' '--alternative'
    '-h' '--help'
    '-l' '--longoptions'
    '-n' '--name'
    '-o' '--options'
    '-q' '--quiet'
    '-Q' '--quiet-output'
    '-s' '--shell'
    '-T' '--test'
    '-u' '--unquoted'
    '-V' '--version')

  local SHELL_ARGS=('sh' 'bash' 'csh' 'tcsh')

  local current=$2
  local previous=$3

  case $previous in
    -s|--shell)
      readarray -t COMPREPLY < <(compgen -W "${SHELL_ARGS[*]}" -- "$current")
      ;;
    -n|--name)
      readarray -t COMPREPLY < <(compgen -A function -- "$current")
      ;;
    *)
      readarray -t COMPREPLY < <(compgen -W "${OPTIONS[*]}" -- "$current")
      ;;
  esac
}

complete -F __getopt getopt

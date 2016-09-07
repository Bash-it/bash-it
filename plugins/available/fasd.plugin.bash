cite about-plugin
about-plugin 'initialize fasd (see https://github.com/clvv/fasd)'

__init_fasd() {
  command -v fasd &> /dev/null
  if [ $? -eq 1 ]; then
    echo -e "You must install fasd before you can use this plugin"
    echo -e "See: https://github.com/clvv/fasd"
  else
    eval "$(fasd --init posix-alias)"

    # Note, this is a custom bash-hook to ensure that the last exit status
    # is maintained even while this hook is in place. This code can be
    # removed once PR #72 is merged into fasd.
    #
    # See: https://github.com/clvv/fasd/pull/72
    _fasd_prompt_func() {
      local _exit_code="$?"
      eval "fasd --proc $(fasd --sanitize $(history 1 | \
        sed "s/^[ ]*[0-9]*[ ]*//"))" >> "/dev/null" 2>&1
      return $_exit_code
    }

    # add bash hook
    case $PROMPT_COMMAND in
      *_fasd_prompt_func*) ;;
      "") PROMPT_COMMAND="_fasd_prompt_func";;
      *) PROMPT_COMMAND="_fasd_prompt_func;$PROMPT_COMMAND";;
    esac
    eval "$(fasd --init bash-ccomp bash-ccomp-install)"
  fi
}

__init_fasd

# shellcheck shell=bash

if _binary_exists ngrok; then
  __ngrok_completion() {
    local prev=$(_get_pword)
    local curr=$(_get_cword)

    local BASE_NO_CONF="--log --log-format --log-level"
    local BASE="--config $BASE_NO_CONF"
    local DEFAULT="$BASE --authtoken --region"

    case $prev in
    authtoken)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$BASE" -- "$curr"))
      ;;
    http)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$DEFAULT --auth --bind-tls --host-header --hostname --inspect --subdomain" -- "$curr"))
      ;;
    start)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$DEFAULT --all --none" -- "$curr"))
      ;;
    tcp)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$DEFAULT --remote-addr" -- "$curr"))
      ;;
    tls)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$DEFAULT --client-cas --crt --hostname --key --subdomain" -- "$curr"))
      ;;
    update)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "$BASE_NO_CONF --channel" -- "$curr"))
      ;;
    *)
      # shellcheck disable=SC2207
      COMPREPLY=($(compgen -W "authtoken credits http start tcp tls update version help" -- "$curr"))
      ;;
    esac
  }

  complete -F __ngrok_completion ngrok
fi

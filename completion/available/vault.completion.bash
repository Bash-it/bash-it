# Credit https://github.com/iljaweis/vault-bash-completion/

function _vault() {

  local VAULT_COMMANDS='delete path-help read renew revoke server status write audit-disable audit-enable audit-list auth auth-disable auth-enable capabilities generate-root init key-status list mount mount-tune mounts policies policy-delete policy-write rekey remount rotate seal ssh step-down token-create token-lookup token-renew token-revoke unmount unseal version'

  # get root paths
  vault mounts >/dev/null 2>&1
  if [ $? != 0 ]; then
    # we do not have access to list mounts
    local VAULT_ROOTPATH="secret"
  else
    local VAULT_ROOTPATH=$(vault mounts | tail -n +2 | awk '{print $1}' | paste -s -d ' ' -)
  fi

  local cur=${COMP_WORDS[COMP_CWORD]}
  local line=${COMP_LINE}

  if [ "$(echo $line | wc -w)" -le 2 ]; then
    if [[ "$line" =~ ^vault\ (read|write|delete|list)\ $ ]]; then
      COMPREPLY=($(compgen -W "$VAULT_ROOTPATH" -- ''))
    else
      COMPREPLY=($(compgen -W "$VAULT_COMMANDS" -- $cur))
    fi
  elif [[ "$line" =~ ^vault\ (read|write|delete|list)\ (.*)$ ]]; then
    path=${BASH_REMATCH[2]}
    if [[ "$path" =~ ^([^ ]+)/([^ /]*)$ ]]; then
      list=$(vault list ${BASH_REMATCH[1]} | tail -n +2)
      COMPREPLY=($(compgen -W "$list" -P "${BASH_REMATCH[1]}/" -- ${BASH_REMATCH[2]}))
    else
      COMPREPLY=($(compgen -W "$VAULT_ROOTPATH" -- $path))
    fi
  fi
}

complete -o default -o nospace -F _vault vault

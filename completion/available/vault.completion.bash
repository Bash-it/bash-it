# ---------------------------------------------------------------------------
# vault-bash-completion
#
# This adds bash completions for [HashiCorp Vault](https://www.vaultproject.io/)
#
# see https://github.com/iljaweis/vault-bash-completion
# ---------------------------------------------------------------------------

function _vault_mounts() {
  (
    set -euo pipefail
    if ! vault mounts 2> /dev/null | awk 'NR > 1 {print $1}'; then
      echo "secret"
    fi
  )
}

function _vault() {
  local VAULT_COMMANDS=$(vault 2>&1 | egrep '^ +' | awk '{print $1}')

  local cur
  local prev

  if [ $COMP_CWORD -gt 0 ]; then
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
  fi

  local line=${COMP_LINE}

  if [[ $prev =~ ^(policies|policy-write|policy-delete) ]]; then
    local policies=$(vault policies 2> /dev/null)
    COMPREPLY=($(compgen -W "$policies" -- $cur))
  elif [ "$(echo $line | wc -w)" -le 2 ]; then
    if [[ "$line" =~ ^vault\ (read|write|delete|list)\ $ ]]; then
      COMPREPLY=($(compgen -W "$(_vault_mounts)" -- ''))
    else
      COMPREPLY=($(compgen -W "$VAULT_COMMANDS" -- $cur))
    fi
  elif [[ "$line" =~ ^vault\ (read|write|delete|list)\ (.*)$ ]]; then
    path=${BASH_REMATCH[2]}
    if [[ "$path" =~ ^([^ ]+)/([^ /]*)$ ]]; then
      list=$(vault list -format=yaml ${BASH_REMATCH[1]} 2> /dev/null | awk '{ print $2 }')
      COMPREPLY=($(compgen -W "$list" -P "${BASH_REMATCH[1]}/" -- ${BASH_REMATCH[2]}))
    else
      COMPREPLY=($(compgen -W "$(_vault_mounts)" -- $path))
    fi
  fi
}

complete -o default -o nospace -F _vault vault

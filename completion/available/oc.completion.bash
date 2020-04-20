CMD="$(which oc)"
[[ -x "$CMD" ]] && source <("$CMD" completion bash)

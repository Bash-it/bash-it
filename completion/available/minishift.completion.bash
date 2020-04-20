CMD="$(which minishift)"
[[ -x "$CMD" ]] && source <("$CMD" completion bash)

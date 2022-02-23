# shellcheck shell=bash
about-completion "Bash completion support for  RVM."
# Source: https://rvm.io/workflow/completion

if [[ -n "${rvm_path:-}" && -s "${rvm_path}/scripts/completion" ]]; then
	# shellcheck disable=SC1091
	source "${rvm_path}/scripts/completion"
fi

# shellcheck shell=bash

cite "about-completion"
about-completion "laravel - PHP web application framework installer and command-line tool"
group "php"
url "https://laravel.com/"

# Make sure laravel is installed
_bash-it-completion-helper-necessary laravel || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient laravel || return

function __laravel_completion() {
	local OPTS=('-h' '--help' '-q' '--quiet' '--ansi' '--no-ansi' '-n' '--no-interaction' '-v' '-vv' '-vvv' '--verbose' 'help' 'list' 'new')
	local _opt_
	COMPREPLY=()
	for _opt_ in "${OPTS[@]}"; do
		if [[ "$_opt_" == "$2"* ]]; then
			COMPREPLY+=("$_opt_")
		fi
	done
}

complete -F __laravel_completion laravel

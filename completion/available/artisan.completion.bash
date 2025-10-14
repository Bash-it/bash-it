# shellcheck shell=bash
cite "about-completion"
about-completion "Laravel artisan completion"
group "php"
url "https://laravel.com/docs/artisan"

# Completion function for Laravel artisan
_artisan_completion() {
	local cur artisan_commands
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	# Only provide completions if artisan file exists in current directory
	if [[ ! -f "artisan" ]]; then
		return 0
	fi

	# Get list of available artisan commands
	# Use command prefix to bypass user aliases
	# shellcheck disable=SC2034
	artisan_commands=$(command php artisan --raw --no-ansi list 2> /dev/null | command sed "s/[[:space:]].*//")

	# shellcheck disable=SC2016,SC2207
	COMPREPLY=($(compgen -W '${artisan_commands}' -- "${cur}"))
	return 0
}

# Complete for both 'artisan' and common alias 'art'
complete -F _artisan_completion artisan art

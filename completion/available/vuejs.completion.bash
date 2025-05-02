# shellcheck shell=bash

# Make sure vue is installed
_bash-it-completion-helper-necessary vue || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient vue || return

function _vuejs() {
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"

	case $prev in
		create)
			COMPREPLY=("-p" "-d" "-i" "-m" "-r" "-g" "-n" "-f" "-c" "-x" "-b"
				"-h" "--help" "--preset" "--default" "--inilinePreset"
				"--packageManager" "--registry" "--git" "--no-git" "--force"
				"--merge" "--clone" "--proxy" "--bare" "" "--skipGetStarted")
			;;
		add | invoke)
			COMPREPLY=("--registry" "-h" "--help")
			;;
		inspect)
			COMPREPLY=("-v" "--help" "--verbose" "--mode" "--rule" "--plugin"
				"--plugins" "--rules")
			;;
		serve)
			COMPREPLY=("-o" "-h" "--help" "--open" "-c" "--copy" "-p" "--port")
			;;
		build)
			COMPREPLY=("-t" "--target" "-n" "--name" "-d" "--dest" "-h" "--help")
			;;
		ui)
			COMPREPLY=("-H" "--host" "-p" "--port" "-D" "--dev" "--quiet"
				"--headless" "-h" "--help")
			;;
		init)
			COMPREPLY=("-c" "--clone" "--offline" "-h" "--help")
			;;
		config)
			COMPREPLY=("-g" "--get" "-s" "--set" "-d" "--delete" "-e" "--edit"
				"--json" "-h" "--help")
			;;
		outdated)
			COMPREPLY=("--next" "-h" "--help")
			;;
		upgrade)
			COMPREPLY=("-t" "--to" "-f" "--from" "-r" "--registry" "--all"
				"--next" "-h" "--help")
			;;
		migrate)
			COMPREPLY=("-f" "--from" "-h" "--help")
			;;
		*)
			COMPREPLY=("-h" "--help" "-v" "--version" "create" "add" "invoke"
				"inspect" "serve" "build" "ui" "init" "config" "outdated"
				"upgrade" "migrate" "info")
			;;
	esac
}

complete -F _vuejs -X '!&*' vue

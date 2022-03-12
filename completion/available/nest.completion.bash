# shellcheck shell=bash
cite "about-completion"
about-completion "nestjs CLI completion"

if _command_exists nest; then
	function __nestjs_completion() {
		local prev
		local curr
		local cmd
		cmd=${COMP_WORDS[1]}
		prev=$(_get_pword)
		curr=$(_get_cword)

		local HELP
		HELP=(-h --help)

		case $cmd in
			n | new)
				case $prev in
					-p | --package-manager)
						COMPREPLY=({p,}npm yarn)
						;;
					-l | --language)
						COMPREPLY=({type,java}script)
						;;
					*)
						COMPREPLY=("${HELP[@]}" --directory -d --dry-run -g --skip-git -s --skip-install -p --package-manager -l --language -c --collection)
						;;
				esac
				;;
			build | start)
				COMPREPLY=("${HELP[@]}" -c --config -p --path -w --watch --watchAssets --webpack --webpackPath --tsc)
				if [[ $cmd == "start" ]]; then
					COMPREPLY=("${COMPREPLY[@]}" -e --exec --preserveWatchOutput)
				fi
				;;
			i | info)
				COMPREPLY=("${HELP[@]}")
				;;
			u | update)
				case $prev in
					-t | --tag)
						COMPREPLY=(latest beta rc next)
						;;
					*)
						COMPREPLY=("${HELP[@]}" -f --force -t --tag)
						;;
				esac
				;;
			add)
				COMPREPLY=("${HELP[@]}" -d --dry-run -p --project)
				;;
			g | generate)
				case $curr in
					-*)
						COMPREPLY=("${HELP[@]}" -d --dry-run -p --project --flat --{no,-}spec -c --collection)
						;;
					*)
						COMPREPLY=(application class configuration controller decorator filter gateway guard interceptor interface middleware module pipe provider resolver service library sub-app resource)
						;;
				esac
				;;
			*)
				COMPREPLY=("${HELP[@]}" -v --version new n build start info i update u add generate g)
				;;
		esac
	}

	complete -F __nestjs_completion -X "!&*" nest
fi

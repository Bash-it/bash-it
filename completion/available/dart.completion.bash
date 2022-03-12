# shellcheck shell=bash

if _command_exists dart; then
	function __dart_completion() {
		local prev HELP VERBOSE cmd

		prev=$(_get_pword)
		cmd=${COMP_WORDS[1]}

		HELP=(--help -h)
		VERBOSE=(-v --verbose)

		case $cmd in
			analyze)
				COMPREPLY=("${HELP[@]}" --fatal-infos --{no-,}fatal-warnings)
				;;

			compile)
				COMPREPLY=("${HELP[@]}" {aot,jit}-snapshot exe js kernel)
				;;

			create)
				case $prev in
					-t | --template)
						COMPREPLY=({console,package,web}-simple console-full server-shelf)
						;;
					*)
						COMPREPLY=("${HELP[@]}" -t --template --{no-,}pub --force)
						;;
				esac
				;;

			fix)
				COMPREPLY=("${HELP[@]}" -n --dry-run --apply)
				;;

			format)
				case $prev in
					-o | --output)
						COMPREPLY=(json none show write)
						;;
					*)
						COMPREPLY=("${HELP[@]} ${VERBOSE[@]}" -o --output -l --line-length --fix --set-exit-if-changed)
						;;
				esac
				;;

			migrate)
				COMPREPLY=("${HELP[@]}"--apply-changes --ignore-errors --skip-import-check --{no-,}web-preview --preview-hostname --preview-port --summary)
				;;

			pub)
				case $prev in
					add)
						COMPREPLY=("${HELP[@]}" -d --dev --git-{url,ref,path} --hosted-url --path --sdk --{no-,}offline -n --dry-run --{no-,}precompile -C --directory)
						;;
					cache)
						COMPREPLY=("${HELP[@]}" add clean repair)
						;;
					deps)
						COMPREPLY=("${HELP[@]}" -s --style --{no-,}dev --executables --json -C --directory)
						;;
					downgrade)
						COMPREPLY=("${HELP[@]}" --{no-,}offline -n --dry-run -C --directory)
						;;
					get)
						COMPREPLY=("${HELP[@]}" --{no-,}{offline,precompile} -n --dry-run -C --directory)
						;;
					global)
						COMPREPLY=("${HELP[@]}" activate deactivate list run)
						;;
					login | logout)
						COMPREPLY=("${HELP[@]}")
						;;
					outdated)
						COMPREPLY=("${HELP[@]}" --{no-,}{color,dependency-overrides,dev-dependencies,prereleases,show-all,transitive} --json --mode -C --directory)
						;;
					publish)
						COMPREPLY=("${HELP[@]}" -n --dry-run -f --force -C --directory)
						;;
					remove)
						COMPREPLY=("${HELP[@]}" --{no-,}{offline,precompile} -n --dry-run -C --directory)
						;;
					upgrade)
						COMPREPLY=("${HELP[@]}" --{no-,}{offline,precompile} -n --dry-run --null-safety --major-versions -C --directory)
						;;
					uploader)
						COMPREPLY=("${HELP[@]}" -p --package -C --directory)
						;;

					*)
						COMPREPLY=("${HELP[@]} ${VERBOSE[@]}" --{no-,}trace add cache deps downgrade get global log{in,out} outdated publish remove upgrade uploader)
						;;
				esac
				;;

			run)
				case $prev in
					--verbosity)
						COMPREPLY=(all error info warning)
						;;
					*)
						COMPREPLY=("${HELP[@]}" --observe --enable-vm-service --{no-,}{serve-devtools,pause-isolates-on-{exit,unhandled-exceptions,start},warn-on-pause-with-no-debugger,enable-asserts} --verbosity -D --define)
						;;
				esac
				;;

			*)
				COMPREPLY=("${HELP[@]} ${VERBOSE[@]}" --version --{enable,disable}-analytics analyze compile create fix format migrate pub run test help)
				;;
		esac
	}

	complete -F __dart_completion -X "!&*" dart
fi

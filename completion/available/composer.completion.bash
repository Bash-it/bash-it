# shellcheck shell=bash
cite "about-completion"
about-completion "composer completion"

function __composer_completion() {
	local cur coms opts com words
	COMPREPLY=()
	_get_comp_words_by_ref -n : cur words

	# lookup for command
	for word in "${words[@]:1}"; do
		if [[ "${word}" != -* ]]; then
			com="${word}"
			break
		fi
	done

	# completing for an option
	if [[ ${cur} == --* ]]; then
		opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --profile --no-plugins --working-dir"

		case "${com}" in
			about)
				opts="${opts} "
				;;
			archive)
				opts="${opts} --format --dir --file"
				;;
			browse)
				opts="${opts} --homepage --show"
				;;
			clear-cache)
				opts="${opts} "
				;;
			config)
				opts="${opts} --global --editor --auth --unset --list --file --absolute"
				;;
			create-project)
				opts="${opts} --stability --prefer-source --prefer-dist --repository --repository-url --dev --no-dev --no-custom-installers --no-scripts --no-progress --no-secure-http --keep-vcs --no-install --ignore-platform-reqs"
				;;
			depends)
				opts="${opts} --recursive --tree"
				;;
			diagnose)
				opts="${opts} "
				;;
			dump-autoload)
				opts="${opts} --no-scripts --optimize --classmap-authoritative --apcu --no-dev"
				;;
			exec)
				opts="${opts} --list"
				;;
			global)
				opts="${opts} "
				;;
			help)
				opts="${opts} --xml --format --raw"
				;;
			init)
				opts="${opts} --name --description --author --type --homepage --require --require-dev --stability --license --repository"
				;;
			install)
				opts="${opts} --prefer-source --prefer-dist --dry-run --dev --no-dev --no-custom-installers --no-autoloader --no-scripts --no-progress --no-suggest --optimize-autoloader --classmap-authoritative --apcu-autoloader --ignore-platform-reqs"
				;;
			licenses)
				opts="${opts} --format --no-dev"
				;;
			list)
				opts="${opts} --xml --raw --format"
				;;
			outdated)
				opts="${opts} --outdated --all --direct --strict"
				;;
			prohibits)
				opts="${opts} --recursive --tree"
				;;
			remove)
				opts="${opts} --dev --no-progress --no-update --no-scripts --update-no-dev --update-with-dependencies --no-update-with-dependencies --ignore-platform-reqs --optimize-autoloader --classmap-authoritative --apcu-autoloader"
				;;
			require)
				opts="${opts} --dev --prefer-source --prefer-dist --no-progress --no-suggest --no-update --no-scripts --update-no-dev --update-with-dependencies --ignore-platform-reqs --prefer-stable --prefer-lowest --sort-packages --optimize-autoloader --classmap-authoritative --apcu-autoloader"
				;;
			run-script)
				opts="${opts} --timeout --dev --no-dev --list"
				;;
			search)
				opts="${opts} --only-name --type"
				;;
			self-update)
				opts="${opts} --rollback --clean-backups --no-progress --update-keys --stable --preview --snapshot"
				;;
			show)
				opts="${opts} --all --installed --platform --available --self --name-only --path --tree --latest --outdated --minor-only --direct --strict"
				;;
			status)
				opts="${opts} "
				;;
			suggests)
				opts="${opts} --by-package --by-suggestion --no-dev"
				;;
			update)
				opts="${opts} --prefer-source --prefer-dist --dry-run --dev --no-dev --lock --no-custom-installers --no-autoloader --no-scripts --no-progress --no-suggest --with-dependencies --optimize-autoloader --classmap-authoritative --apcu-autoloader --ignore-platform-reqs --prefer-stable --prefer-lowest --interactive --root-reqs"
				;;
			validate)
				opts="${opts} --no-check-all --no-check-lock --no-check-publish --with-dependencies --strict"
				;;

		esac

		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
		__ltrim_colon_completions "${cur}"

		return 0
	fi

	# completing for a command
	if [[ "${cur}" == "${com}" ]]; then
		coms="about archive browse clear-cache config create-project depends diagnose dump-autoload exec global help init install licenses list outdated prohibits remove require run-script search self-update show status suggests update validate"

		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "${coms}" -- "${cur}"))
		__ltrim_colon_completions "${cur}"

		return 0
	fi
}

complete -o default -F __composer_completion composer

# shellcheck shell=bash
# shellcheck disable=SC2016
#
# A collection of reusable functions.

: "${BASH_IT_LOAD_PRIORITY_ALIAS:=150}"
: "${BASH_IT_LOAD_PRIORITY_PLUGIN:=250}"
: "${BASH_IT_LOAD_PRIORITY_COMPLETION:=350}"
BASH_IT_LOAD_PRIORITY_SEPARATOR="---"

# Handle the different ways of running `sed` without generating a backup file based on provenance:
# - GNU sed (Linux) uses `-i''`
# - BSD sed (FreeBSD/macOS/Solaris/PlayStation) uses `-i ''`
# To use this in Bash-it for inline replacements with `sed`, use the following syntax:
# sed "${BASH_IT_SED_I_PARAMETERS[@]}" -e "..." file
# shellcheck disable=SC2034 # expected for this case
if sed --version > /dev/null 2>&1; then
	# GNU sed accepts "long" options
	BASH_IT_SED_I_PARAMETERS=('-i')
else
	# BSD sed errors on invalid option `-`
	BASH_IT_SED_I_PARAMETERS=('-i' '')
fi

function _bash_it_homebrew_check() {
	if _binary_exists 'brew'; then
		# Homebrew is installed
		if [[ "${BASH_IT_HOMEBREW_PREFIX:-unset}" == 'unset' ]]; then
			# variable isn't set
			BASH_IT_HOMEBREW_PREFIX="$(brew --prefix)"
		else
			true # Variable is set already, don't invoke `brew`.
		fi
	else
		# Homebrew is not installed: clear variable.
		BASH_IT_HOMEBREW_PREFIX=
		false # return failure if brew not installed.
	fi
}

function _make_reload_alias() {
	echo "source '${BASH_IT?}/scripts/reloader.bash' '${1?}' '${2?}'"
}

# Alias for reloading aliases
# shellcheck disable=SC2139
alias reload_aliases="$(_make_reload_alias alias aliases)"

# Alias for reloading auto-completion
# shellcheck disable=SC2139
alias reload_completion="$(_make_reload_alias completion completion)"

# Alias for reloading plugins
# shellcheck disable=SC2139
alias reload_plugins="$(_make_reload_alias plugin plugins)"

function bash-it() {
	about 'Bash-it help and maintenance'
	param '1: verb [one of: help | show | enable | disable | migrate | update | search | preview | version | reload | restart | doctor ] '
	param '2: component type [one of: alias(es) | completion(s) | plugin(s) ] or search term(s)'
	param '3: specific component [optional]'
	example '$ bash-it show plugins'
	example '$ bash-it help aliases'
	example '$ bash-it enable plugin git [tmux]...'
	example '$ bash-it disable alias hg [tmux]...'
	example '$ bash-it migrate'
	example '$ bash-it update'
	example '$ bash-it search [-|@]term1 [-|@]term2 ... [ -e/--enable ] [ -d/--disable ] [ -r/--refresh ] [ -c/--no-color ]'
	example '$ bash-it preview'
	example '$ bash-it preview essential'
	example '$ bash-it version'
	example '$ bash-it reload'
	example '$ bash-it restart'
	example '$ bash-it profile list|save|load|rm [profile_name]'
	example '$ bash-it doctor errors|warnings|all'
	local verb=${1:-}
	shift
	local component=${1:-}
	shift
	local func

	case "$verb" in
		show)
			func="_bash-it-$component"
			;;
		enable)
			func="_enable-$component"
			;;
		disable)
			func="_disable-$component"
			;;
		help)
			func="_help-$component"
			;;
		doctor)
			func="_bash-it-doctor-$component"
			;;
		profile)
			func=_bash-it-profile-$component
			;;
		search)
			_bash-it-search "$component" "$@"
			return
			;;
		preview)
			_bash-it-preview "$component" "$@"
			return
			;;
		update)
			func="_bash-it-update-$component"
			;;
		migrate)
			func="_bash-it-migrate"
			;;
		version)
			func="_bash-it-version"
			;;
		restart)
			func="_bash-it-restart"
			;;
		reload)
			func="_bash-it-reload"
			;;
		*)
			reference "bash-it"
			return
			;;
	esac

	# pluralize component if necessary
	if ! _is_function "$func"; then
		if _is_function "${func}s"; then
			func="${func}s"
		else
			if _is_function "${func}es"; then
				func="${func}es"
			else
				echo "oops! $component is not a valid option!"
				reference bash-it
				return
			fi
		fi
	fi

	if [[ "$verb" == "enable" || "$verb" == "disable" ]]; then
		# Automatically run a migration if required
		_bash-it-migrate

		for arg in "$@"; do
			"$func" "$arg"
		done

		if [[ -n "${BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE:-}" ]]; then
			_bash-it-reload
		fi
	else
		"$func" "$@"
	fi
}

function _bash-it-aliases() {
	_about 'summarizes available bash_it aliases'
	_group 'lib'

	_bash-it-describe "aliases" "an" "alias" "Alias"
}

function _bash-it-completions() {
	_about 'summarizes available bash_it completions'
	_group 'lib'

	_bash-it-describe "completion" "a" "completion" "Completion"
}

function _bash-it-plugins() {
	_about 'summarizes available bash_it plugins'
	_group 'lib'

	_bash-it-describe "plugins" "a" "plugin" "Plugin"
}

function _bash-it-update-dev() {
	_about 'updates Bash-it to the latest master'
	_group 'lib'

	_bash-it-update- dev "$@"
}

function _bash-it-update-stable() {
	_about 'updates Bash-it to the latest tag'
	_group 'lib'

	_bash-it-update- stable "$@"
}

function _bash-it_update_migrate_and_restart() {
	_about 'Checks out the wanted version, pops directory and restart. Does not return (because of the restart!)'
	_param '1: Which branch to checkout to'
	_param '2: Which type of version we are using'
	if git checkout "${1?}" &> /dev/null; then
		echo "Bash-it successfully updated."
		echo ""
		echo "Migrating your installation to the latest ${2:-} version now..."
		_bash-it-migrate
		echo ""
		echo "All done, enjoy!"
		# Don't forget to restore the original pwd (called from `_bash-it-update-`)!
		popd > /dev/null || return
		_bash-it-restart
	else
		echo "Error updating Bash-it, please, check if your Bash-it installation folder (${BASH_IT}) is clean."
	fi
}

function _bash-it-update-() {
	_about 'updates Bash-it'
	_param '1: What kind of update to do (stable|dev)'
	_group 'lib'

	local silent word DIFF version TARGET revision status revert log_color RESP
	for word in "$@"; do
		if [[ "${word}" == "--silent" || "${word}" == "-s" ]]; then
			silent=true
		fi
	done

	pushd "${BASH_IT?}" > /dev/null || return

	DIFF=$(git diff --name-status)
	if [[ -n "$DIFF" ]]; then
		echo -e "Local changes detected in bash-it directory. Clean '$BASH_IT' directory to proceed.\n$DIFF"
		popd > /dev/null || return
		return 1
	fi

	if [[ -z "$BASH_IT_REMOTE" ]]; then
		BASH_IT_REMOTE="origin"
	fi

	git fetch "$BASH_IT_REMOTE" --tags &> /dev/null

	if [[ -z "$BASH_IT_DEVELOPMENT_BRANCH" ]]; then
		BASH_IT_DEVELOPMENT_BRANCH="master"
	fi
	# Defaults to stable update
	if [[ -z "${1:-}" || "$1" == "stable" ]]; then
		version="stable"
		TARGET=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2> /dev/null)

		if [[ -z "$TARGET" ]]; then
			echo "Can not find tags, so can not update to latest stable version..."
			popd > /dev/null || return
			return
		fi
	else
		version="dev"
		TARGET="${BASH_IT_REMOTE}/${BASH_IT_DEVELOPMENT_BRANCH}"
	fi

	revision="HEAD..${TARGET}"
	status="$(git rev-list "${revision}" 2> /dev/null)"

	if [[ -z "${status}" && "${version}" == "stable" ]]; then
		revision="${TARGET}..HEAD"
		status="$(git rev-list "${revision}" 2> /dev/null)"
		revert=true
	fi

	if [[ -n "${status}" ]]; then
		if [[ -n "${revert}" ]]; then
			echo "Your version is a more recent development version ($(git log -1 --format=%h HEAD))"
			echo "You can continue in order to revert and update to the latest stable version"
			echo ""
			log_color="%Cred"
		fi

		git log --no-merges --format="${log_color}%h: %s (%an)" "${revision}"
		echo ""

		if [[ -n "${silent}" ]]; then
			echo "Updating to ${TARGET}($(git log -1 --format=%h "${TARGET}"))..."
			_bash-it_update_migrate_and_restart "$TARGET" "$version"
		else
			read -r -e -n 1 -p "Would you like to update to ${TARGET}($(git log -1 --format=%h "${TARGET}"))? [Y/n] " RESP
			case "$RESP" in
				[yY] | "")
					_bash-it_update_migrate_and_restart "$TARGET" "$version"
					;;
				[nN])
					echo "Not updating…"
					;;
				*)
					echo -e "${echo_orange?}Please choose y or n.${echo_reset_color?}"
					;;
			esac
		fi
	else
		if [[ "${version}" == "stable" ]]; then
			echo "You're on the latest stable version. If you want to check out the latest 'dev' version, please run \"bash-it update dev\""
		else
			echo "Bash-it is up to date, nothing to do!"
		fi
	fi
	popd > /dev/null || return
}

function _bash-it-migrate() {
	_about 'migrates Bash-it configuration from a previous format to the current one'
	_group 'lib'

	local migrated_something component_type component_name single_type file_type _bash_it_config_file disable_func enable_func
	migrated_something=false

	for file_type in "aliases" "plugins" "completion"; do
		for _bash_it_config_file in "${BASH_IT}/$file_type/enabled"/*.bash; do
			[[ -f "$_bash_it_config_file" ]] || continue

			# Get the type of component from the extension
			component_type="$(_bash-it-get-component-type-from-path "$_bash_it_config_file")"
			# Cut off the optional "250---" prefix and the suffix
			component_name="$(_bash-it-get-component-name-from-path "$_bash_it_config_file")"

			migrated_something=true

			single_type="${component_type/aliases/aliass}"
			echo "Migrating ${single_type%s} $component_name."

			disable_func="_disable-${single_type%s}"
			enable_func="_enable-${single_type%s}"

			"$disable_func" "$component_name"
			"$enable_func" "$component_name"
		done
	done

	if [[ -n "${BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE:-}" ]]; then
		_bash-it-reload
	fi

	if [[ "$migrated_something" == "true" ]]; then
		echo ""
		echo "If any migration errors were reported, please try the following: reload && bash-it migrate"
	fi
}

function _bash-it-version() {
	_about 'shows current Bash-it version'
	_group 'lib'

	local BASH_IT_GIT_REMOTE BASH_IT_GIT_URL current_tag BASH_IT_GIT_VERSION_INFO TARGET

	pushd "${BASH_IT?}" > /dev/null || return

	if [[ -z "${BASH_IT_REMOTE:-}" ]]; then
		BASH_IT_REMOTE="origin"
	fi

	BASH_IT_GIT_REMOTE="$(git remote get-url "$BASH_IT_REMOTE")"
	BASH_IT_GIT_URL="${BASH_IT_GIT_REMOTE%.git}"
	if [[ "$BASH_IT_GIT_URL" == *"git@"* ]]; then
		# Fix URL in case it is ssh based URL
		BASH_IT_GIT_URL="${BASH_IT_GIT_URL/://}"
		BASH_IT_GIT_URL="${BASH_IT_GIT_URL/git@/https://}"
	fi

	current_tag="$(git describe --exact-match --tags 2> /dev/null)"

	if [[ -z "$current_tag" ]]; then
		BASH_IT_GIT_VERSION_INFO="$(git log --pretty=format:'%h on %aI' -n 1)"
		TARGET="${BASH_IT_GIT_VERSION_INFO%% *}"
		echo "Version type: dev"
		echo "Current git SHA: $BASH_IT_GIT_VERSION_INFO"
		echo "Commit info: $BASH_IT_GIT_URL/commit/$TARGET"
	else
		TARGET="$current_tag"
		echo "Version type: stable"
		echo "Current tag: $current_tag"
		echo "Tag information: $BASH_IT_GIT_URL/releases/tag/$current_tag"
	fi

	echo "Compare to latest: $BASH_IT_GIT_URL/compare/$TARGET...master"

	popd > /dev/null || return
}

function _bash-it-doctor() {
	_about 'reloads a profile file with a BASH_IT_LOG_LEVEL set'
	_param '1: BASH_IT_LOG_LEVEL argument: "errors" "warnings" "all"'
	_group 'lib'

	# shellcheck disable=SC2034 # expected for this case
	local BASH_IT_LOG_LEVEL="${1?}"
	_bash-it-reload
}

function _bash-it-doctor-all() {
	_about 'reloads a profile file with error, warning and debug logs'
	_group 'lib'

	_bash-it-doctor "${BASH_IT_LOG_LEVEL_ALL?}"
}

function _bash-it-doctor-warnings() {
	_about 'reloads a profile file with error and warning logs'
	_group 'lib'

	_bash-it-doctor "${BASH_IT_LOG_LEVEL_WARNING?}"
}

function _bash-it-doctor-errors() {
	_about 'reloads a profile file with error logs'
	_group 'lib'

	_bash-it-doctor "${BASH_IT_LOG_LEVEL_ERROR?}"
}

function _bash-it-doctor-() {
	_about 'default bash-it doctor behavior, behaves like bash-it doctor all'
	_group 'lib'

	_bash-it-doctor-all
}

function _bash-it-profile-save() {
	_about 'saves the current configuration to the "profile" directory'
	_group 'lib'

	local name="${1:-}"
	while [[ -z "$name" ]]; do
		read -r -e -p "Please enter the name of the profile to save: " name
		case "$name" in
			"")
				echo -e "${echo_orange?}Please choose a name.${echo_reset_color?}"
				;;
			*)
				break
				;;
		esac
	done

	local profile_path="${BASH_IT}/profiles/${name}.bash_it" RESP
	if [[ -s "$profile_path" ]]; then
		echo -e "${echo_yellow?}Profile '$name' already exists.${echo_reset_color?}"
		while true; do
			read -r -e -n 1 -p "Would you like to overwrite existing profile? [y/N] " RESP
			case "$RESP" in
				[yY])
					echo -e "${echo_green?}Overwriting profile '$name'...${echo_reset_color?}"
					break
					;;
				[nN] | "")
					echo -e "${echo_orange?}Aborting profile save...${echo_reset_color?}"
					return 1
					;;
				*)
					echo -e "${echo_orange?}Please choose y or n.${echo_reset_color?}"
					;;
			esac
		done
	fi

	local something_exists subdirectory component_exists f enabled_file
	echo "# This file is auto generated by Bash-it. Do not edit manually!" > "$profile_path"
	for subdirectory in "plugins" "completion" "aliases"; do
		echo "Saving $subdirectory configuration..."
		for f in "${BASH_IT}/$subdirectory/available"/*.bash; do
			if _bash-it-component-item-is-enabled "$f"; then
				if [[ -z "${component_exists:-}" ]]; then
					# This is the first component of this type, print the header
					component_exists="yes"
					something_exists="yes"
					echo "" >> "$profile_path"
					echo "# $subdirectory" >> "$profile_path"
				fi
				enabled_file="$(_bash-it-get-component-name-from-path "$f")"
				echo "$subdirectory $enabled_file" >> "$profile_path"
			fi
		done
	done
	if [[ -z "${something_exists:-}" ]]; then
		echo "It seems like no configuration was enabled.."
		echo "Make sure to double check that this is the wanted behavior."
	fi

	echo "All done!"
	echo ""
	echo "Profile location: $profile_path"
	echo "Load the profile by invoking \"bash-it profile load $name\""
}

_bash-it-profile-load-parse-profile() {
	_about 'Internal function used to parse the profile file'
	_param '1: path to the profile file'
	_param '2: dry run- only check integrity of the profile file'
	_example '$ _bash-it-profile-load-parse-profile "profile.bash_it" "dry"'

	local -i num=0
	local line enable_func subdirectory component to_enable bad
	while read -r -a line; do
		((++num))
		# Ignore comments and empty lines
		[[ -z "${line[*]}" || "${line[*]}" =~ ^#.* ]] && continue
		enable_func="_enable-${line[0]}"
		subdirectory=${line[0]}
		component=${line[1]}

		to_enable=("${BASH_IT}/$subdirectory/available/$component.${subdirectory%s}"*.bash)
		# Ignore botched lines
		if [[ ! -e "${to_enable[0]}" ]]; then
			echo -e "${echo_orange?}Bad line(#$num) in profile, aborting load...${line[*]}${echo_reset_color?}"
			bad="bad line"
			break
		fi
		# Do not actually modify config on dry run
		[[ -z "${2:-}" ]] || continue
		# Actually enable the component
		$enable_func "$component"
	done < "${1?}"

	# Make sure to propagate the error
	[[ -z ${bad:-} ]]
}

_bash-it-profile-list() {
	about 'lists all profiles from the "profiles" directory'
	_group 'lib'
	local profile

	echo "Available profiles:"
	for profile in "${BASH_IT}/profiles"/*.bash_it; do
		profile="${profile##*/}"
		echo "${profile/.bash_it/}"
	done
}

_bash-it-profile-rm() {
	about 'Removes a profile from the "profiles" directory'
	_group 'lib'

	local name="${1:-}"
	if [[ -z $name ]]; then
		echo -e "${echo_orange?}Please specify profile name to remove...${echo_reset_color?}"
		return 1
	fi

	# Users should not be allowed to delete the default profile
	if [[ $name == "default" ]]; then
		echo -e "${echo_orange?}Can not remove the default profile...${echo_reset_color?}"
		return 1
	fi

	local profile_path="${BASH_IT}/profiles/$name.bash_it"
	if [[ ! -f "$profile_path" ]]; then
		echo -e "${echo_orange?}Could not find profile '$name'...${echo_reset_color?}"
		return 1
	fi

	command rm "$profile_path"
	echo "Removed profile '$name' successfully!"
}

_bash-it-profile-load() {
	_about 'loads a configuration from the "profiles" directory'
	_group 'lib'

	local name="${1:-}"
	if [[ -z $name ]]; then
		echo -e "${echo_orange?}Please specify profile name to load, not changing configuration...${echo_reset_color?}"
		return 1
	fi

	local profile_path="${BASH_IT}/profiles/$name.bash_it"
	if [[ ! -f "$profile_path" ]]; then
		echo -e "${echo_orange?}Could not find profile '$name', not changing configuration...${echo_reset_color?}"
		return 1
	fi

	echo "Trying to parse profile '$name'..."
	if _bash-it-profile-load-parse-profile "$profile_path" "dry"; then
		echo "Profile '$name' parsed successfully!"
		echo "Disabling current configuration..."
		_disable-all
		echo ""
		echo "Enabling configuration based on profile..."
		_bash-it-profile-load-parse-profile "$profile_path"
		echo ""
		echo "Profile '$name' enabled!"
	else
		false # failure
	fi
}

function _bash-it-restart() {
	_about 'restarts the shell in order to fully reload it'
	_group 'lib'

	exec "${0#-}" --rcfile "${BASH_IT_BASHRC:-${HOME?}/.bashrc}"
}

function _bash-it-reload() {
	_about 'reloads the shell initialization file'
	_group 'lib'

	# shellcheck disable=SC1090
	source "${BASH_IT_BASHRC:-${HOME?}/.bashrc}"
}

function _bash-it-describe() {
	_about 'summarizes available bash_it components'
	_param '1: subdirectory'
	_param '2: preposition'
	_param '3: file_type'
	_param '4: column_header'
	_example '$ _bash-it-describe "plugins" "a" "plugin" "Plugin"'

	local subdirectory preposition file_type column_header f enabled enabled_file
	subdirectory="$1"
	preposition="$2"
	file_type="$3"
	column_header="$4"

	printf "%-20s %-10s %s\n" "$column_header" 'Enabled?' 'Description'
	for f in "${BASH_IT?}/$subdirectory/available"/*.*.bash; do
		enabled=''
		enabled_file="${f##*/}"
		enabled_file="${enabled_file%."${file_type}"*.bash}"
		_bash-it-component-item-is-enabled "${file_type}" "${enabled_file}" && enabled='x'
		printf "%-20s %-10s %s\n" "$enabled_file" "[${enabled:- }]" "$(metafor "about-$file_type" < "$f")"
	done
	printf '\n%s\n' "to enable $preposition $file_type, do:"
	printf '%s\n' "$ bash-it enable $file_type  <$file_type name> [$file_type name]... -or- $ bash-it enable $file_type all"
	printf '\n%s\n' "to disable $preposition $file_type, do:"
	printf '%s\n' "$ bash-it disable $file_type <$file_type name> [$file_type name]... -or- $ bash-it disable $file_type all"
}

function _on-disable-callback() {
	_about 'Calls the disabled plugin destructor, if present'
	_param '1: plugin name'
	_example '$ _on-disable-callback gitstatus'
	_group 'lib'

	local callback="${1}_on_disable"
	if _command_exists "$callback"; then
		"$callback"
	fi
}

function _disable-all() {
	_about 'disables all bash_it components'
	_example '$ _disable-all'
	_group 'lib'

	_disable-plugin "all"
	_disable-alias "all"
	_disable-completion "all"
}

function _disable-plugin() {
	_about 'disables bash_it plugin'
	_param '1: plugin name'
	_example '$ disable-plugin rvm'
	_group 'lib'

	_disable-thing "plugins" "plugin" "${1?}"
	_on-disable-callback "${1?}"
}

function _disable-alias() {
	_about 'disables bash_it alias'
	_param '1: alias name'
	_example '$ disable-alias git'
	_group 'lib'

	_disable-thing "aliases" "alias" "${1?}"
}

function _disable-completion() {
	_about 'disables bash_it completion'
	_param '1: completion name'
	_example '$ disable-completion git'
	_group 'lib'

	_disable-thing "completion" "completion" "${1?}"
}

function _disable-thing() {
	_about 'disables a bash_it component'
	_param '1: subdirectory'
	_param '2: file_type'
	_param '3: file_entity'
	_example '$ _disable-thing "plugins" "plugin" "ssh"'

	local subdirectory="${1?}"
	local file_type="${2?}"
	local file_entity="${3:-}"

	if [[ -z "$file_entity" ]]; then
		reference "disable-$file_type"
		return
	fi

	local f suffix _bash_it_config_file plugin
	suffix="${subdirectory/plugins/plugin}"

	if [[ "$file_entity" == "all" ]]; then
		# Disable everything that's using the old structure and everything in the global "enabled" directory.
		for _bash_it_config_file in "${BASH_IT}/$subdirectory/enabled"/*."${suffix}.bash" "${BASH_IT}/enabled"/*".${suffix}.bash"; do
			rm -f "$_bash_it_config_file"
		done
	else
		# Use a glob to search for both possible patterns
		# 250---node.plugin.bash
		# node.plugin.bash
		# Either one will be matched by this glob
		for plugin in "${BASH_IT}/enabled"/[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR}${file_entity}.${suffix}.bash" "${BASH_IT}/$subdirectory/enabled/"{[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR}${file_entity}.${suffix}.bash","${file_entity}.${suffix}.bash"}; do
			if [[ -e "${plugin}" ]]; then
				rm -f "${plugin}"
				plugin=
				break
			fi
		done
		if [[ -n "${plugin}" ]]; then
			printf '%s\n' "sorry, $file_entity does not appear to be an enabled $file_type."
			return
		fi
	fi

	_bash-it-component-cache-clean "${file_type}"

	if [[ "$file_entity" == "all" ]]; then
		_bash-it-component-pluralize "$file_type" file_type
		printf '%s\n' "$file_entity ${file_type} disabled."
	else
		printf '%s\n' "$file_entity disabled."
	fi
}

function _enable-plugin() {
	_about 'enables bash_it plugin'
	_param '1: plugin name'
	_example '$ enable-plugin rvm'
	_group 'lib'

	_enable-thing "plugins" "plugin" "${1?}" "$BASH_IT_LOAD_PRIORITY_PLUGIN"
}

function _enable-plugins() {
	_about 'alias of _enable-plugin'
	_enable-plugin "$@"
}

function _enable-alias() {
	_about 'enables bash_it alias'
	_param '1: alias name'
	_example '$ enable-alias git'
	_group 'lib'

	_enable-thing "aliases" "alias" "${1?}" "$BASH_IT_LOAD_PRIORITY_ALIAS"
}

function _enable-aliases() {
	_about 'alias of _enable-alias'
	_enable-alias "$@"
}

function _enable-completion() {
	_about 'enables bash_it completion'
	_param '1: completion name'
	_example '$ enable-completion git'
	_group 'lib'

	_enable-thing "completion" "completion" "${1?}" "$BASH_IT_LOAD_PRIORITY_COMPLETION"
}

function _enable-thing() {
	cite _about _param _example
	_about 'enables a bash_it component'
	_param '1: subdirectory'
	_param '2: file_type'
	_param '3: file_entity'
	_param '4: load priority'
	_example '$ _enable-thing "plugins" "plugin" "ssh" "150"'

	local subdirectory="${1?}"
	local file_type="${2?}"
	local file_entity="${3:-}"
	local load_priority="${4:-500}"

	if [[ -z "$file_entity" ]]; then
		reference "enable-$file_type"
		return
	fi

	local _bash_it_config_file to_enable to_enables enabled_plugin local_file_priority use_load_priority
	local suffix="${subdirectory/plugins/plugin}"

	if [[ "$file_entity" == "all" ]]; then
		for _bash_it_config_file in "${BASH_IT}/$subdirectory/available"/*.bash; do
			to_enable="${_bash_it_config_file##*/}"
			_enable-thing "$subdirectory" "$file_type" "${to_enable%."${file_type/alias/aliases}".bash}" "$load_priority"
		done
	else
		to_enables=("${BASH_IT}/$subdirectory/available/$file_entity.${suffix}.bash")
		if [[ ! -e "${to_enables[0]}" ]]; then
			printf '%s\n' "sorry, $file_entity does not appear to be an available $file_type."
			return
		fi

		to_enable="${to_enables[0]##*/}"
		# Check for existence of the file using a wildcard, since we don't know which priority might have been used when enabling it.
		for enabled_plugin in "${BASH_IT}/$subdirectory/enabled"/{[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR}${to_enable}","${to_enable}"} "${BASH_IT}/enabled"/[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}${to_enable}"; do
			if [[ -e "${enabled_plugin}" ]]; then
				printf '%s\n' "$file_entity is already enabled."
				return
			fi
		done

		mkdir -p "${BASH_IT}/enabled"

		# Load the priority from the file if it present there
		local_file_priority="$(awk -F': ' '$1 == "# BASH_IT_LOAD_PRIORITY" { print $2 }' "${BASH_IT}/$subdirectory/available/$to_enable")"
		use_load_priority="${local_file_priority:-$load_priority}"

		ln -s "../$subdirectory/available/$to_enable" "${BASH_IT}/enabled/${use_load_priority}${BASH_IT_LOAD_PRIORITY_SEPARATOR}${to_enable}"
	fi

	_bash-it-component-cache-clean "${file_type}"

	printf '%s\n' "$file_entity enabled with priority $use_load_priority."
}

function _help-completions() {
	_about 'summarize all completions available in bash-it'
	_group 'lib'

	_bash-it-completions
}

function _help-aliases() {
	_about 'shows help for all aliases, or a specific alias group'
	_param '1: optional alias group'
	_example '$ alias-help'
	_example '$ alias-help git'

	if [[ -n "${1:-}" ]]; then
		case "$1" in
			custom)
				alias_path='custom.aliases.bash'
				;;
			*)
				alias_path="available/${1}.aliases.bash"
				;;
		esac
		metafor alias < "${BASH_IT}/aliases/$alias_path" | sed "s/$/'/"
	else
		local f

		for f in "${BASH_IT}/aliases/enabled"/* "${BASH_IT}/enabled"/*."aliases.bash"; do
			[[ -f "$f" ]] || continue
			_help-list-aliases "$f"
		done

		if [[ -e "${BASH_IT}/aliases/custom.aliases.bash" ]]; then
			_help-list-aliases "${BASH_IT}/aliases/custom.aliases.bash"
		fi
	fi
}

function _help-list-aliases() {
	local file
	file="$(_bash-it-get-component-name-from-path "${1?}")"
	printf '\n\n%s:\n' "${file}"
	# metafor() strips trailing quotes, restore them with sed..
	metafor alias < "$1" | sed "s/$/'/"
}

function _help-plugins() {
	_about 'summarize all functions defined by enabled bash-it plugins'
	_group 'lib'

	local grouplist func group about gfile defn
	# display a brief progress message...
	printf '%s' 'please wait, building help...'
	grouplist="$(mktemp -t grouplist.XXXXXX)"
	while read -ra func; do
		defn="$(declare -f "${func[2]}")"
		group="$(metafor group <<< "$defn")"
		if [[ -z "$group" ]]; then
			group='misc'
		fi
		about="$(metafor about <<< "$defn")"
		_letterpress "$about" "${func[2]}" >> "$grouplist.$group"
		echo "$grouplist.$group" >> "$grouplist"
	done < <(declare -F)
	# clear progress message
	printf '\r%s\n' '                              '
	while IFS= read -r gfile; do
		printf '%s\n' "${gfile##*.}:"
		cat "$gfile"
		printf '\n'
		rm "$gfile" 2> /dev/null
	done < <(sort -u "$grouplist") | less
	rm "$grouplist" 2> /dev/null
}

function _help-profile() {
	_about 'help message for profile command'
	_group 'lib'

	echo "Manages profiles of bash it."
	echo "Use 'bash-it profile list' to see all available profiles."
	echo "Use 'bash-it profile save foo' to save the current configuration into a profile named 'foo'."
	echo "Use 'bash-it profile load foo' to load an existing profile named 'foo'."
	echo "Use 'bash-it profile rm foo' to remove an existing profile named 'foo'."
}

function _help-update() {
	_about 'help message for update command'
	_group 'lib'

	echo "Check for a new version of Bash-it and update it."
}

function _help-migrate() {
	_about 'help message for migrate command'
	_group 'lib'

	echo "Migrates internal Bash-it structure to the latest version in case of changes."
	echo "The 'migrate' command is run automatically when calling 'update', 'enable' or 'disable'."
}

function all_groups() {
	about 'displays all unique metadata groups'
	group 'lib'

	declare -f | metafor group | sort -u
}

function pathmunge() {
	about 'prevent duplicate directories in your PATH variable'
	group 'helpers'
	example 'pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH'
	example 'pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir'

	if [[ -d "${1:-}" && ! $PATH =~ (^|:)"${1}"($|:) ]]; then
		if [[ "${2:-before}" == "after" ]]; then
			export PATH="$PATH:${1}"
		else
			export PATH="${1}:$PATH"
		fi
	fi
}

# `_bash-it-find-in-ancestor` uses the shell's ability to run a function in
# a subshell to simplify our search to a simple `cd ..` and `[[ -r $1 ]]`
# without any external dependencies. Let the shell do what it's good at.
function _bash-it-find-in-ancestor() (
	: _about 'searches parents of the current directory for any of the specified file names'
	: _group 'helpers'
	: _param '*: names of files or folders to search for'
	: _returns '0: prints path of closest matching ancestor directory to stdout'
	: _returns '1: no match found'
	: _returns '2: improper usage of shell builtin' # uncommon
	: _example '_bash-it-find-in-ancestor .git .hg'
	: _example '_bash-it-find-in-ancestor GNUmakefile Makefile makefile'

	local kin
	# To keep things simple, we do not search the root dir.
	while [[ "${PWD}" != '/' ]]; do
		for kin in "$@"; do
			if [[ -r "${PWD}/${kin}" ]]; then
				printf '%s' "${PWD}"
				return "$?"
			fi
		done
		command cd .. || return "$?"
	done
	return 1
)

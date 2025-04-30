# shellcheck shell=bash
# shellcheck disable=SC2207
# bash completion for the `bundle` command.
#
# Copyright (c) 2008 Daniel Luz

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# To use, source this file on bash:
#   . completion-bundle

__bundle() {
	local bundle_bin=("${_RUBY_COMMAND_PREFIX[@]}" "$1")
	local cur prev
	_get_comp_words_by_ref -n : cur prev
	local bundle_command
	local bundle_command_index
	__bundle_get_command
	COMPREPLY=()

	local options
	if [[ $cur = -* && $bundle_command != exec ]]; then
		options="-V --help --no-color --no-no-color --verbose --no-verbose"
		case $bundle_command in
			"")
				options="$options --version"
				;;
			check)
				options="$options --dry-run --gemfile --path -r --retry"
				;;
			clean)
				options="$options --dry-run --force"
				;;
			config)
				options="$options --local --global --delete"
				;;
			doctor)
				options="$options --gemfile --quiet --no-quiet"
				;;
			gem)
				options="$options -b -e -t --bin --coc --no-coc --edit --exe
                     --no-exe --ext --no-ext --mit --no-mit --test"
				;;
			init)
				options="$options --gemspec"
				;;
			install)
				options="$options --binstubs --clean --deployment --force --frozen
                     --full-index --gemfile --jobs --local --no-cache
                     --no-prune --path --quiet --retry --shebang --standalone
                     --system --trust-policy --with --without"
				;;
			lock)
				options="$options --add-platform --conservative --full-index
                     --local --lockfile --major --minor --patch --print
                     --remove-platform --strict --update"
				;;
			package)
				options="$options --all --all-platforms"
				;;
			platform)
				options="$options --ruby"
				;;
			show)
				options="$options --outdated --paths --no-paths"
				;;
			update)
				options="$options --bundler --conservative --force --full-index
                     --group --jobs --local --major --minor --patch --quiet
                     --ruby --source --strict"
				;;
			viz)
				options="$options -f -F -R -v -W --file --format --requirements
                     --no-requirements --version --no-version --without"
				;;
		esac
	else
		case $bundle_command in
			"" | help)
				options="help install update package exec config
                     check show outdated console open lock viz init gem
                     platform clean doctor"
				;;
			check | install)
				case $prev in
					--binstubs | --path)
						_filedir -d
						return
						;;
					--standalone | --with | --without)
						__bundle_complete_groups
						return
						;;
					--trust-policy)
						options="HighSecurity MediumSecurity LowSecurity
                         AlmostNoSecurity NoSecurity"
						;;
				esac
				;;
			config)
				case $prev in
					config | --*)
						case $cur in
							local.*)
								options=($(__bundle_exec_ruby 'puts Bundler.definition.specs.to_hash.keys'))
								options=("${options[*]/#/local.}")
								;;
							*)
								options=(path frozen without bin gemfile ssl_ca_cert
									ssl_client_cert cache_path disable_multisource
									ignore_messages retry redirect timeout
									force_ruby_platform specific_platform
									disable_checksum_validation disable_version_check
									allow_offline_install auto_install
									cache_all_platforms cache_all clean console
									disable_exec_load disable_local_branch_check
									disable_shared_gems jobs major_deprecations
									no_install no_prune only_update_to_newer_versions
									plugins shebang silence_root_warning
									ssl_verify_mode system_bindir user_agent)
								# We want to suggest the options above as complete words,
								# and also "local." and "mirror." as prefixes
								# To achieve that, disable automatic space insertion,
								# insert it manually, then add the non-spaced prefixes
								compopt -o nospace
								options=("${options[@]/%/ }")
								# And add prefix suggestions
								options+=(local. mirror.)
								# Override $IFS for completion to work
								local IFS=$'\n'
								# shellcheck disable=SC2016
								COMPREPLY=($(compgen -W '${options[@]}' -- "$cur"))
								return
								;;
						esac
						;;
					path | local.*)
						_filedir -d
						return
						;;
				esac
				;;
			exec)
				if [[ $COMP_CWORD -eq $bundle_command_index ]]; then
					# Figure out Bundler's binaries dir
					local bundler_bin
					bundler_bin=$(__bundle_exec_ruby 'puts Bundler.bundle_path + "bin"')
					if [[ -d $bundler_bin ]]; then
						local binaries
						binaries=("$bundler_bin"/*)
						# If there are binaries, strip directory name and use them
						[[ -f "${binaries[0]}" ]] && options=("${binaries[@]##*/}")
					else
						# No binaries found; use full command completion
						COMPREPLY=($(compgen -c -- "$cur"))
						return
					fi
				else
					local _RUBY_COMMAND_PREFIX=("${bundle_bin[@]}" exec)
					_command_offset "$bundle_command_index"
					return
				fi
				;;
			gem)
				case $prev in
					-e | --edit)
						COMPREPLY=($(compgen -c -- "$cur"))
						return
						;;
					-t | --test)
						options=("minitest" "rspec")
						;;
				esac
				;;
			update)
				case $prev in
					--group)
						__bundle_complete_groups
						return
						;;
					*)
						options=($(__bundle_exec_ruby 'puts Bundler.definition.specs.to_hash.keys'))
						;;
				esac
				;;
			viz)
				case $prev in
					-F | --format)
						options=("dot" "jpg" "png" "svg")
						;;
					-W | --without)
						__bundle_complete_groups
						return
						;;
				esac
				;;
		esac
	fi
	COMPREPLY=($(compgen -W "${options[*]}" -- "$cur"))
}

__bundle_get_command() {
	local i
	for ((i = 1; i < COMP_CWORD; ++i)); do
		local arg=${COMP_WORDS[$i]}

		case $arg in
			[^-]*)
				bundle_command=$arg
				bundle_command_index=$((i + 1))
				return
				;;
			--version)
				# Command-killer
				bundle_command=-
				return
				;;
			--help)
				bundle_command=help
				bundle_command_index=$((i + 1))
				return
				;;
		esac
	done
}

# Provides completion for Bundler group names.
#
# Multiple groups can be entered, separated either by spaces or by colons.
# Input is read from $cur, and the result is directly written to $COMPREPLY.
__bundle_complete_groups() {
	# Group being currently written
	local cur_group=${cur##*[ :]}
	# All groups written before
	local prefix=${cur%"$cur_group"}
	local groups
	groups=$(__bundle_exec_ruby 'puts Bundler.definition.dependencies.map(&:groups).reduce(:|).map(&:to_s)')
	if [[ ! $groups ]]; then
		COMPREPLY=()
		return
	fi
	# Duplicate "default" and anything already in $prefix, so that `uniq`
	# strips it; groups may be separated by ':', ' ', or '\ '
	local excluded=$'\ndefault\n'${prefix//[: \'\"\\]/$'\n'}
	# Include them twice to ensure they are duplicates
	groups=$groups$excluded$excluded
	COMPREPLY=($(compgen -W "$(sort <<< "$groups" | uniq -u)" -- "$cur_group"))
	# Prepend prefix to all entries
	COMPREPLY=("${COMPREPLY[@]/#/$prefix}")
	__ltrim_colon_completions "$cur"
}

# __bundle_exec_ruby <script> [args...]
#
# Runs a Ruby script with Bundler loaded.
# Results may be cached.
__bundle_exec_ruby() {
	local bundle_bin=("${bundle_bin[@]:-bundle}")
	# Lockfile is inferred here, and might not be correct (for example, when
	# running on a subdirectory). However, a wrong file path won't be a
	# cadastrophic mistake; it just means the cache won't be invalidated when
	# the local gem list changes (but will still invalidate if the command is
	# run on another directory)
	local lockfile=$PWD/Gemfile.lock
	local cachedir=${XDG_CACHE_HOME:-~/.cache}/completion-ruby
	local cachefile=$cachedir/bundle--exec-ruby
	# A representation of all arguments with newlines replaced by spaces,
	# to fit in a single line as a cache identifier
	local cache_id_line="${bundle_bin[*]} @ $lockfile: ${*//$'\n'/ }"

	if [[ (! -f $lockfile || $cachefile -nt $lockfile) &&
		$(head -n 1 -- "$cachefile" 2> /dev/null) = "$cache_id_line" ]]; then
		tail -n +2 -- "$cachefile"
	else
		local output
		if output=$("${bundle_bin[@]}" exec ruby -e "$@" 2> /dev/null); then
			(mkdir -p -- "$cachedir" \
				&& echo "$cache_id_line"$'\n'"$output" > "$cachefile") 2> /dev/null
			echo "$output"
		fi
	fi
}

complete -F __bundle -o bashdefault -o default bundle
# vim: ai ft=sh sw=4 sts=4 et

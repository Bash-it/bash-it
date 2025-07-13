# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors"
}

function local_setup() {
	# Copy the test fixture to the Bash-it folder
	cp -RP "${BASH_IT?}/test/fixtures/bash_it"/* "${BASH_IT?}/"
}

# TODO Create global __is_enabled function
# TODO Create global __get_base_name function
# TODO Create global __get_enabled_name function
@test "bash-it: verify that the test fixture is available" {
	assert_file_exist "${BASH_IT?}/profiles/test-bad-component.bash_it"
	assert_file_exist "${BASH_IT?}/profiles/test-bad-type.bash_it"
}

@test "helpers: bash-it help aliases ag" {
	run bash-it help aliases "ag"
	assert_line -n 0 "ag='ag --smart-case --pager=\"less -MIRFX'"
}

@test "helpers: bash-it help aliases without any aliases enabled" {
	run bash-it help aliases
	assert_output ""
}

@test "helpers: bash-it help plugins" {
	run bash-it help plugins
	assert_line -n 1 "composure:"
}

@test "helpers: bash-it help list aliases without any aliases enabled" {
	run _help-list-aliases "${BASH_IT?}/aliases/available/ag.aliases.bash"
	assert_line -n 0 "ag:"
}

@test "helpers: bash-it help list aliases with ag aliases enabled" {
	ln -s "${BASH_IT?}/aliases/available/ag.aliases.bash" "${BASH_IT?}/aliases/enabled/150---ag.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---ag.aliases.bash"

	run _help-list-aliases "${BASH_IT?}/aliases/enabled/150---ag.aliases.bash"
	assert_line -n 0 "ag:"
}

@test "helpers: bash-it help list aliases with todo.txt-cli aliases enabled" {
	ln -s "${BASH_IT?}/aliases/available/todo.txt-cli.aliases.bash" "${BASH_IT?}/aliases/enabled/150---todo.txt-cli.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---todo.txt-cli.aliases.bash"

	run _help-list-aliases "${BASH_IT?}/aliases/enabled/150---todo.txt-cli.aliases.bash"
	assert_line -n 0 "todo.txt-cli:"
}

@test "helpers: bash-it help list aliases with docker-compose aliases enabled" {
	ln -s "${BASH_IT?}/aliases/available/docker-compose.aliases.bash" "${BASH_IT?}/aliases/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---docker-compose.aliases.bash"

	run _help-list-aliases "${BASH_IT?}/aliases/enabled/150---docker-compose.aliases.bash"
	assert_line -n 0 "docker-compose:"
}

@test "helpers: bash-it help list aliases with ag aliases enabled in global directory" {
	ln -s "${BASH_IT?}/aliases/available/ag.aliases.bash" "${BASH_IT?}/enabled/150---ag.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run _help-list-aliases "${BASH_IT?}/enabled/150---ag.aliases.bash"
	assert_line -n 0 "ag:"
}

@test "helpers: bash-it help aliases one alias enabled in the old directory" {
	ln -s "${BASH_IT?}/aliases/available/ag.aliases.bash" "${BASH_IT?}/aliases/enabled/150---ag.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---ag.aliases.bash"

	run bash-it help aliases
	assert_line -n 0 "ag:"
}

@test "helpers: bash-it help aliases one alias enabled in global directory" {
	run bash-it enable alias "ag"
	assert_line -n 0 'ag enabled with priority 150.'
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run bash-it enable plugin "aws"
	assert_line -n 0 'aws enabled with priority 250.'
	assert_link_exist "${BASH_IT?}/enabled/250---aws.plugin.bash"

	run bash-it help aliases
	assert_line -n 0 "ag:"
	assert_line -n 1 "ag='ag --smart-case --pager=\"less -MIRFX'"
}

@test "helpers: enable the todo.txt-cli aliases through the bash-it function" {
	run bash-it enable alias "todo.txt-cli"
	assert_line -n 0 'todo.txt-cli enabled with priority 150.'
	assert_link_exist "${BASH_IT?}/enabled/150---todo.txt-cli.aliases.bash"
}

@test "helpers: enable the curl aliases" {
	run _enable-alias "curl"
	assert_line -n 0 'curl enabled with priority 150.'
	assert_link_exist "${BASH_IT?}/enabled/150---curl.aliases.bash"
}

@test "helpers: enable the apm completion through the bash-it function" {
	run bash-it enable completion "apm"
	assert_line -n 0 'apm enabled with priority 350.'
	assert_link_exist "${BASH_IT?}/enabled/350---apm.completion.bash"
}

@test "helpers: enable the brew completion" {
	run _enable-completion "brew"
	assert_line -n 0 'brew enabled with priority 375.'
	assert_link_exist "${BASH_IT?}/enabled/375---brew.completion.bash"
}

@test "helpers: enable the node plugin" {
	run _enable-plugin "node"
	assert_line -n 0 'node enabled with priority 250.'
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash" "../plugins/available/node.plugin.bash"
}

@test "helpers: enable the node plugin through the bash-it function" {
	run bash-it enable plugin "node"
	assert_line -n 0 'node enabled with priority 250.'
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash"
}

@test "helpers: enable the node and nvm plugins through the bash-it function" {
	run bash-it enable plugin "node" "nvm"
	assert_line -n 0 'node enabled with priority 250.'
	assert_line -n 1 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
}

@test "helpers: enable the foo-unkown and nvm plugins through the bash-it function" {
	run bash-it enable plugin "foo-unknown" "nvm"
	assert_line -n 0 'sorry, foo-unknown does not appear to be an available plugin.'
	assert_line -n 1 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
}

@test "helpers: enable the nvm plugin" {
	run _enable-plugin "nvm"
	assert_line -n 0 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
}

@test "helpers: enable an unknown plugin" {
	run _enable-plugin "unknown-foo"
	assert_line -n 0 'sorry, unknown-foo does not appear to be an available plugin.'

	# Check for both old an new structure
	assert [ ! -L "${BASH_IT?}/plugins/enabled/250---unknown-foo.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/plugins/enabled/unknown-foo.plugin.bash" ]

	assert [ ! -L "${BASH_IT?}/enabled/250---unknown-foo.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/enabled/unknown-foo.plugin.bash" ]
}

@test "helpers: enable an unknown plugin through the bash-it function" {
	run bash-it enable plugin "unknown-foo"
	echo "${lines[@]}"
	assert_line -n 0 'sorry, unknown-foo does not appear to be an available plugin.'

	# Check for both old an new structure
	assert [ ! -L "${BASH_IT?}/plugins/enabled/250---unknown-foo.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/plugins/enabled/unknown-foo.plugin.bash" ]

	assert [ ! -L "${BASH_IT?}/enabled/250---unknown-foo.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/enabled/unknown-foo.plugin.bash" ]
}

@test "helpers: disable a plugin that is not enabled" {
	run _disable-plugin "sdkman"
	assert_line -n 0 'sorry, sdkman does not appear to be an enabled plugin.'
}

@test "helpers: enable and disable the nvm plugin" {
	run _enable-plugin "nvm"
	assert_line -n 0 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
	assert [ ! -L "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash" ]

	run _disable-plugin "nvm"
	assert_line -n 0 'nvm disabled.'
	assert [ ! -L "${BASH_IT?}/enabled/225---nvm.plugin.bash" ]
}

@test "helpers: disable the nvm plugin if it was enabled with a priority, but in the component-specific directory" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert [ ! -L "${BASH_IT?}/enabled/225---nvm.plugin.bash" ]

	run _disable-plugin "nvm"
	assert_line -n 0 'nvm disabled.'
	assert [ ! -L "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/enabled/225---nvm.plugin.bash" ]
}

@test "helpers: disable the nvm plugin if it was enabled without a priority" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	run _disable-plugin "nvm"
	assert_line -n 0 'nvm disabled.'
	assert [ ! -L "${BASH_IT?}/plugins/enabled/nvm.plugin.bash" ]
}

@test "helpers: enable the nvm plugin if it was enabled without a priority" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	run _enable-plugin "nvm"
	assert_line -n 0 'nvm is already enabled.'
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert [ ! -L "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/enabled/225---nvm.plugin.bash" ]
}

@test "helpers: enable the nvm plugin if it was enabled with a priority, but in the component-specific directory" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"

	run _enable-plugin "nvm"
	assert_line -n 0 'nvm is already enabled.'
	assert [ ! -L "${BASH_IT?}/plugins/enabled/nvm.plugin.bash" ]
	assert_link_exist "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert [ ! -L "${BASH_IT?}/enabled/225---nvm.plugin.bash" ]
}

@test "helpers: enable the nvm plugin twice" {
	run _enable-plugin "nvm"
	assert_line -n 0 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"

	run _enable-plugin "nvm"
	assert_line -n 0 'nvm is already enabled.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
}

@test "helpers: profile load command sanity" {
	run _bash-it-profile-load "default"
	assert_success

	assert_link_exist "${BASH_IT?}/enabled/150---general.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/800---aliases.completion.bash"
	assert_link_exist "${BASH_IT?}/enabled/350---bash-it.completion.bash"
	assert_link_exist "${BASH_IT?}/enabled/325---system.completion.bash"
}

@test "helpers: profile save command sanity" {
	run _enable-plugin "nvm"

	run _bash-it-profile-save "test"
	assert_line -n 0 "Saving plugins configuration..."
	assert_line -n 1 "Saving completion configuration..."
	assert_line -n 2 "Saving aliases configuration..."
	assert_line -n 3 "All done!"
	assert_file_exist "${BASH_IT?}/profiles/test.bash_it"
}

@test "helpers: profile save creates valid file with only plugin enabled" {
	run _enable-plugin "nvm"

	run _bash-it-profile-save "test"
	run cat "${BASH_IT?}/profiles/test.bash_it"
	assert_line -n 0 "# This file is auto generated by Bash-it. Do not edit manually!"
	assert_line -n 1 "# plugins"
	assert_line -n 2 "plugins nvm"
}

@test "helpers: profile save creates valid file with only completion enabled" {
	run _enable-completion "bash-it"

	run _bash-it-profile-save "test"
	run cat "${BASH_IT?}/profiles/test.bash_it"
	assert_line -n 0 "# This file is auto generated by Bash-it. Do not edit manually!"
	assert_line -n 1 "# completion"
	assert_line -n 2 "completion bash-it"
}

@test "helpers: profile save creates valid file with only aliases enabled" {
	run _enable-alias "general"

	run _bash-it-profile-save "test"
	run cat "${BASH_IT?}/profiles/test.bash_it"
	assert_line -n 0 "# This file is auto generated by Bash-it. Do not edit manually!"
	assert_line -n 1 "# aliases"
	assert_line -n 2 "aliases general"
}

@test "helpers: profile edge case, empty configuration" {
	run _bash-it-profile-save "test"
	assert_success
	assert_line -n 3 "It seems like no configuration was enabled.."
	assert_line -n 4 "Make sure to double check that this is the wanted behavior."

	run _enable-alias "general"
	assert_success
	run _enable-plugin "base"
	assert_success
	run _enable-completion "aliases"
	assert_success
	run _enable-completion "bash-it"
	assert_success
	run _enable-completion "system"
	assert_success

	run _bash-it-profile-load "test"
	assert_success
	assert_line -n 0 "Trying to parse profile 'test'..."
	assert_link_not_exist "${BASH_IT?}/enabled/150---general.aliases.bash"
	assert_link_not_exist "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_not_exist "${BASH_IT?}/enabled/800---aliases.completion.bash"
	assert_link_not_exist "${BASH_IT?}/enabled/350---bash-it.completion.bash"
	assert_link_not_exist "${BASH_IT?}/enabled/325---system.completion.bash"
}

@test "helpers: profile save and load" {
	run _enable-alias "general"
	assert_success
	run _enable-plugin "base"
	assert_success
	run _enable-plugin "alias-completion"
	assert_success
	run _enable-completion "bash-it"
	assert_success
	run _enable-completion "system"
	assert_success

	run _bash-it-profile-save "test"
	assert_success

	run _disable-alias "general"
	assert_success
	assert_output "general disabled."
	assert_link_not_exist "${BASH_IT?}/enabled/150---general.aliases.bash"
	run _bash-it-profile-load "test"
	assert_success
	assert_link_exist "${BASH_IT?}/enabled/150---general.aliases.bash"
}

@test "helpers: profile load corrupted profile file: bad component" {
	run _bash-it-profile-load "test-bad-component"
	assert_line -n 1 -p "Bad line(#12) in profile, aborting load..."
}

@test "helpers: profile load corrupted profile file: bad subdirectory" {
	run _bash-it-profile-load "test-bad-type"
	assert_line -n 1 -p "Bad line(#4) in profile, aborting load..."
}

@test "helpers: profile rm sanity" {
	run _bash-it-profile-save "test"
	assert_file_exist "${BASH_IT?}/profiles/test.bash_it"
	run _bash-it-profile-rm "test"
	assert_line -n 0 "Removed profile 'test' successfully!"
	assert_file_not_exist "${BASH_IT?}/profiles/test.bash_it"
}

@test "helpers: profile rm no params" {
	run _bash-it-profile-rm ""
	assert_line -n 0 -p "Please specify profile name to remove..."
}

@test "helpers: profile load no params" {
	run _bash-it-profile-load ""
	assert_line -n 0 -p "Please specify profile name to load, not changing configuration..."
}

@test "helpers: profile rm default" {
	run _bash-it-profile-rm "default"
	assert_line -n 0 -p "Can not remove the default profile..."
	assert_file_exist "${BASH_IT?}/profiles/default.bash_it"
}

@test "helpers: profile rm bad profile name" {
	run _bash-it-profile-rm "notexisting"
	assert_line -n 0 -p "Could not find profile 'notexisting'..."
}

@test "helpers: profile list sanity" {
	run _bash-it-profile-list
	assert_line -n 0 "Available profiles:"
	assert_line -n 1 "default"
}

@test "helpers: profile list more profiles" {
	run _bash-it-profile-save "cactus"
	run _bash-it-profile-save "another"
	run _bash-it-profile-save "brother"
	run _bash-it-profile-list
	assert_line -n 0 "Available profiles:"
	assert_line -n 4 "default"
	assert_line -n 3 "cactus"
	assert_line -n 1 "another"
	assert_line -n 2 "brother"
}

@test "helpers: migrate plugins and completions that share the same name" {
	ln -s "${BASH_IT?}/completion/available/dirs.completion.bash" "${BASH_IT?}/completion/enabled/350---dirs.completion.bash"
	assert_link_exist "${BASH_IT?}/completion/enabled/350---dirs.completion.bash"

	ln -s "${BASH_IT?}/plugins/available/dirs.plugin.bash" "${BASH_IT?}/plugins/enabled/250---dirs.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---dirs.plugin.bash"

	run _bash-it-migrate
	assert_line -n 0 'Migrating plugin dirs.'
	assert_line -n 1 'dirs disabled.'
	assert_line -n 2 'dirs enabled with priority 250.'
	assert_line -n 3 'Migrating completion dirs.'
	assert_line -n 4 'dirs disabled.'
	assert_line -n 5 'dirs enabled with priority 350.'
	assert_line -n 6 'If any migration errors were reported, please try the following: reload && bash-it migrate'

	assert_link_exist "${BASH_IT?}/enabled/350---dirs.completion.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---dirs.plugin.bash"
	assert [ ! -L "${BASH_IT?}/completion/enabled/350----dirs.completion.bash" ]
	assert [ ! -L "${BASH_IT?}/plugins/enabled/250----dirs.plugin.bash" ]
}

@test "helpers: migrate enabled plugins that don't use the new priority-based configuration" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	ln -s "${BASH_IT?}/plugins/available/node.plugin.bash" "${BASH_IT?}/plugins/enabled/node.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/node.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/todo.txt-cli.aliases.bash" "${BASH_IT?}/aliases/enabled/todo.txt-cli.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/todo.txt-cli.aliases.bash"

	run _enable-plugin "ssh"
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"

	run _bash-it-migrate
	assert_line -n 0 'Migrating alias todo.txt-cli.'
	assert_line -n 1 'todo.txt-cli disabled.'
	assert_line -n 2 'todo.txt-cli enabled with priority 150.'

	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---todo.txt-cli.aliases.bash"
	assert [ ! -L "${BASH_IT?}/plugins/enabled/node.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/plugins/enabled/nvm.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/aliases/enabled/todo.txt-cli.aliases.bash" ]
}

@test "helpers: migrate enabled plugins that use the new priority-based configuration in the individual directories" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"

	ln -s "${BASH_IT?}/plugins/available/node.plugin.bash" "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/todo.txt-cli.aliases.bash" "${BASH_IT?}/aliases/enabled/250---todo.txt-cli.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/250---todo.txt-cli.aliases.bash"

	run _enable-plugin "ssh"
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"

	run _bash-it-migrate
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---todo.txt-cli.aliases.bash"
	assert [ ! -L "${BASH_IT?}/plugins/enabled/225----node.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/plugins/enabled/250----nvm.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/aliases/enabled/250----todo.txt-cli.aliases.bash" ]
}

@test "helpers: run the migrate command without anything to migrate and nothing enabled" {
	run _bash-it-migrate
}

@test "helpers: run the migrate command without anything to migrate" {
	run _enable-plugin "ssh"
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"

	run _bash-it-migrate
	assert_link_exist "${BASH_IT?}/enabled/250---ssh.plugin.bash"
}

function __migrate_all_components() {
	subdirectory="${1:-}"
	one_type="${2:-}"
	priority="${3:-}"

	for f in "${BASH_IT}/$subdirectory/available/"*.bash; do
		to_enable=$(basename "$f")
		if [[ -z "$priority" ]]; then
			ln -s "../available/$to_enable" "${BASH_IT}/${subdirectory}/enabled/$to_enable"
		else
			ln -s "../available/$to_enable" "${BASH_IT}/${subdirectory}/enabled/$priority---$to_enable"
		fi
	done

	ls "${BASH_IT?}/${subdirectory}/enabled"

	all_available=$(compgen -G "${BASH_IT}/${subdirectory}/available/*.$one_type.bash" | wc -l | xargs)
	all_enabled_old=$(compgen -G "${BASH_IT}/${subdirectory}/enabled/*.$one_type.bash" | wc -l | xargs)

	assert_equal "$all_available" "$all_enabled_old"

	run bash-it migrate

	all_enabled_old_after=$(compgen -G "${BASH_IT}/${subdirectory}/enabled/*.$one_type.bash" | wc -l | xargs)
	assert_equal "0" "$all_enabled_old_after"

	all_enabled_new_after=$(compgen -G "${BASH_IT}/enabled/*.$one_type.bash" | wc -l | xargs)
	assert_equal "$all_enabled_old" "$all_enabled_new_after"
}

@test "helpers: migrate all plugins" {
	subdirectory="plugins"
	one_type="plugin"

	run __migrate_all_components "$subdirectory" "$one_type"
	assert_success
}

@test "helpers: migrate all aliases" {
	subdirectory="aliases"
	one_type="aliases"

	run __migrate_all_components "$subdirectory" "$one_type"
	assert_success
}

@test "helpers: migrate all completions" {
	subdirectory="completion"
	one_type="completion"

	run __migrate_all_components "$subdirectory" "$one_type"
	assert_success
}

@test "helpers: migrate all plugins with previous priority" {
	subdirectory="plugins"
	one_type="plugin"

	run __migrate_all_components "$subdirectory" "$one_type" "100"
	assert_success
}

@test "helpers: migrate all aliases with previous priority" {
	subdirectory="aliases"
	one_type="aliases"

	run __migrate_all_components "$subdirectory" "$one_type" "100"
	assert_success
}

@test "helpers: migrate all completions with previous priority" {
	subdirectory="completion"
	one_type="completion"

	run __migrate_all_components "$subdirectory" "$one_type" "100"
	assert_success
}

@test "helpers: verify that existing components are automatically migrated when something is enabled" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	run bash-it enable plugin "node"
	assert_line -n 0 'Migrating plugin nvm.'
	assert_line -n 1 'nvm disabled.'
	assert_line -n 2 'nvm enabled with priority 225.'
	assert_line -n 3 'If any migration errors were reported, please try the following: reload && bash-it migrate'
	assert_line -n 4 'node enabled with priority 250.'
	assert [ ! -L "${BASH_IT?}/plugins/enabled/nvm.plugin.bash" ]
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---node.plugin.bash"
}

@test "helpers: verify that existing components are automatically migrated when something is disabled" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	ln -s "${BASH_IT?}/plugins/available/node.plugin.bash" "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"

	run bash-it disable plugin "node"
	assert_line -n 0 'Migrating plugin node.'
	assert_line -n 1 'node disabled.'
	assert_line -n 2 'node enabled with priority 250.'
	assert_line -n 3 'Migrating plugin nvm.'
	assert_line -n 4 'nvm disabled.'
	assert_line -n 5 'nvm enabled with priority 225.'
	assert_line -n 6 'If any migration errors were reported, please try the following: reload && bash-it migrate'
	assert_line -n 7 'node disabled.'
	assert [ ! -L "${BASH_IT?}/plugins/enabled/nvm.plugin.bash" ]
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"
	assert [ ! -L "${BASH_IT?}/plugins/enabled/250---node.plugin.bash" ]
	assert [ ! -L "${BASH_IT?}/enabled/250---node.plugin.bash" ]
}

@test "helpers: enable all plugins" {
	local available enabled
	run _enable-plugin "all"
	available=$(find "${BASH_IT?}/plugins/available" -name '*.plugin.bash' | wc -l | xargs)
	enabled=$(find "${BASH_IT?}/enabled" -name '[0-9]*.plugin.bash' | wc -l | xargs)
	assert_equal "$available" "$enabled"
}

@test "helpers: disable all plugins" {
	local available enabled enabled2
	run _enable-plugin "all"
	available=$(find "${BASH_IT?}/plugins/available" -name '*.plugin.bash' | wc -l | xargs)
	enabled=$(find "${BASH_IT?}/enabled" -name '[0-9]*.plugin.bash' | wc -l | xargs)
	assert_equal "$available" "$enabled"

	run _enable-alias "ag"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run _disable-plugin "all"
	enabled2=$(find "${BASH_IT?}/enabled" -name '[0-9]*.plugin.bash' | wc -l | xargs)
	assert_equal "0" "$enabled2"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"
}

@test "helpers: disable all plugins in the old directory structure" {
	local enabled enabled2
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	ln -s "${BASH_IT?}/plugins/available/node.plugin.bash" "${BASH_IT?}/plugins/enabled/node.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/node.plugin.bash"

	enabled=$(find "${BASH_IT?}/plugins/enabled" -name '*.plugin.bash' | wc -l | xargs)
	assert_equal "2" "$enabled"

	run _enable-alias "ag"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run _disable-plugin "all"
	enabled2=$(find "${BASH_IT?}/plugins/enabled" -name '*.plugin.bash' | wc -l | xargs)
	assert_equal "0" "$enabled2"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"
}

@test "helpers: disable all plugins in the old directory structure with priority" {
	local enabled enabled2
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/250---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---nvm.plugin.bash"

	ln -s "${BASH_IT?}/plugins/available/node.plugin.bash" "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---node.plugin.bash"

	enabled=$(find "${BASH_IT?}/plugins/enabled" -name '*.plugin.bash' | wc -l | xargs)
	assert_equal "2" "$enabled"

	run _enable-alias "ag"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run _disable-plugin "all"
	enabled2=$(find "${BASH_IT?}/plugins/enabled" -name '*.plugin.bash' | wc -l | xargs)
	assert_equal "0" "$enabled2"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"
}

@test "helpers: disable all plugins without anything enabled" {
	local enabled enabled2
	enabled=$(find "${BASH_IT?}/enabled" -name '[0-9]*.plugin.bash' | wc -l | xargs)
	assert_equal "0" "$enabled"

	run _enable-alias "ag"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"

	run _disable-plugin "all"
	enabled2=$(find "${BASH_IT?}/enabled" -name '[0-9]*.plugin.bash' | wc -l | xargs)
	assert_equal "0" "$enabled2"
	assert_link_exist "${BASH_IT?}/enabled/150---ag.aliases.bash"
}

@test "helpers: enable the ansible aliases through the bash-it function" {
	run bash-it enable alias "ansible"
	assert_line -n 0 'ansible enabled with priority 150.'
	assert_link_exist "${BASH_IT?}/enabled/150---ansible.aliases.bash"
}

@test "helpers: describe the nvm plugin without enabling it" {
	_bash-it-plugins | grep "nvm" | grep "\[ \]"
}

@test "helpers: describe the nvm plugin after enabling it" {
	run _enable-plugin "nvm"
	assert_line -n 0 'nvm enabled with priority 225.'
	assert_link_exist "${BASH_IT?}/enabled/225---nvm.plugin.bash"

	_bash-it-plugins | grep "nvm" | grep "\[x\]"
}

@test "helpers: describe the nvm plugin after enabling it in the old directory" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/nvm.plugin.bash"

	_bash-it-plugins | grep "nvm" | grep "\[x\]"
}

@test "helpers: describe the nvm plugin after enabling it in the old directory with priority" {
	ln -s "${BASH_IT?}/plugins/available/nvm.plugin.bash" "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/225---nvm.plugin.bash"

	_bash-it-plugins | grep "nvm" | grep "\[x\]"
}

@test "helpers: describe the todo.txt-cli aliases without enabling them" {
	run _bash-it-aliases
	assert_line "todo.txt-cli         [ ]        todo.txt-cli abbreviations"
}

# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	# Copy the test fixture to the Bash-it folder
	cp -fRP "${BASH_IT?}/test/fixtures/bash_it"/* "${BASH_IT?}/" || true
	# don't load any libraries as the tests here test the *whole* kit
}

@test "bash-it: verify that the test fixture is available" {
	assert_file_exist "${BASH_IT?}/aliases/available/a.aliases.bash"
	assert_file_exist "${BASH_IT?}/aliases/available/b.aliases.bash"
}

@test "bash-it: load aliases in order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases in priority order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/175---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/175---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load aliases and plugins in priority order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load aliases, plugins and completions in priority order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/completion/enabled/350---b.completion.bash"
	assert_link_exist "${BASH_IT?}/completion/enabled/350---b.completion.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	# "b" wins since completions are loaded last in the old directory structure
	assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases, plugins and completions in priority order, even if the priority says otherwise" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/450---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/450---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/completion/enabled/350---b.completion.bash"
	assert_link_exist "${BASH_IT?}/completion/enabled/350---b.completion.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/plugins/enabled/950---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/950---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	# "b" wins since completions are loaded last in the old directory structure
	assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases and plugins in priority order, with one alias higher than plugins" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/aliases/enabled/350---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/350---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	# This will be c, loaded from the c plugin, since the individual directories
	# are loaded one by one.
	assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load global aliases in order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/enabled/150---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---b.aliases.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load global aliases in priority order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/enabled/175---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/175---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---b.aliases.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load global aliases and plugins in priority order" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/enabled/150---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---b.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load global aliases and plugins in priority order, with one alias higher than plugins" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/enabled/350---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/350---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---b.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---c.plugin.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	# This will be a, loaded from the a aliases, since the global directory
	# loads all component types at once
	assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load global aliases and plugins in priority order, individual old directories are loaded later" {
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	ln -s "${BASH_IT?}/aliases/available/a.aliases.bash" "${BASH_IT?}/enabled/350---a.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/350---a.aliases.bash"
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---b.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/c.plugin.bash" "${BASH_IT?}/enabled/250---c.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---c.plugin.bash"
	# Add one file in the old directory structure
	ln -s "${BASH_IT?}/aliases/available/b.aliases.bash" "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---b.aliases.bash"

	# The `test_alias` alias should not exist
	run alias test_alias &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias test_alias &> /dev/null
	assert_success
	# This will be "b", loaded from the b aliases in the individual directory, since
	# the individual directories are loaded after the global one.
	assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load enabled aliases from new structure, priority-based" {
	ln -s "${BASH_IT?}/aliases/available/atom.aliases.bash" "${BASH_IT?}/enabled/150---atom.aliases.bash"
	assert_link_exist "${BASH_IT?}/enabled/150---atom.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/enabled/250---base.plugin.bash"

	# The `ah` alias should not exist
	run alias ah &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias ah &> /dev/null
	assert_success
}

@test "bash-it: load enabled aliases from old structure, priority-based" {
	ln -s "${BASH_IT?}/aliases/available/atom.aliases.bash" "${BASH_IT?}/aliases/enabled/150---atom.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/150---atom.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/250---base.plugin.bash"

	# The `ah` alias should not exist
	run alias ah &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias ah &> /dev/null
	assert_success
}

@test "bash-it: load enabled aliases from old structure, without priorities" {
	ln -s "${BASH_IT?}/aliases/available/atom.aliases.bash" "${BASH_IT?}/aliases/enabled/atom.aliases.bash"
	assert_link_exist "${BASH_IT?}/aliases/enabled/atom.aliases.bash"
	ln -s "${BASH_IT?}/plugins/available/base.plugin.bash" "${BASH_IT?}/plugins/enabled/base.plugin.bash"
	assert_link_exist "${BASH_IT?}/plugins/enabled/base.plugin.bash"

	# The `ah` alias should not exist
	run alias ah &> /dev/null
	assert_failure

	load "${BASH_IT?}/bash_it.sh"

	run alias ah &> /dev/null
	assert_success
}

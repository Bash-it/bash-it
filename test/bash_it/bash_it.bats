#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

function local_setup {
  setup_test_fixture

  # Copy the test fixture to the Bash-it folder
  if command -v rsync &> /dev/null
  then
    rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/"
  else
    find "$BASH_IT/test/fixtures/bash_it" \
      -mindepth 1 -maxdepth 1 \
      -exec cp -r {} "$BASH_IT/" \;
  fi
}

@test "bash-it: verify that the test fixture is available" {
  assert_file_exist "$BASH_IT/aliases/available/a.aliases.bash"
  assert_file_exist "$BASH_IT/aliases/available/b.aliases.bash"
}

@test "bash-it: load aliases in order" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/150---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases in priority order" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/175---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/175---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load aliases and plugins in priority order" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/150---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/plugins/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load aliases, plugins and completions in priority order" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled
  mkdir -p $BASH_IT/completion/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/150---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/completion/enabled/350---b.completion.bash
  assert_link_exist "$BASH_IT/completion/enabled/350---b.completion.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/plugins/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  # "b" wins since completions are loaded last in the old directory structure
  assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases, plugins and completions in priority order, even if the priority says otherwise" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled
  mkdir -p $BASH_IT/completion/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/450---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/450---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/completion/enabled/350---b.completion.bash
  assert_link_exist "$BASH_IT/completion/enabled/350---b.completion.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/plugins/enabled/950---c.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/950---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  # "b" wins since completions are loaded last in the old directory structure
  assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load aliases and plugins in priority order, with one alias higher than plugins" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/350---a.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/350---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/plugins/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  # This will be c, loaded from the c plugin, since the individual directories
  # are loaded one by one.
  assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load global aliases in order" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150---a.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---b.aliases.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load global aliases in priority order" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/175---a.aliases.bash
  assert_link_exist "$BASH_IT/enabled/175---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---b.aliases.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load global aliases and plugins in priority order" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150---a.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---b.aliases.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line -n 0 "alias test_alias='c'"
}

@test "bash-it: load global aliases and plugins in priority order, with one alias higher than plugins" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/350---a.aliases.bash
  assert_link_exist "$BASH_IT/enabled/350---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---b.aliases.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---c.plugin.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  # This will be a, loaded from the a aliases, since the global directory
  # loads all component types at once
  assert_line -n 0 "alias test_alias='a'"
}

@test "bash-it: load global aliases and plugins in priority order, individual old directories are loaded later" {
  mkdir -p $BASH_IT/enabled
  mkdir -p $BASH_IT/aliases/enabled

  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/350---a.aliases.bash
  assert_link_exist "$BASH_IT/enabled/350---a.aliases.bash"
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---b.aliases.bash"
  ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250---c.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---c.plugin.bash"
  # Add one file in the old directory structure
  ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"

  # The `test_alias` alias should not exist
  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  # This will be "b", loaded from the b aliases in the individual directory, since
  # the individual directories are loaded after the global one.
  assert_line -n 0 "alias test_alias='b'"
}

@test "bash-it: load enabled aliases from new structure, priority-based" {
  mkdir -p $BASH_IT/enabled
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---atom.aliases.bash"
  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"

  # The `ah` alias should not exist
  run alias ah &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias ah &> /dev/null
  assert_success
}

@test "bash-it: load enabled aliases from old structure, priority-based" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---atom.aliases.bash"
  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/250---base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/250---base.plugin.bash"

  # The `ah` alias should not exist
  run alias ah &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias ah &> /dev/null
  assert_success
}

@test "bash-it: load enabled aliases from old structure, without priorities" {
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/plugins/enabled
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/atom.aliases.bash"
  ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/plugins/enabled/base.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/base.plugin.bash"

  # The `ah` alias should not exist
  run alias ah &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias ah &> /dev/null
  assert_success
}

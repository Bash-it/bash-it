#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

function local_setup {
  mkdir -p $BASH_IT
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  cp -r $lib_directory/../.. $BASH_IT
  mkdir -p $BASH_IT/aliases/enabled
  mkdir -p $BASH_IT/completion/enabled
  mkdir -p $BASH_IT/plugins/enabled
}

@test "bash-it: enable the ansible aliases through the bash-it function" {
  run bash-it enable alias "ansible"
  assert_line "0" 'ansible enabled with priority 150.'
  assert [ -L "$BASH_IT/aliases/enabled/150---ansible.aliases.bash" ]
}

@test "bash-it: enable the todo.txt-cli aliases through the bash-it function" {
  run bash-it enable alias "todo.txt-cli"
  assert_line "0" 'todo.txt-cli enabled with priority 150.'
  assert [ -L "$BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash" ]
}

@test "bash-it: enable the curl aliases" {
  run _enable-alias "curl"
  assert_line "0" 'curl enabled with priority 150.'
  assert [ -L "$BASH_IT/aliases/enabled/150---curl.aliases.bash" ]
}

@test "bash-it: enable the apm completion through the bash-it function" {
  run bash-it enable completion "apm"
  assert_line "0" 'apm enabled with priority 350.'
  assert [ -L "$BASH_IT/completion/enabled/350---apm.completion.bash" ]
}

@test "bash-it: enable the brew completion" {
  run _enable-completion "brew"
  assert_line "0" 'brew enabled with priority 350.'
  assert [ -L "$BASH_IT/completion/enabled/350---brew.completion.bash" ]
}

@test "bash-it: enable the node plugin" {
  run _enable-plugin "node"
  assert_line "0" 'node enabled with priority 250.'
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "bash-it: enable the node plugin through the bash-it function" {
  run bash-it enable plugin "node"
  assert_line "0" 'node enabled with priority 250.'
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "bash-it: enable the node and nvm plugins through the bash-it function" {
  run bash-it enable plugin "node" "nvm"
  assert_line "0" 'node enabled with priority 250.'
  assert_line "1" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable the foo-unkown and nvm plugins through the bash-it function" {
  run bash-it enable plugin "foo-unknown" "nvm"
  assert_line "0" 'sorry, foo-unknown does not appear to be an available plugin.'
  assert_line "1" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin" {
  run _enable-plugin "nvm"
  assert_line "0" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable an unknown plugin" {
  run _enable-plugin "unknown-foo"
  assert_line "0" 'sorry, unknown-foo does not appear to be an available plugin.'
  assert [ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]
}

@test "bash-it: enable an unknown plugin through the bash-it function" {
  run bash-it enable plugin "unknown-foo"
  echo "${lines[@]}"
  assert_line "0" 'sorry, unknown-foo does not appear to be an available plugin.'
  assert [ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]
}

@test "bash-it: disable a plugin that is not enabled" {
  run _disable-plugin "sdkman"
  assert_line "0" 'sorry, sdkman does not appear to be an enabled plugin.'
}

@test "bash-it: enable and disable the nvm plugin" {
  run _enable-plugin "nvm"
  assert_line "0" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  assert_line "0" 'nvm disabled.'
  assert [ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: disable the nvm plugin if it was enabled without a priority" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  assert_line "0" 'nvm disabled.'
  assert [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin if it was enabled without a priority" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run _enable-plugin "nvm"
  assert_line "0" 'nvm is already enabled.'
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin twice" {
  run _enable-plugin "nvm"
  assert_line "0" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _enable-plugin "nvm"
  assert_line "0" 'nvm is already enabled.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: migrate enabled plugins that don't use the new priority-based configuration" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  ln -s $BASH_IT/plugins/available/node.plugin.bash $BASH_IT/plugins/enabled/node.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/node.plugin.bash" ]

  ln -s $BASH_IT/aliases/available/todo.txt-cli.aliases.bash $BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash" ]

  run _enable-plugin "ssh"
  assert [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]

  run _bash-it-migrate
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]
  assert [ -L "$BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/node.plugin.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  assert [ ! -L "$BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash" ]
}

@test "bash-it: run the migrate command without anything to migrate and nothing enabled" {
  run _bash-it-migrate
}

@test "bash-it: run the migrate command without anything to migrate" {
  run _enable-plugin "ssh"
  assert [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]

  run _bash-it-migrate
  assert [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]
}

@test "bash-it: verify that existing components are automatically migrated when something is enabled" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run bash-it enable plugin "node"
  assert_line "0" 'Migrating plugin nvm.'
  assert_line "1" 'nvm disabled.'
  assert_line "2" 'nvm enabled with priority 225.'
  assert_line "3" 'node enabled with priority 250.'
  assert [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "bash-it: verify that existing components are automatically migrated when something is disabled" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  ln -s $BASH_IT/plugins/available/node.plugin.bash $BASH_IT/plugins/enabled/250---node.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]

  run bash-it disable plugin "node"
  assert_line "0" 'Migrating plugin nvm.'
  assert_line "1" 'nvm disabled.'
  assert_line "2" 'nvm enabled with priority 225.'
  assert_line "3" 'node disabled.'
  assert [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
  assert [ ! -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "bash-it: enable all plugins" {
  run _enable-plugin "all"
  local available=$(find $BASH_IT/plugins/available -name *.plugin.bash | wc -l | xargs)
  local enabled=$(find $BASH_IT/plugins/enabled -name [0-9]*.plugin.bash | wc -l | xargs)
  assert_equal "$available" "$enabled"
}

@test "bash-it: disable all plugins" {
  run _enable-plugin "all"
  local available=$(find $BASH_IT/plugins/available -name *.plugin.bash | wc -l | xargs)
  local enabled=$(find $BASH_IT/plugins/enabled -name [0-9]*.plugin.bash | wc -l | xargs)
  assert_equal "$available" "$enabled"

  run _disable-plugin "all"
  local enabled2=$(find $BASH_IT/plugins/enabled -name *.plugin.bash | wc -l | xargs)
  assert_equal "$enabled2" "0"
}

@test "bash-it: describe the nvm plugin without enabling it" {
  _bash-it-plugins | grep "nvm" | grep "\[ \]"
}

@test "bash-it: describe the nvm plugin after enabling it" {
  run _enable-plugin "nvm"
  assert_line "0" 'nvm enabled with priority 225.'
  assert [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  _bash-it-plugins | grep "nvm" | grep "\[x\]"
}

@test "bash-it: describe the todo.txt-cli aliases without enabling them" {
  run _bash-it-aliases
  assert_line "todo.txt-cli          [ ]     todo.txt-cli abbreviations"
}

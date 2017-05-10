#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

function local_setup {
  mkdir -p $BASH_IT/plugins
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  cp -r $lib_directory/../../plugins/available $BASH_IT/plugins
  mkdir -p $BASH_IT/plugins/enabled
}

@test "bash-it: enable the node plugin" {
  run _enable-plugin "node"
  [ "${lines[0]}" == 'node enabled with priority 250.' ]
  [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin" {
  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable an unknown plugin" {
  run _enable-plugin "unknown-foo"
  [ "${lines[0]}" == 'sorry, unknown-foo does not appear to be an available plugin.' ]
  [ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]
  [ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]
}

@test "bash-it: disable a plugin that is not enabled" {
  run _disable-plugin "sdkman"
  [ "${lines[0]}" == 'sorry, sdkman does not appear to be an enabled plugin.' ]
}

@test "bash-it: enable and disable the nvm plugin" {
  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  [ "${lines[0]}" == 'nvm disabled.' ]
  [ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: disable the nvm plugin if it was enabled without a priority" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  [ "${lines[0]}" == 'nvm disabled.' ]
  [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin if it was enabled without a priority" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm is already enabled.' ]
  [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
  [ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: enable the nvm plugin twice" {
  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm is already enabled.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "bash-it: migrate enabled plugins that don't use the new priority-based configuration" {
  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  ln -s $BASH_IT/plugins/available/node.plugin.bash $BASH_IT/plugins/enabled/node.plugin.bash
  [ -L "$BASH_IT/plugins/enabled/node.plugin.bash" ]

  run _enable-plugin "ssh"
  [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]

  run _bash-it-migrate
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
  [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
  [ -L "$BASH_IT/plugins/enabled/250---ssh.plugin.bash" ]
  [ ! -L "$BASH_IT/plugins/enabled/node.plugin.bash" ]
  [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
}

@test "bash-it: enable all plugins" {
  run _enable-plugin "all"
  local available=$(find $BASH_IT/plugins/available -name *.plugin.bash | wc -l)
  local enabled=$(find $BASH_IT/plugins/enabled -name 2*.plugin.bash | wc -l)
  echo "Available: $available, Enabled: $enabled"
  [ "$available" == "$enabled" ]
}

@test "bash-it: disable all plugins" {
  run _enable-plugin "all"
  local available=$(find $BASH_IT/plugins/available -name *.plugin.bash | wc -l)
  local enabled=$(find $BASH_IT/plugins/enabled -name 2*.plugin.bash | wc -l)
  echo "Available: $available, Enabled: $enabled"
  [ "$available" == "$enabled" ]

  run _disable-plugin "all"
  local enabled2=$(find $BASH_IT/plugins/enabled -name *.plugin.bash | wc -l)
  echo "Enabled: $enabled2"
  [ "$enabled2" -eq 0 ]
}

@test "bash-it: describe the nvm plugin without enabling it" {
  _bash-it-plugins | grep "nvm" | grep "\[ \]"
}

@test "bash-it: describe the nvm plugin after enabling it" {
  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  _bash-it-plugins | grep "nvm" | grep "\[x\]"
}

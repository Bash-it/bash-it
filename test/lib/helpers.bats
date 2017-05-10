#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

function __setup_plugin_tests {
  mkdir -p $BASH_IT/plugins
  pwd
  ls -als ..
  ls -als ../plugins
  cp -r ../plugins/available $BASH_IT/plugins
  mkdir -p $BASH_IT/plugins/enabled
}

@test "enable the node plugin" {
  __setup_plugin_tests

  run _enable-plugin "node"
  [ "${lines[0]}" == 'node enabled with priority 250.' ]
  [ -L "$BASH_IT/plugins/enabled/250---node.plugin.bash" ]
}

@test "enable the nvm plugin" {
  __setup_plugin_tests

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "enable an unknown plugin" {
  __setup_plugin_tests

  run _enable-plugin "unknown-foo"
  [ "${lines[0]}" == 'sorry, unknown-foo does not appear to be an available plugin.' ]
  [ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]
  [ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]
}

@test "disable a plugin that is not enabled" {
  __setup_plugin_tests

  run _disable-plugin "sdkman"
  [ "${lines[0]}" == 'sorry, sdkman does not appear to be an enabled plugin.' ]
}

@test "enable and disable the nvm plugin" {
  __setup_plugin_tests

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  [ "${lines[0]}" == 'nvm disabled.' ]
  [ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "disable the nvm plugin if it was enabled without a priority" {
  __setup_plugin_tests

  ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
  [ -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]

  run _disable-plugin "nvm"
  [ "${lines[0]}" == 'nvm disabled.' ]
  [ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]
}

@test "enable the nvm plugin twice" {
  __setup_plugin_tests

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm is already enabled.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]
}

@test "enable all plugins" {
  __setup_plugin_tests

  run _enable-plugin "all"
  local available=$(find $BASH_IT/plugins/available -name *.plugin.bash | wc -l)
  local enabled=$(find $BASH_IT/plugins/enabled -name 2*.plugin.bash | wc -l)
  echo "Available: $available, Enabled: $enabled"
  [ "$available" == "$enabled" ]
}

@test "disable all plugins" {
  __setup_plugin_tests

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

@test "describe the nvm plugin without enabling it" {
  __setup_plugin_tests

  _bash-it-plugins | grep "nvm" | grep "\[ \]"
}

@test "describe the nvm plugin after enabling it" {
  __setup_plugin_tests

  run _enable-plugin "nvm"
  [ "${lines[0]}" == 'nvm enabled with priority 225.' ]
  [ -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]

  _bash-it-plugins | grep "nvm" | grep "\[x\]"
}

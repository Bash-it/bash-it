#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

cite _about _param _example _group _author _version

load ../../plugins/available/battery.plugin

function setup_command_exists_pmset {
  function _command_exists {
    case "$1" in
      "pmset")
        true
      ;;
      *)
        false
      ;;
    esac
  }
}

function setup_pmset {
  percent="$1"

  function pmset {
    echo "-InternalBattery-0 (id=12345)	""${percent}""; discharging; 16:00 remaining present: true"
  }
}

@test 'plugins battery: battery-percentage with pmset, 100%' {
  setup_command_exists_pmset

  setup_pmset "100%"

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with pmset, 98%' {
  setup_command_exists_pmset

  setup_pmset "98%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 98.5%' {
  setup_command_exists_pmset

  setup_pmset "98.5%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 4%' {
  setup_command_exists_pmset

  setup_pmset "4%"

  run battery_percentage
  assert_output "4"
}

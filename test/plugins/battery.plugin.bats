#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../plugins/available/battery.plugin

@test 'plugins battery: battery-percentage with pmset, 100%' {
  function pmset {
    echo "-InternalBattery-0 (id=12345)	100%; discharging; 16:00 remaining present: true"
  }

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with pmset, 98%' {
  function pmset {
    echo "-InternalBattery-0 (id=12345)	98%; discharging; 16:00 remaining present: true"
  }

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 4%' {
  function pmset {
    echo "-InternalBattery-0 (id=12345)	4%; discharging; 16:00 remaining present: true"
  }

  run battery_percentage
  assert_output "4"
}

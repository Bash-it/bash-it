#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

cite _about _param _example _group _author _version

load ../../plugins/available/battery.plugin

function setup_command_exists {
  success_command="$1"

  function _command_exists {
    case "$1" in
      "${success_command}")
        true
      ;;
      *)
        false
      ;;
    esac
  }
}

#######################
#
# pmset
#

function setup_pmset {
  percent="$1"

  function pmset {
    echo "-InternalBattery-0 (id=12345)	""${percent}""; discharging; 16:00 remaining present: true"
  }
}

@test 'plugins battery: battery-percentage with pmset, 100%' {
  setup_command_exists "pmset"

  setup_pmset "100%"

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with pmset, 98%' {
  setup_command_exists "pmset"

  setup_pmset "98%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 98.5%' {
  setup_command_exists "pmset"

  setup_pmset "98.5%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 4%' {
  setup_command_exists "pmset"

  setup_pmset "4%"

  run battery_percentage
  assert_output "4"
}

#######################
#
# acpi
#

function setup_acpi {
  percent="$1"

  function acpi {
    echo "-InternalBattery-0 (id=12345)	""${percent}""; discharging; 16:00 remaining present: true"
  }
}

@test 'plugins battery: battery-percentage with acpi, 100%' {
  setup_command_exists "acpi"

  setup_acpi "100%"

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with acpi, 98%' {
  setup_command_exists "acpi"

  setup_acpi "98%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with acpi, 98.5%' {
  setup_command_exists "acpi"

  setup_acpi "98.5%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with acpi, 4%' {
  setup_command_exists "acpi"

  setup_acpi "4%"

  run battery_percentage
  assert_output "4"
}

#######################
#
# upower
#

function setup_upower {
  percent="$1"

  function upower {
    echo "-InternalBattery-0 (id=12345)	""${percent}""; discharging; 16:00 remaining present: true"
  }
}

@test 'plugins battery: battery-percentage with upower, 100%' {
  setup_command_exists "upower"

  setup_upower "100%"

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with upower, 98%' {
  setup_command_exists "upower"

  setup_upower "98%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with upower, 98.5%' {
  setup_command_exists "upower"

  setup_upower "98.5%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with upower, 4%' {
  setup_command_exists "upower"

  setup_upower "4%"

  run battery_percentage
  assert_output "4"
}

#######################
#
# ioreg
#

function setup_ioreg {
  percent="$1"

  function ioreg {
    printf "\"MaxCapacity\" = 100\n\"CurrentCapacity\" = %s" "${percent}"
  }
}

@test 'plugins battery: battery-percentage with ioreg, 100%' {
  setup_command_exists "ioreg"

  setup_ioreg "100%"

  run battery_percentage
  assert_output "100"
}

@test 'plugins battery: battery-percentage with ioreg, 98%' {
  setup_command_exists "ioreg"

  setup_ioreg "98%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with ioreg, 98.5%' {
  setup_command_exists "ioreg"

  setup_ioreg "98.5%"

  run battery_percentage
  assert_output "98"
}

@test 'plugins battery: battery-percentage with ioreg, 4%' {
  setup_command_exists "ioreg"

  setup_ioreg "4%"

  run battery_percentage
  assert_output "4"
}

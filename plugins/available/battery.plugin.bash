cite about-plugin
about-plugin 'display info about your battery charge level'

ac_adapter_connected(){
  if _command_exists upower;
  then
    upower -i $(upower -e | grep BAT) | grep 'state' | grep -q 'charging\|fully-charged'
    return $?
  elif _command_exists acpi;
  then
    acpi -a | grep -q "on-line"
    return $?
  elif _command_exists pmset;
  then
    pmset -g batt | grep -q 'AC Power'
    return $?
  elif _command_exists ioreg;
  then
    ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = Yes'
    return $?
  elif _command_exists WMIC;
  then
    WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=2'
    return $?
  fi
}

ac_adapter_disconnected(){
  if _command_exists upower;
  then
    upower -i $(upower -e | grep BAT) | grep 'state' | grep -q 'discharging'
    return $?
  elif _command_exists acpi;
  then
    acpi -a | grep -q "off-line"
    return $?
  elif _command_exists pmset;
  then
    pmset -g batt | grep -q 'Battery Power'
    return $?
  elif _command_exists ioreg;
  then
    ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = No'
    return $?
  elif _command_exists WMIC;
  then
    WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=1'
    return $?
  fi
}

battery_percentage(){
  about 'displays battery charge as a percentage of full (100%)'
  group 'battery'

  if _command_exists upower;
  then
    local UPOWER_OUTPUT=$(upower --show-info $(upower --enumerate | grep BAT) | grep percentage | grep -o "[0-9]\+" | head -1)
    echo ${UPOWER_OUTPUT:--1}
  elif _command_exists acpi;
  then
    local PERC_OUTPUT=$(acpi -b | awk -F, '/,/{gsub(/ /, "", $0); gsub(/%/,"", $0); print $2}' )
    echo ${PERC_OUTPUT:--1}
  elif _command_exists pmset;
  then
    local PMSET_OUTPUT=$(pmset -g ps | sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p' | grep -o "[0-9]\+" | head -1)
    echo ${PMSET_OUTPUT:--1}
  elif _command_exists ioreg;
  then
    local IOREG_OUTPUT=$(ioreg -n AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%d"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}')
    echo ${IOREG_OUTPUT:--1}
  elif _command_exists WMIC;
  then
    local WINPC=$(WMIC PATH Win32_Battery Get EstimatedChargeRemaining /Format:List | grep -o '[0-9]\+' | head -1)
    echo ${WINPC:--1}
  else
    echo "no"
  fi
}

battery_charge(){
  about 'graphical display of your battery charge'
  group 'battery'

  # Full char
  local F_C='▸'
  # Depleted char
  local D_C='▹'
  local DEPLETED_COLOR="${normal}"
  local FULL_COLOR="${green}"
  local HALF_COLOR="${yellow}"
  local DANGER_COLOR="${red}"
  local BATTERY_OUTPUT="${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${D_C}"
  local BATTERY_PERC=$(battery_percentage)

  case $BATTERY_PERC in
    no)
      echo ""
    ;;
    9*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${F_C}${normal}"
    ;;
    8*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${normal}"
    ;;
    7*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
    ;;
    6*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
    ;;
    5*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
    ;;
    4*)
      echo "${FULL_COLOR}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
    ;;
    3*)
      echo "${FULL_COLOR}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
    ;;
    2*)
      echo "${FULL_COLOR}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
    ;;
    1*)
      echo "${FULL_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    05)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    04)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    03)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    02)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    0*)
      echo "${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
    ;;
    *)
      echo "${DANGER_COLOR}UNPLG${normal}"
    ;;
  esac
}

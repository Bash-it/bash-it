cite about-plugin
about-plugin 'display info about your battery charge level'

ac_adapter_connected(){
    if command_exists acpi;
    then
        acpi -a | grep "on-line"
        if [[ "$?" -eq 0 ]]; then
           return 1
        else
           return 0
        fi
    fi
}

battery_percentage(){
  about 'displays battery charge as a percentage of full (100%)'
  group 'battery'

  if command_exists acpi;
  then
    local ACPI_OUTPUT=$(acpi -b)
    case $ACPI_OUTPUT in
      *" Unknown"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 22 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Discharging"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 26 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Charging"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 23 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Full"*)
        echo '99'
        ;;
      *)
        echo '-1'
        ;;
    esac
  elif command_exists ioreg;
  then
    # http://hints.macworld.com/article.php?story=20100130123935998
    #local IOREG_OUTPUT_10_6=$(ioreg -l | grep -i capacity | tr '\n' ' | ' | awk '{printf("%.2f%%", $10/$5 * 100)}')
    #local IOREG_OUTPUT_10_5=$(ioreg -l | grep -i capacity | grep -v Legacy| tr '\n' ' | ' | awk '{printf("%.2f%%", $14/$7 * 100)}')
    local IOREG_OUTPUT=$(ioreg -n AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%05.2f%%"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}')
    case $IOREG_OUTPUT in
      100*)
        echo '99'
        ;;
      *)
        echo $IOREG_OUTPUT | head -c 2
        ;;
    esac
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

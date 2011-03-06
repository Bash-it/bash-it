#!/bin/bash

battery_percentage(){
  local ACPI_OUTPUT=$(acpi -b)
  case $ACPI_OUTPUT in
    *" Unknown"*) 
      echo $ACPI_OUTPUT | head -c 22 | tail -c 2
      ;;
    *" Discharging"*) 
      echo $ACPI_OUTPUT | head -c 26 | tail -c 2
      ;;
    *" Charging"*) 
      echo $ACPI_OUTPUT | head -c 23 | tail -c 2
      ;;
    *" Full"*) 
      echo '99'
      ;;
    *)
      echo '-1'
      ;;
  esac
}

battery_charge(){
  # Full char
  local F_C='▸'
  # Depleted char
  local D_C='▹'
  local DEPLETED_COLOR='\[${normal}\]'
  local FULL_COLOR='\[${green}\]'
  local HALF_COLOR='\[${yellow}\]'
  local DANGER_COLOR='\[${red}\]'
  local BATTERY_OUTPUT='${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${D_C}'
  local BATTERY_PERC=$(battery_percentage)

  case $BATTERY_PERC in
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
      echo "${DANGER_COLOR}ERROR\[${normal}\]"
      ;;
  esac

#  if [ $BATTERY_PERC < 0 ];
  #then
    #BATTERY_OUTPUT="ERROR"
  #else
    #if [ $BATTERY_PERC > 90 ];
    #then
      #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${F_C}${normal}"
    #else
      #if [ $BATTERY_PERC > 80 ];
      #then
        #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${normal}"
      #else
        #if [ $BATTERY_PERC > 70 ];
        #then
          #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
        #else
          #if [ $BATTERY_PERC > 60 ];
          #then
            #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
          #else
            #if [ $BATTERY_PERC > 50 ];
            #then
              #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
            #else
              #if [ $BATTERY_PERC > 40 ];
              #then
                #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
              #else
                #if [ $BATTERY_PERC > 30 ];
                #then
                  #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
                #else
                  #if [ $BATTERY_PERC > 20 ];
                  #then
                    #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
                  #else
                    #if [ $BATTERY_PERC > 10 ];
                    #then
                      #BATTERY_OUTPUT="${FULL_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
                    #else
                      #BATTERY_OUTPUT="${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
                    #fi
                  #fi
                #fi
              #fi
            #fi
          #fi
        #fi
      #fi
    #fi
  #fi
  #echo $BATTERY_OUTPUT
}

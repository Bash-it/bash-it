cite about-plugin
about-plugin 'OS X Time Machine functions'

function time-machine-destination() {
  group "osx-timemachine"
  about "Shows the OS X Time Machine destination/mount point"

  echo $(tmutil destinationinfo | grep "Mount Point" | sed -e 's/Mount Point   : \(.*\)/\1/g')
}

function time-machine-list-machines() {
  group "osx-timemachine"
  about "Lists the OS X Time Machine machines on the backup volume"

  local tmdest="$(time-machine-destination)/Backups.backupdb"

  find "$tmdest" -maxdepth 1 -mindepth 1 -type d | grep -v "/\." | while read line ; do
    echo "$(basename "$line")"
  done
}

function time-machine-list-all-backups() {
  group "osx-timemachine"
  about "Shows all of the backups for the specified machine"
  param "1: Machine name (optional)"
  example "time-machine-list-all-backups my-laptop"

  # Use the local hostname if none provided
  local COMPUTERNAME=${1:-$(scutil --get ComputerName)}
  local BACKUP_LOCATION="$(time-machine-destination)/Backups.backupdb/$COMPUTERNAME"

  find "$BACKUP_LOCATION" -maxdepth 1 -mindepth 1 -type d | while read line ; do
    echo "$line"
  done
}

function time-machine-list-old-backups() {
  group "osx-timemachine"
  about "Shows all of the backups for the specified machine, except for the most recent backup"
  param "1: Machine name (optional)"
  example "time-machine-list-old-backups my-laptop"

  # Use the local hostname if none provided
  local COMPUTERNAME=${1:-$(scutil --get ComputerName)}
  local BACKUP_LOCATION="$(time-machine-destination)/Backups.backupdb/$COMPUTERNAME"

  # List all but the most recent one
  find "$BACKUP_LOCATION" -maxdepth 1 -mindepth 1 -type d -name 2\* | sed \$d | while read line ; do
    echo "$line"
  done
}

# Taken from here: http://stackoverflow.com/a/30547074/1228454
function _tm_startsudo() {
    sudo -v
    ( while true; do sudo -v; sleep 50; done; ) &
    SUDO_PID="$!"
    trap _tm_stopsudo SIGINT SIGTERM
}
function _tm_stopsudo() {
    kill "$SUDO_PID"
    trap - SIGINT SIGTERM
    sudo -k
}

function time-machine-delete-old-backups() {
  group "osx-timemachine"
  about "Deletes all of the backups for the specified machine, with the exception of the most recent one"
  param "1: Machine name (optional)"
  example "time-machine-delete-old-backups my-laptop"

  # Use the local hostname if none provided
  local COMPUTERNAME=${1:-$(scutil --get ComputerName)}

  # Ask for sudo credentials only once
  _tm_startsudo

  echo "$(time-machine-list-old-backups "$COMPUTERNAME")" | while read i ; do
    # Delete the backup
    sudo tmutil delete "$i"
  done

  _tm_stopsudo
}

#!/bin/bash

function rh {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
  
function ips {
  ifconfig | grep "inet " | awk '{ print $2 }'
}


# View man documentation in Preview
pman () {
   man -t "${1}" | open -f -a /Applications/Preview.app/
}


pcurl() {
  curl "${1}" | open -f -a /Applications/Preview.app/
}

pri() {
  ri -T "${1}" | open -f -a /Applications/Preview.app/
}


# disk usage per directory
usage ()
{
  if [ $1 ]
  then
    du -hd $1
  else
    du -hd 1
  fi
}
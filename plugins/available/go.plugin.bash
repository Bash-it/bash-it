#!/usr/bin/env bash

cite about-plugin
about-plugin 'go environment variables & path configuration'

[ ! command -v go &>/dev/null ] && return

function _split_path_reverse() {
  local r=
  for p in ${@//:/ } ; do
    r="$p $r"
  done
  echo "$r"
}

export GOROOT=${GOROOT:-$(go env GOROOT)}
pathmunge "${GOROOT}/bin"

export GOPATH=${GOPATH:-$(go env GOPATH)}
for p in $( _split_path_reverse ${GOPATH} ) ; do
  pathmunge "${p}/bin"
done

#!/usr/bin/env bash

cite about-plugin
about-plugin 'go environment variables & path configuration'

[ ! command -v go &>/dev/null ] && return

export GOROOT=${GOROOT:-$(go env GOROOT)}
pathmunge "${GOROOT}/bin"
export GOPATH=${GOPATH:-$(go env GOPATH)}
pathmunge "${GOPATH}/bin"

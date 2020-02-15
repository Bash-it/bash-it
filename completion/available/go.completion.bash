#!/usr/bin/env bash

# bash completion for go tool
# https://github.com/posener/complete
# https://pkg.go.dev/github.com/posener/complete?tab=doc

# Install gocomplete:
# go get -u github.com/posener/complete/gocomplete
# gocomplete -install

if _command_exists gocomplete && _command_exists go ; then
  complete -C "${GOBIN}"/gocomplete go
fi

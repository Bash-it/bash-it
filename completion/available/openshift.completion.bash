#!/usr/bin/env bash

OCPATH=$(which oc)

[ -x "${OCPATH}" ] && eval "$(oc completion bash)" 

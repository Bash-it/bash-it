#!/usr/bin/env bash
which register-python-argcomplete > /dev/null \
  && eval "$(register-python-argcomplete conda)" \
  || echo "Please install argcomplete to use conda completion"

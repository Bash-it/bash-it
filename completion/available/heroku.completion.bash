#!/usr/bin/bash

if command -v heroku > /dev/null; then
    heroku autocomplete > /dev/null
    printf "$(heroku autocomplete:script bash)" >> ~/.bashrc; source ~/.bashrc
fi


#!/usr/bin/env bash

if _command_exists conda
then
    if _command_exists register-python-argcomplete
    then
        eval "$(register-python-argcomplete conda)"
    else
        _log_warning "Argcomplete not found. Please run 'conda install argcomplete'"
        return 1
    fi
fi

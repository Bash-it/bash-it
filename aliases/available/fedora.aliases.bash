#!/bin/bash
#zuck007
cite 'about-alias'
about-alias 'dnf aliases for fedora 22+ distros'

#set-dnf-aliases
function _set_dnf_aliases() 
{
    if [ -x $(which dnf) ];then
       
        alias dnfl="dnf list"                       # List packages
        alias dnfli="dnf list installed"            # List installed packages
        alias dnfgl="dnf grouplist"                 # List package groups
        alias dnfmc="dnf makecache"                 # Generate metadata cache
        alias dnfp="dnf info"                       # Show package information
        alias dnfs="dnf search"                     # Search package

        alias dnfu="sudo dnf upgrade"               # Upgrade package
        alias dnfi="sudo dnf install"               # Install package
        alias dnfgi="sudo dnf groupinstall"         # Install package group
        alias dnfr="sudo dnf remove"                # Remove package
        alias dnfgr="sudo dnf groupremove"          # Remove package group
        alias dnfc="sudo dnf clean all"             # Clean cache
    fi
}

_set_dnf_aliases


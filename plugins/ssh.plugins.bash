#!/bin/bash

function add_ssh() {
  echo -en "\n\nHost $1\n  HostName $2\n  User $3" >> ~/.ssh/config
}
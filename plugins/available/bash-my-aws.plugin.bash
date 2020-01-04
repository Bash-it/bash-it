cite about-plugin
about-plugin 'Bash My AWS'

export BASH_MY_AWS="${BASH_MY_AWS:-$HOME/.bash-my-aws}"

__bma_load() {
  force=$1
  if [[ -d "$BASH_MY_AWS" ]] ; then
    if [[ -z $force ]] || [[ ":$PATH:" != *":$BASH_MY_AWS/bin:"* ]] ; then
      pathmunge "$BASH_MY_AWS/bin"
      source "$BASH_MY_AWS/aliases"
      source "$BASH_MY_AWS/bash_completion.sh"
    fi
  fi
}

install-bash-my-aws() {
  about 'Install bash-my-aws'
  group 'bash-my-aws'

  if [[ ! -d "$BASH_MY_AWS" ]] ; then
    git clone https://github.com/bash-my-aws/bash-my-aws.git $BASH_MY_AWS
    echo "bash-my-aws successfully installed."
  else
    echo "bash-my-aws already installed."
  fi

  __bma_load
}

update-bash-my-aws() {
  about 'Update bash-my-aws to the latest'
  group 'bash-my-aws'

  if [[ ! -d "$BASH_MY_AWS" ]] ; then
    install-bash-my-aws
  else
    _bash-it-update-repo 'bash-my-aws' "${BASH_MY_AWS}"
  fi

  __bma_load
}

__bma_load

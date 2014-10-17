cite about-plugin
about-plugin 'load pipsi, if you are using it'

if [[ -f $HOME/.local/bin/pipsi ]]
then
    export PATH=~/.local/bin:$PATH
fi

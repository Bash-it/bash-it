# bash completion support for Hashicorp consul

if _command_exists consul
then
    complete -C "$(which consul)" consul
fi


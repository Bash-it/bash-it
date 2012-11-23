#mano aslias
if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=auto'
fi


if [ $(uname) = "Darwin" ]; then
        alias ls='gls $LS_OPTIONS -hF'
        alias ll='gls $LS_OPTIONS -lhF'
        alias l='gls $LS_OPTIONS -lAhF'

    elif [ $(uname) = "Linux" ]; then
        alias ls='ls $LS_OPTIONS -hF'
        alias ll='ls $LS_OPTIONS -lhF'
        alias l='ls $LS_OPTIONS -lAhF'
    fi


alias c='clear'
alias edit="$EDITOR"
alias pager="$PAGER"
alias ..='cd ..'         # Go up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up two directories
alias back='cd -'        # Go back
alias h='history'
alias md='mkdir -p'
alias rd='rmdir'



function sshcopyid {
    KEY="$HOME/.ssh/id_rsa.pub"
    if [ ! -f $KEY ];then
        echo "private key not found at $KEY"
        echo '* please create it with "ssh-keygen -t dsa"'
        echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password"
        return
    fi

    if [ -z $1 ];then
        echo "Please specify user@host.tld as the first switch to this script"
        return
    fi

    echo "Putting your public key on $1... "
    cat $KEY | ssh -q $1 "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; cat - >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"
    echo "done!"
}

function ql {
  (( $# > 0 )) && qlmanage -p "$@" &> /dev/null
}

# Delete .DS_Store and __MACOSX directories.
function rm-osx-cruft {
  find "${@:-$PWD}" \( \
    -type f -name '.DS_Store' -o \
    -type d -name '__MACOSX' \
  \) -print0 | xargs -0 rm -rf
}

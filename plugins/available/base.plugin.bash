cite about-plugin
about-plugin 'miscellaneous tools'

ips ()
{
    about 'display all ip addresses for this host'
    group 'base'
    ifconfig | grep "inet " | awk '{ print $2 }'
}

down4me ()
{
    about 'checks whether a website is down for you, or everybody'
    param '1: website url'
    example '$ down4me http://www.google.com'
    group 'base'
    curl -s "http://www.downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}

myip ()
{
    about 'displays your ip address, as seen by the Internet'
    group 'base'
    res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    echo -e "Your public IP is: ${echo_bold_green} $res ${echo_normal}"
}


pickfrom ()
{
    about 'picks random line from file'
    param '1: filename'
    example '$ pickfrom /usr/share/dict/words'
    group 'base'
    local file=$1
    [ -z "$file" ] && reference $FUNCNAME && return
    length=$(cat $file | wc -l)
    n=$(expr $RANDOM \* $length \/ 32768 + 1)
    head -n $n $file | tail -1
}

pass ()
{
    about 'generates random password from dictionary words'
    param 'optional integer length'
    param 'if unset, defaults to 4'
    example '$ pass'
    example '$ pass 6'
    group 'base'
    local i pass length=${1:-4}
    pass=$(echo $(for i in $(eval echo "{1..$length}"); do pickfrom /usr/share/dict/words; done))
    echo "With spaces (easier to memorize): $pass"
    echo "Without (use this as the pass): $(echo $pass | tr -d ' ')"
}

pmdown ()
{
    about 'preview markdown file in a browser'
    param '1: markdown file'
    example '$ pmdown README.md'
    group 'base'
    if command -v markdown &>/dev/null
    then
      markdown $1 | browser
    else
      echo "You don't have a markdown command installed!"
    fi
}

mkcd ()
{
    about 'make a directory and cd into it'
    param 'path to create'
    example '$ mkcd foo'
    example '$ mkcd /tmp/img/photos/large'
    group 'base'
    mkdir -p "$*"
    cd "$*"
}

lsgrep ()
{
    about 'search through directory contents with grep'
    group 'base'
    ls | grep "$*"
}


pman ()
{
    about 'view man documentation in Preview'
    param '1: man page to view'
    example '$ pman bash'
    group 'base'
    man -t "${1}" | open -f -a $PREVIEW
}


pcurl ()
{
    about 'download file and Preview it'
    param '1: download URL'
    example '$ pcurl http://www.irs.gov/pub/irs-pdf/fw4.pdf'
    group 'base'
    curl "${1}" | open -f -a $PREVIEW
}

pri ()
{
    about 'display information about Ruby classes, modules, or methods, in Preview'
    param '1: Ruby method, module, or class'
    example '$ pri Array'
    group 'base'
    ri -T "${1}" | open -f -a $PREVIEW
}

quiet ()
{
    about 'what *does* this do?'
    group 'base'
	$* &> /dev/null &
}

banish-cookies ()
{
    about 'redirect .adobe and .macromedia files to /dev/null'
    group 'base'
	rm -r ~/.macromedia ~/.adobe
	ln -s /dev/null ~/.adobe
	ln -s /dev/null ~/.macromedia
}

usage ()
{
    about 'disk usage per directory, in Mac OS X and Linux'
    param '1: directory name'
    group 'base'
    if [ $(uname) = "Darwin" ]; then
        if [ -n $1 ]; then
            du -hd $1
        else
            du -hd 1
        fi

    elif [ $(uname) = "Linux" ]; then
        if [ -n $1 ]; then
            du -h --max-depth=1 $1
        else
            du -h --max-depth=1
        fi
    fi
}

if [ ! -e $BASH_IT/plugins/enabled/todo.plugin.bash ]; then
# if user has installed todo plugin, skip this...
    t ()
    {
        about 'one thing todo'
        param 'if not set, display todo item'
        param '1: todo text'
        if [[ "$*" == "" ]] ; then
            cat ~/.t
        else
            echo "$*" > ~/.t
        fi
    }
fi

command_exists ()
{
    about 'checks for existence of a command'
    param '1: command to check'
    example '$ command_exists ls && echo exists'
    group 'base'
    type "$1" &> /dev/null ;
}

# useful for administrators and configs
buf ()
{
    about 'back up file with timestamp'
    param 'filename'
    group 'base'
    local filename=$1
    local filetime=$(date +%Y%m%d_%H%M%S)
    cp ${filename} ${filename}_${filetime}
}

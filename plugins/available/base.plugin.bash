cite about-plugin
about-plugin 'miscellaneous tools'

function ips ()
{
    about 'display all ip addresses for this host'
    group 'base'
    ifconfig | grep "inet " | awk '{ print $2 }'
}

function down4me ()
{
    about 'checks whether a website is down for you, or everybody'
    param '1: website url'
    example '$ down4me http://www.google.com'
    group 'base'
    curl -s "http://www.downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}

function myip ()
{
    about 'displays your ip address, as seen by the Internet'
    group 'base'
    res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    echo -e "Your public IP is: ${echo_bold_green} $res ${echo_normal}"
}


function pickfrom ()
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

function pass ()
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

function pmdown ()
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

function mkcd ()
{
    about 'make a directory and cd into it'
    param 'path to create'
    example '$ mkcd foo'
    example '$ mkcd /tmp/img/photos/large'
    group 'base'
    mkdir -p "$*"
    cd "$*"
}

function lsgrep ()
{
    about 'search through directory contents with grep'
    group 'base'
    ls | grep "$*"
}


function pman ()
{
    about 'view man documentation in Preview'
    param '1: man page to view'
    example '$ pman bash'
    group 'base'
    man -t "${1}" | open -f -a $PREVIEW
}


function pcurl ()
{
    about 'download file and Preview it'
    param '1: download URL'
    example '$ pcurl http://www.irs.gov/pub/irs-pdf/fw4.pdf'
    group 'base'
    curl "${1}" | open -f -a $PREVIEW
}

function pri ()
{
    about 'display information about Ruby classes, modules, or methods, in Preview'
    param '1: Ruby method, module, or class'
    example '$ pri Array'
    group 'base'
    ri -T "${1}" | open -f -a $PREVIEW
}

function quiet ()
{
    about 'what *does* this do?'
    group 'base'
	$* &> /dev/null &
}

function banish-cookies ()
{
    about 'redirect .adobe and .macromedia files to /dev/null'
    group 'base'
	rm -r ~/.macromedia ~/.adobe
	ln -s /dev/null ~/.adobe
	ln -s /dev/null ~/.macromedia
}

function usage ()
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
    function t ()
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

function command_exists ()
{
    about 'checks for existence of a command'
    param '1: command to check'
    example '$ command_exists ls && echo exists'
    group 'base'
    type "$1" &> /dev/null ;
}

mkiso ()
{

    about 'creates iso from current dir in the parent dir (unless defined)'
    param '1: ISO name'
    param '2: dest/path'
    param '3: src/path'
    example 'mkiso'
    example 'mkiso ISO-Name dest/path src/path'
    group 'base'

    if type "mkisofs" > /dev/null; then
        [ -z ${1+x} ] && local isoname=${PWD##*/} || local isoname=$1
        [ -z ${2+x} ] && local destpath=../ || local destpath=$2
        [ -z ${3+x} ] && local srcpath=${PWD} || local srcpath=$3

        if [ ! -f "${destpath}${isoname}.iso" ]; then
            echo "writing ${isoname}.iso to ${destpath} from ${srcpath}"
            mkisofs -V ${isoname} -iso-level 3 -r -o "${destpath}${isoname}.iso" "${srcpath}"
        else
            echo "${destpath}${isoname}.iso already exists"
        fi
    else
        echo "mkisofs cmd does not exist, please install cdrtools"
    fi
}

# useful for administrators and configs
function buf ()
{
    about 'back up file with timestamp'
    param 'filename'
    group 'base'
    local filename=$1
    local filetime=$(date +%Y%m%d_%H%M%S)
    cp ${filename} ${filename}_${filetime}
}

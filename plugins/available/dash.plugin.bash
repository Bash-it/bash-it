# Open manpages in Dash.app via:
#
# man <something>
#
cite about-plugin
about-plugin "Dash.app Man Pages Integration"

# To override the DocSet shortcut Man Pages name, export DASH_MAN_DOCSET somewhere.
DASH_MAN_DOCSET=${DASH_MAN_DOCSET-manpages}

if [[ `uname` != Darwin ]]; then
    echo The Dash.app plugin is only available on Mac OS X.  Sorry!
    exit 
elif [[ ! -d /Applications/Dash.app ]]; then
    echo To use the Dash.app plugin, install Dash.app from http://kapeli.com/dash
    exit 
elif [[ ! -d "$HOME/Library/Application Support/Dash/DocSets/Man_Pages" ]]; then
    echo To use the Dash.app plugin, install the "Man Pages" DocSet from within Dash.app.
    exit
else
    # http://stackoverflow.com/questions/296536/urlencode-from-a-bash-script
    # this enables to search multiple strings; "man git fetch" will find the "git" page and search for "fetch" within
    function rawurlencode() {
      local string="${@}"
      local strlen=${#string}
      local encoded=""
    
      for (( pos=0 ; pos<strlen ; pos++ )); do
         c=${string:$pos:1}
         case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
         esac
         encoded+="${o}"
      done
      echo "${encoded}"    # You can either set a return variable (FASTER) 
    }
    
    function dash_man {        
        /usr/bin/open dash://${DASH_MAN_DOCSET}:`rawurlencode ${@}`
    }
    
    alias man=dash_man        
fi 

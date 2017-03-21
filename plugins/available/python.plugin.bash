cite about-plugin
about-plugin 'alias "shttp" to SimpleHTTPServer'

if [ $(uname) = "Linux" ]
then
  alias shttp='python2 -m SimpleHTTPServer'
else
  alias shttp='python -m SimpleHTTPServer'
fi

function pyedit() {
    about 'opens python module in your EDITOR'
    param '1: python module to open'
    example '$ pyedit requests'
    group 'python'

    xpyc=`python -c "import os, sys; f = open(os.devnull, 'w'); sys.stderr = f; module = __import__('$1'); sys.stdout.write(module.__file__)"`

    if [ "$xpyc" == "" ]; then
        echo "Python module $1 not found"
        return -1

    elif [[ $xpyc == *__init__.py* ]]; then
        xpydir=`dirname $xpyc`;
        echo "$EDITOR $xpydir";
        $EDITOR "$xpydir";
    else
        echo "$EDITOR ${xpyc%.*}.py";
        $EDITOR "${xpyc%.*}.py";
    fi
}

cite about-plugin                                                                                        
about-plugin 'pygmentize instead of cat to terminal if possible'                                         

if [ -z $(which pygmentize) ]
then
    echo "Pygments is required to use this plugin"
    echo "Install it by doing 'pip install Pygments' as the superuser"
    exit 1
fi

# get the actual cat binary
CAT_BIN=$(which cat)

# replace the cat binary for a pygmentize if possible
cat()
{
    about 'runs either pygmentize or cat on each file passed in'
    param '*: files to concatenate (as normally passed to cat'
    example 'cat mysite/manage.py dir/text-file.txt'
    for var;
    do
        pygmentize "$var" 2>/dev/null || "$CAT_BIN" "$var";
    done
}

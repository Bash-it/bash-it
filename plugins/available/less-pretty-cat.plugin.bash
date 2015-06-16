cite about-plugin                                                                                        
about-plugin 'pygmentize instead of cat to terminal if possible'                                         

if [ -z $(which pygmentize) ]
then
    echo "Pygments is required to use this plugin"
    echo "Install it by doing 'pip install Pygments' as the superuser"
fi

# get the full paths to binaries
CAT_BIN=$(which cat)
LESS_BIN=$(which less)

# pigmentize cat and less outputs
cat()
{
    about 'runs either pygmentize or cat on each file passed in'
    param '*: files to concatenate (as normally passed to cat)'
    example 'cat mysite/manage.py dir/text-file.txt'
    for var;
    do
        pygmentize "$var" 2>/dev/null || "$CAT_BIN" "$var";
    done
}

less()
{
    about 'it pigments the file passed in and passes it to less for pagination'
    param '$1: the file to paginate with less'
    example 'less mysite/manage.py'
    pygmentize "$*" | "$LESS_BIN" -R
}

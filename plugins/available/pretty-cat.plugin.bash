cite about-plugin                                                                                        
about-plugin 'pygmentize instead of cat to terminal if possible'                                         

if [ -z $(which pygmentize) ]                                                                            
then                                                                                                     
    echo "Pygments is required to use this pluging"                                                      
    echo "Install it by doing 'pip install Pygments' as the superuser"                                   
    exit                                                                                                 
fi                                                                                                       

# get the actual cat binary                                                                              
CAT_BIN=$(which cat)                                                                                     

# replace the cat binary for a pygmentize if possible                                                    
cat()                                                                                                    
{                                                                                                        
    for var;                                                                                             
    do                                                                                                   
        pygmentize "$var" 2>/dev/null || "$CAT_BIN" "$var";                                              
    done                                                                                                 
}

# Open the root of your site in your vim or builtin cd to it

if [[ $EDITOR = "vim" ]]
then 
	alias newentry="builtin cd $JEKYLL_LOCAL_ROOT && $EDITOR ."
else 
	alias newentry="builtin cd $JEKYLL_LOCAL_ROOT"
fi

# Build and locally serve the site

alias testsite="builtin cd $JEKYLL_LOCAL_ROOT && jekyll --server --auto"

# Build but don't locally serve the site

alias buildsite="builtin cd $JEKYLL_LOCAL_ROOT && rm -rf _site/ && jekyll"

# Rsync the site to the remote server

alias deploysite="builtin cd $JEKYLL_LOCAL_ROOT && rsync -rz _site/ $JEKYLL_REMOTE_ROOT"

alias jkas="jekyll --auto --server"
alias rmjkas="rm -rf _site/* && jkas"
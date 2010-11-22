# Open the root of your site in your vim or cd to it

if [[ $EDITOR = "vim" ]]
then alias newentry="cd $JEKYLL_LOCAL_ROOT && $EDITOR ."
else alias newentry="cd $JEKYLL_LOCAL_ROOT"
fi

# Open the _posts/ directory for making a new blog post (seperate from above alias because not everyone uses jekyll for a blog)

# if [ $editor = "vim" ]
# then
# 	alias newpost="cd $jekyll_local_root/_posts && $editor ."
# else
# 	alias newpost="cd $jekyll_local_root"
# fi

# Build and locally serve the site

alias testsite="cd $JEKYLL_LOCAL_ROOT && jekyll --server --auto"

# Build but don't locally serve the site

alias buildsite="cd $JEKYLL_LOCAL_ROOT && rm -rf _site/ && jekyll"

# Rsync the site to the remote server

alias deploysite="cd $JEKYLL_LOCAL_ROOT && rsync -rz _site/ $JEKYLL_REMOTE_ROOT"

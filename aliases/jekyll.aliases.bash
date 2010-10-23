# Open the root of your site in your favorite editor

alias newentry="cd $JEKYLL_LOCAL_ROOT && $EDITOR ."

# Open the _posts/ directory for making a new blog post (seperate from above alias because not everyone uses jekyll for a blog)

alias newpost="cd $JEKYLL_LOCAL_ROOT/_posts && $EDITOR ."

# Build and locally serve the site

alias testsite="cd $JEKYLL_LOCAL_ROOT && jekyll --server --auto"

# Build but don't locally serve the site

alias buildsite="cd $JEKYLL_LOCAL_ROOT && rm -rf _site/ && jekyll"

# Rsync the site to the remote server

alias deploysite="cd $JEKYLL_LOCAL_ROOT && rsync -rz _site/ $JEKYLL_REMOTE_ROOT"

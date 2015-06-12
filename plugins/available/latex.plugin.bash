cite about-plugin
about-plugin 'use mactex'

# add mactex to the path if its present
MACTEX_PATH=/usr/local/texlive/2009/bin/universal-darwin
if [[ -d  $MACTEX_PATH ]]; then
  pathmunge $MACTEX_PATH after
fi
unset MACTEX_PATH

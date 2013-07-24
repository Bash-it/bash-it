cite about-plugin
about-plugin 'Add Sublime Text cli binary "subl" to path'

SUBL_BIN="/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl"
SUBL_LOCAL_DIR=$BASH_IT/.subl-bin/
SUBL_LOCAL_BIN=$BASH_IT/.subl-bin/subl

if [ ! -f $SUBL_LOCAL_BIN ]; then
  mkdir -p $SUBL_LOCAL_DIR
  ln -s "$SUBL_BIN" $SUBL_LOCAL_BIN
fi

export PATH=$PATH:$SUBL_LOCAL_DIR

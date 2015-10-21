cite about-plugin
about-plugin 'Defines the `code` executable for Visual Studio Code on OS X'

# Based on https://code.visualstudio.com/Docs/editor/setup
if [[ `uname -s` == "Darwin" ]]; then
  function code () {
    about 'Starts Visual Studio Code in the provided directory'
    group 'visual-studio-code'

    VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;
  }
fi

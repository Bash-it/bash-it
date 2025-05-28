#!/bin/bash

# -------------------------------
# Change these variables to match your app:
# -------------------------------

APP_NAME="MyApp"                   # The name of your application
INSTALL_DIR="$HOME/$APP_NAME"      # Where your app will be installed (in user home folder)
EXECUTABLE="MyApp.sh"              # The name of your launch script or executable inside the folder
ICON="icon.png"                   # The icon file name inside your app folder
WMCLASS="MyAppWindowClass"        # The WM_CLASS string of your app window for taskbar grouping

# -------------------------------
# Do not change below unless you know what you're doing
# -------------------------------

# Create the install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Copy all files from current directory to install directory
cp -r ./* "$INSTALL_DIR/"

# Create a .desktop file for your app in the user's applications directory
cat > ~/.local/share/applications/$APP_NAME.desktop <<EOF
[Desktop Entry]
Name=$APP_NAME                                  # The app name shown in menus
Comment=A great application                     # A short description of your app
Exec=$INSTALL_DIR/$EXECUTABLE                   # Full path to the launch script or executable
Icon=$INSTALL_DIR/$ICON                          # Full path to the icon file
Terminal=false                                  # Set to true if your app needs terminal
Type=Application
Categories=Utility;                             # Change categories if needed (e.g. Game; Development;)
StartupWMClass=$WMCLASS                         # Helps group app windows in taskbar; see xprop for your app's WM_CLASS
EOF

# Make the executable script or binary runnable
chmod +x "$INSTALL_DIR/$EXECUTABLE"

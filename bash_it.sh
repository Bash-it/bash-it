# Initialize Bash It

# Reload Library
alias reload='source ~/.bash_profile'

# Load all files

# Library
LIB="${BASH}/lib/*.bash"
for config_file in $LIB
do
  source $config_file
done

# Tab Completion
COMPLETION="${BASH}/completion/*.bash"
for config_file in $COMPLETION
do
  source $config_file
done


# Plugins
PLUGINS="${BASH}/plugins/*.bash"
for config_file in $PLUGINS
do
  source $config_file
done

# Themes
THEMES="${BASH}/themes/*.bash"
for config_file in $THEMES
do
  source $config_file
done

# Functions
FUNCTIONS="${BASH}/functions/*.bash"
for config_file in $FUNCTIONS
do
  source $config_file
done

# Custom
CUSTOM="${BASH}/custom/*.bash"
for config_file in $CUSTOM
do
  source $config_file
done
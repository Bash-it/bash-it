# shellcheck shell=bash
# BASH_IT_LOAD_PRIORITY: 200

# Autoenv Plugin for Bash-it with automatic cleanup
# Automatically loads .env files when changing directories
# Automatically unsets variables when leaving directories

cite about-plugin
about-plugin 'Automatically loads .env files and cleans up when leaving directories'

# Global tracking for autoenv state
declare -A _AUTOENV_PROCESSED_DIRS     # Track processed directories
declare -A _AUTOENV_DIR_VARS           # Map directories to their variables
declare -A _AUTOENV_VAR_SOURCES        # Map variables to their source directories
declare _AUTOENV_LAST_PWD=""           # Track last working directory

_autoenv_init() {
    typeset target home _file current_dir
    typeset -a _files
    target=$1
    home="${HOME%/*}"

    _files=($(
        current_dir="$target"
        while [[ "$current_dir" != "/" && "$current_dir" != "$home" ]]; do
            _file="$current_dir/.env"
            if [[ -e "${_file}" ]]; then
                echo "${_file}"
            fi
            # Move to parent directory
            current_dir="$(dirname "$current_dir")"
        done
    ))

    # Process files in reverse order (from root to current directory)
    local _file_count=${#_files[@]}
    local i
    for ((i = _file_count - 1; i >= 0; i--)); do
        local env_file="${_files[i]}"
        local env_dir="$(dirname "$env_file")"
        
        # Only process if this directory hasn't been processed yet
        # OR if it was processed but its variables were cleaned up
        if [[ -z "${_AUTOENV_PROCESSED_DIRS[$env_dir]}" ]] || [[ -z "${_AUTOENV_DIR_VARS[$env_dir]}" ]]; then
            echo "Processing $env_file"
            _autoenv_process_file "$env_file" "$env_dir"
            _AUTOENV_PROCESSED_DIRS[$env_dir]=1
        fi
    done
}

_autoenv_process_file() {
    local env_file="$1"
    local env_dir="$2"
    local line key value original_line line_number=0
    local -a dir_vars=()
    
    # Check if file is readable
    if [[ ! -r "$env_file" ]]; then
        echo "Warning: Cannot read $env_file" >&2
        return 1
    fi
    
    # Read the file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number++))
        original_line="$line"
        
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Remove leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        
        # Check if line matches KEY=value pattern
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # Validate key name (additional safety check)
            if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
                echo "Warning: Invalid variable name '$key' at line $line_number in $env_file" >&2
                continue
            fi
            
            # Handle quoted values (remove outer quotes if present)
            if [[ "$value" =~ ^\"(.*)\"$ ]]; then
                value="${BASH_REMATCH[1]}"
            elif [[ "$value" =~ ^\'(.*)\'$ ]]; then
                value="${BASH_REMATCH[1]}"
            fi
            
            # Export the variable silently
            export "$key=$value"
            
            # Track the variable
            dir_vars+=("$key")
            _AUTOENV_VAR_SOURCES["$key"]="$env_dir"
            
        else
            echo "Warning: Skipping invalid line $line_number in $env_file: $original_line" >&2
        fi
    done < "$env_file"
    
    # Store variables for this directory
    if [[ ${#dir_vars[@]} -gt 0 ]]; then
        _AUTOENV_DIR_VARS["$env_dir"]="${dir_vars[*]}"
    fi
}

# Check if a directory is an ancestor of the current directory
_autoenv_is_ancestor() {
    local ancestor="$1"
    local current="$PWD"
    
    # Normalize paths (remove trailing slashes)
    ancestor="${ancestor%/}"
    current="${current%/}"
    
    # Check if current path starts with ancestor path
    [[ "$current" == "$ancestor"* ]]
}

# Clean up variables from directories we've left
_autoenv_cleanup() {
    local dir var_list var
    
    # Check each directory we've processed
    for dir in "${!_AUTOENV_DIR_VARS[@]}"; do
        # If this directory is no longer an ancestor of current directory
        if ! _autoenv_is_ancestor "$dir"; then
            var_list="${_AUTOENV_DIR_VARS[$dir]}"
            
            # Unset each variable from this directory
            for var in $var_list; do
                if [[ "${_AUTOENV_VAR_SOURCES[$var]}" == "$dir" ]]; then
                    echo "Unsetting $var (from $dir)"
                    unset "$var"
                    unset "_AUTOENV_VAR_SOURCES[$var]"
                fi
            done
            
            # Remove directory from tracking AND clear its processed status
            unset "_AUTOENV_DIR_VARS[$dir]"
            unset "_AUTOENV_PROCESSED_DIRS[$dir]"
        fi
    done
}

# Main prompt command function
_autoenv_prompt_command() {
    local current_dir="$PWD"
    
    # If directory changed, perform cleanup first
    if [[ "$current_dir" != "$_AUTOENV_LAST_PWD" ]]; then
        _autoenv_cleanup
        _AUTOENV_LAST_PWD="$current_dir"
    fi
    
    # Always try to initialize the current directory and its ancestors
    # The _autoenv_init function will handle checking if processing is needed
    _autoenv_init "$current_dir"
}

# Public function for manual use
autoenv() {
    case "$1" in
        "reload"|"refresh")
            # Clear all tracking and reload
            _autoenv_clear_all
            _autoenv_init "$PWD"
            ;;
        "status")
            echo "Processed directories:"
            for dir in "${!_AUTOENV_PROCESSED_DIRS[@]}"; do
                echo "  $dir"
            done
            echo
            echo "Active variables by directory:"
            for dir in "${!_AUTOENV_DIR_VARS[@]}"; do
                echo "  $dir: ${_AUTOENV_DIR_VARS[$dir]}"
            done
            echo
            echo "Variable sources:"
            for var in "${!_AUTOENV_VAR_SOURCES[@]}"; do
                echo "  $var -> ${_AUTOENV_VAR_SOURCES[$var]}"
            done
            ;;
        "clean"|"cleanup")
            _autoenv_cleanup
            ;;
        "clear")
            _autoenv_clear_all
            ;;
        *)
            _autoenv_init "${1:-$PWD}"
            ;;
    esac
}

# Clear all autoenv state and unset tracked variables
_autoenv_clear_all() {
    local var
    
    # Unset all tracked variables
    for var in "${!_AUTOENV_VAR_SOURCES[@]}"; do
        echo "Clearing $var"
        unset "$var"
    done
    
    # Clear all tracking arrays
    unset _AUTOENV_PROCESSED_DIRS
    unset _AUTOENV_DIR_VARS
    unset _AUTOENV_VAR_SOURCES
    
    # Reinitialize arrays
    declare -A _AUTOENV_PROCESSED_DIRS
    declare -A _AUTOENV_DIR_VARS
    declare -A _AUTOENV_VAR_SOURCES
    
    _AUTOENV_LAST_PWD=""
}

# Hook into bash-it's prompt command system
safe_append_prompt_command '_autoenv_prompt_command'

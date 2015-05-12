cite about-plugin
about-plugin 'AWS helper functions'

function awskeys {
    about 'helper function for AWS credentials file'
    group 'aws'
    if [[ $# -eq 0 ]]; then
        __awskeys_help
    elif [[ $# -eq 1 ]] && [[ "$1" = "list" ]]; then
        __awskeys_list "$2"
    elif [[ $# -eq 2 ]]; then
        if [[ "$1" = "show" ]]; then
            __awskeys_show "$2"
        elif [[ "$1" = "export" ]]; then
            __awskeys_export "$2"
        else
            __awskeys_help
        fi
    else
        __awskeys_help
    fi
}

function __awskeys_help {
    echo -e "Usage: awskeys [COMMAND] [profile]\n"
    echo -e "Helper to AWS credentials file.\n"
    echo -e "Commands:\n"
    echo "   help    Show this help message"
    echo "   list    List available credentials profiles"
    echo "   show    Show the keys associated to a credentials profile"
    echo "   export  Export a credentials profile keys as environment variables"
}

function __awskeys_get {
    local ln=$(grep -n "\[ *$1 *\]" ~/.aws/credentials | cut -d ":" -f 1)
    if [[ -n "${ln}" ]]; then
        tail -n +${ln} ~/.aws/credentials | egrep -m 2 "aws_access_key_id|aws_secret_access_key"
    fi
}

function __awskeys_list {
    local credentials_list="$(egrep '^\[ *[a-zA-Z0-0_-]+ *\]$' ~/.aws/credentials)"
    if [[ -n $"{credentials_list}" ]]; then
        echo -e "Available credentials profiles:\n"
        for cred in ${credentials_list}; do
            echo "    $(echo ${cred} | tr -d "[]")"
        done
        echo
    else
        echo "No profiles found in credentials file"
    fi
}

function __awskeys_show {
    local p_keys="$(__awskeys_get $1)"
    if [[ -n "${p_keys}" ]]; then
        echo "${p_keys}"
    else
        echo "Profile $1 not found in credentials file"
    fi
}

function __awskeys_export {
    local p_keys="$(__awskeys_get $1)"
    if [[ -n "${p_keys}" ]]; then
        eval $(echo "${p_keys}" | tr -d " " | sed -r -e "s/(.+=)(.+)/export \U\1\E\2/")
        export AWS_DEFAULT_PROFILE="$1"
    else
        echo "Profile $1 not found in credentials file"
    fi
}


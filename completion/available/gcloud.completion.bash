#/usr/bin/env bash
# Bash completion for Google Cloud SDK

if _command_exists gcloud
then
    # get install path
    GOOGLE_SDK_ROOT=${GOOGLE_SDK_ROOT:-$(gcloud info --format="value(installation.sdk_root)")}

    # souce all the bash completion file that are available
    for i in $(ls ${GOOGLE_SDK_ROOT}/*.bash.inc); do
        source $i
    done
fi

#!/usr/bin/env bash
############################################################
# Hello World example to use batshell utility              #
############################################################

#needed variables
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(dirname -- "${SCRIPT_DIR}")
source $SCRIPT_DIR/include/common.sh

Help() {
    # Display Help
    padprint "Hello World example to use batshell utility"
    exit 1
}

print "Hello world." "Green"

scriptEnding

#!/usr/bin/env bash

#maximum character to display table with calculated end of line
MAX_CHAR=80

# Needed variables :
#   You have to copy this lines in your script before including this file
#
CURRENT_SCRIPT_FULLPATH=$(readlink -f "$0")
CURRENT_DIR=${BASH_SOURCE%/*}
ROOT_DIR=$(dirname $(dirname "$CURRENT_DIR"))
FILENAME=$(basename "$0")
SCRIPT_NAME="${FILENAME%.*}"
ERROR_FILE=/tmp/tmp.err
#
#   Then you can include this file
# source

#region COLORS VARIABLES
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source $SCRIPT_DIR/colors.sh
#endregion

#print function to add current datetime to the echo function
# usage print "test to print" "color"
# example: print "Hello" "Blue"
function print() {
    theDate=$(date +"%Y-%m-%d %H:%M:%S")
    if [ $2 ]; then
        eval "chosenColor=\$$2"
        echo -e "$theDate : ${chosenColor}${1}${NC}"
    else
        echo "$theDate : $1"
    fi
}

function deleteErrorFile() {
    if [ -f "$ERROR_FILE" ]; then
        print "Deleting error file $ERROR_FILE" "Purple"
        rm $ERROR_FILE
    fi
}

#format size (48832200 => 46.58Mio) and set it into the $2 parameter variable
#usage: humanSize 48832200 THE_VARIABLE
function humanSize() {
    eval "$2=\$(numfmt --to=iec-i --suffix=o --format="%9.2f" $1)"
}

#region pad printing function to fill all the line with spaces
function padprint() {
    print "$(printf " %-${MAX_CHAR}s \n" "$1")" "$2"
}
pad=$(printf '%*s' "$MAX_CHAR")
pad=${pad// /-}
#endregion

#region scriptStarting
START_TIME=$SECONDS
print "$pad"
padprint "Start of script $CURRENT_SCRIPT_FULLPATH" "Purple"
print "$pad"
#endregion

#ending function to display execution time at the end
function scriptEnding() {
    print "$pad"
    ELAPSED_TIME=$(($SECONDS - $START_TIME))
    padprint "End of script $CURRENT_SCRIPT_FULLPATH" "Purple"
    padprint "Duration: $(($ELAPSED_TIME / 60)) min $(($ELAPSED_TIME % 60)) sec" "Purple"
    print "$pad"
}

#Function: create MySQL config file from ENV string sent in parameter
# ex: createMySQLConfigFile AWS
# .env file must be filled with all needed parameters:
#   {ENV}_DATABASE_DBNAME,
#   {ENV}_DATABASE_USER,
#   {ENV}_DATABASE_PASSWORD,
#   {ENV}_DATABASE_HOST,
#   {ENV}_DATABASE_PORT
function createMySQLConfigFile() {
    copyFile=false
    CNF_TEMPLATE_FILE="mysql.cnf"
    DBNAME=$1
    DBUSER="${DBNAME^^}_DATABASE_USER"
    DBPASSWORD="${DBNAME^^}_DATABASE_PASSWORD"
    DBHOST="${DBNAME^^}_DATABASE_HOST"
    DBPORT="${DBNAME^^}_DATABASE_PORT"
    destinationFile="$ROOT_DIR/.mysql_${DBNAME}.cnf"

    error=false
    if [ "${!DBUSER}" == "" ]; then 
        print "Variable ${!DBUSER} does not exist for DB ${DBNAME}."
        error=true
    fi
    if [ "${!DBPASSWORD}" == "" ]; then 
        print "Variable $DBPASSWORD does not exist for DB ${DBNAME}."
        error=true
    fi
    if [ "${!DBPORT}" == "" ]; then 
        print "Variable $DBPORT does not exist for DB ${DBNAME}."
        error=true
    fi
    if [ "${!DBHOST}" == "" ]; then 
        print "Variable $DBHOST does not exist for DB ${DBNAME}."
        error=true
    fi
    if [ "$error" = true ]; then
        exit
    fi

    content=$(cat $ROOT_DIR/etc/template/$CNF_TEMPLATE_FILE | sed "s/@user/${!DBUSER}/g" | sed "s/@password/${!DBPASSWORD}/g" | sed "s/@host/${!DBHOST}/g" | sed "s/@port/${!DBPORT}/g")

    if [ ! -f $destinationFile ]; then #test if the file exists
        print "Config file $destinationFile does not exist."
        copyFile=true
    elif [[ $(<$destinationFile) != "$content" ]]; then #test if the files are different
        print "Config file $destinationFile is different."
        copyFile=true
    fi

    if [ "$copyFile" = true ]; then
        print "Copying content to $destinationFile"
        echo "$content" | tee $destinationFile >/dev/null
        print "$pad"
    fi
}

#load .env variables
envIsLoaded=false
if [ -f $ROOT_DIR/.env ]; then
    print "loading .env" "Black"
    source $ROOT_DIR/.env
    envIsLoaded=true
fi
if [ -f $ROOT_DIR/.env.local ]; then
    print "loading .env.local" "Black"
    source $ROOT_DIR/.env.local
    envIsLoaded=true
fi
if [ -f $ROOT_DIR/.env.$APP_ENV ]; then
    print "loading .env.$APP_ENV" "Black"
    source $ROOT_DIR/.env.$APP_ENV
    envIsLoaded=true
fi
if [ -f $ROOT_DIR/.env.$APP_ENV.local ]; then
    print "loading .env.$APP_ENV.local" "Black"
    source $ROOT_DIR/.env.$APP_ENV.local
    envIsLoaded=true
fi
if [ envIsLoaded ]; then
    print "$pad"
fi

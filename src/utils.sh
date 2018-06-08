#!/usr/bin/env bash

# Check if argument an integer
is_int()
{
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Check if argument empty
#
# param must not be quoted
empty()
{
    [[ -z "$1" || $# -eq 0 || "$1" = "" ]]
}

# Check if argument an existing file
file_exists()
{
    [ -f "$1" ]
}

# Check if argument an existing directory
dir_exists()
{
    [ -d "$1" ]
}

# Check if given data is an element of given array
in_array () {
    local NEEDLE="$1"

    shift

    for e; do
        [ "$e" = "$NEEDLE" ] && return 0
    done

    return 1
}

# Run given function, or exit status, then response to its returned value by another function and/or echoing given string.
#
# Usage: test FUNCTION [options]
test()
{
    # echo -e "\nTesting..."

    local CMD=""
    local CMD_ARGS=""
    local TRUE_ECHO=""
    local FALSE_ECHO=""
    local TRUE_EXEC=""
    local FALSE_EXEC=""
    local TRUE_EXIT=1
    local FALSE_EXIT=1
    local RETURNED=""

    while [ $# -ne 0 ]; do
        case "$1" in
            # Echo given string when condition returns true
            --true-echo | --te)
                shift
                TRUE_ECHO="$1"
            ;;
            # Echo given string when condition returns false
            --false-echo | --fe)
                shift
                FALSE_ECHO="$1"
            ;;
            # Run given function when condition returns true
            --true-exec | --txec)
                shift
                TRUE_EXEC="$1"
            ;;
            # Run given function when condition returns false
            --false-exec | --fxec)
                shift
                FALSE_EXEC="$1"
            ;;
            # Exit when condition returns true
            --true-exit | --txit)
                TRUE_EXIT=0
            ;;
            # Exit when condition returns false
            --false-exit | --fxit)
                FALSE_EXIT=0
            ;;
            # If the argument is not a flag, it's a command or command's arguments
            *)
                if [ "$CMD" = "" ]; then
                    CMD="$1"
                else
                    CMD_ARGS="${CMD_ARGS}$1 "
                fi
            ;;
        esac

        shift

    done

    # Check if given CMD is a command or an exit status
    local IS_COMMAND=$(command -v "$CMD")

    # echo "Cmd: $CMD"
    # echo "Cmd_args: $CMD_ARGS"
    # echo "IS_COMMAND: $IS_COMMAND"

    if [ -z "$IS_COMMAND" ]; then RETURNED="$CMD"
    else 
        # echo "command: $CMD $CMD_ARGS"

        $CMD $CMD_ARGS
        
        RETURNED=$?

        # echo "RETURNED: $RETURNED"
    fi

    # echo "Returned: $RETURNED"
    
    # Test given command/exit status
    # then execute options based on its returned value
    if [ "$RETURNED" -eq 0 ]; then
        [ "$TRUE_ECHO" != "" ] && echo -e "$TRUE_ECHO"
        $TRUE_EXEC # run command, if exists
        [ $TRUE_EXIT -eq 0 ] && exit 0
        return 0
    else
        [ "$FALSE_ECHO" != "" ] && echo -e "$FALSE_ECHO"
        $FALSE_EXEC # run command, if exists
        [ $FALSE_EXIT -eq 0 ] && exit 1
        return 1
    fi
}

# Import script
import()
{
    source "${APP_SOURCE_DIR}/${1}.sh"
}

load_env()
{
    test file_exists "$1" \
        --fe "Environment variable file not found. '$1'" \
        --fxit

    source "$1"
}

# Get environment variable with default value
env()
{
    local var="${!1}"
    # local value=""

    # bold "var" "$var"
    # bold "1" "$1"
    # bold "2" "$2"

    if [ -z "$var" ]
    then
        echo "$2"
    else
        echo "$var"
    fi
}
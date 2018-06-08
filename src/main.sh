#!/usr/bin/env bash

if [ $# -eq 0 ] 
then
    echo "help"
    exit    
fi

source "./.env"
source "./src/utils.sh"
import "output"
# import "env_check"

SITES_AVAILABLE="$(env "WPTH_SITES_AVAILABLE" "./sites-availalbe")"
SITES_ENABLED="$(env "WPTH_SITES_ENABLED" "./sites-enabled")"
HOSTS_FILE="$(env "WPTH_HOSTS_FILE" "/etc/hosts")"

ensite()
{
    test empty "${1}" \
        --te "$(err "No sitename given.")" \
        --txit
        
    local filename="${1}.conf"
    local availFile="${SITES_AVAILABLE}/${filename}"

    test file_exists "$availFile" \
        --fe "$(err "Site config file name '$filename' not found in '$availFile'" "ensite")"

    if [ $? -eq 0 ]
    then
        ln -s "$availFile" "${SITES_ENABLED}/${filename}"

        test $? \
            --te "$(success "Site '$1' is enabled.")" \
            --fe "$(err "Failed to enable site '$1'" "ensite")"
    fi
}

dissite()
{
    test empty "${1}" \
        --te "$(err "No sitename given.")" \
        --txit

    local filename="${1}.conf"
    local enabledFile="${SITES_ENABLED}/${filename}"
    
    test file_exists "$enabledFile" \
        --fe "$(err "Site config file name '$filename' not found in '$enabledFile'" "dissite")"

    if [ $? -eq 0 ]
    then
        rm "$enabledFile"

        test $? \
            --te "$(success "Site '$1' is disabled.")" \
            --fe "$(err "Failed to disable site '$1'" "dissite")"
    fi
}

addhost()
{
    test empty "${1}" \
        --te "$(err "No host IP address given.")" \
        --txit

    test empty "${2}" \
        --te "$(err "No hostname given.")" \
        --txit

    local ip="$1"
    shift
    local name=""

    [[ "$ip" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]
    
    test $? \
        --fe "$(err "'$ip' is an invalid IP address.")" \
        --fxit

    for n in "$@"
    do
        [[ "$n" =~ ^[a-zA-Z.-]+$ ]] && name="${name}${n} " || err "$n is an invalid hostname."
    done
    
    # Append with comment
    echo -e "# Added by wpth\n${ip}\t${name}\n" >> $HOSTS_FILE

    test $? \
        --fe "$(err "Failed to add hostname to '$HOSTS_FILE'")" \
        --te "$(success "Hostname added.")" \
        --fxit
}

removehost()
{
    local pattern=$(cat "$HOSTS_FILE" | grep -Pm 1 -B 1 "\s$1\s")
    local comment=$(echo "$pattern" | head -n 1)
    local hostinfo=$(echo "$pattern" | tail -n 1)

    # bold "pattern" "$pattern"
    # bold "comment" "$comment"
    # bold "hostinfo" "$hostinfo"
    # exit

    test empty "$pattern" \
        --te "$(err "Hostname '$1' not found.")" \
        --txit

    sed -i "/$comment/d; /$hostinfo/d" $HOSTS_FILE 

    test $? \
        --te "$(success "Host '$pattern' removed")" \
        --fe "$(err "Failed to remove host '$1'")"
}


while [ $# -ne 0 ] 
do
    case "$1" in
        ensite) 
            shift
            ensite "$@"
            exit
        ;;
        dissite)
            shift
            dissite "$@"
            exit
        ;;
        addhost)
            shift
            addhost "$@"
            exit
        ;;
        removehost)
            shift
            removehost "$@"
            exit
        ;;
    esac

    shift
    
done
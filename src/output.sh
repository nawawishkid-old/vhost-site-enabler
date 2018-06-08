t_bold=$(tput bold) # bold text
t_normal="$(tput sgr0)\033[0m" # normal text
t_error="\033[1;31m" # bright red
t_warn="\033[1;33m" # bright yellow
t_success="\033[1;32m" # bright green

# Makes given text bold then print it
o_bold()
{
    printf "${t_bold}$1${t_normal}"
}

# Colorize given text to $t_error color then print it
o_error()
{
    printf "${t_error}$1${t_normal}"
}

# Colorize given text to $t_warn color then print it
o_warn()
{
    printf "${t_warn}$1${t_normal}"
}

# Colorize given text to $t_success color then print it
o_success()
{
    printf "${t_success}$1${t_normal}"
}

# Echo given string as 'key: value' pair
# Usage: out_pair KEY VALUE TYPE
out_pair()
{
    local KEY="$1"
    local VALUE="$2"
    local TYPE="$3"

    case "$TYPE" in
        bold)
            echo -e "$(o_bold "$KEY"): "$VALUE""
            ;;
        success)
            echo -e "$(o_success "$KEY"): "$VALUE""
            ;;
        error)
            echo -e "$(o_error "$KEY"): "$VALUE""
            ;;
        warn)
            echo -e "$(o_warn "$KEY"): "$VALUE""
            ;;
    esac
}

# Each function below are a high-level implementation of out_pair() for easier usage

bold()
{
    out_pair "$1" "$2" bold
}

warn()
{
    out_pair "\nWARNING" "${1}" warn
}

err()
{
    out_pair "\nERROR" "${1}\nUse '${APP_NAME} ${2} --help' for more information." error
}

success()
{
    out_pair "\nSUCCESS" "${1}" success
}

# ---------------

# Show help text by given doc name
help()
{
    cat "${DOC_DIR}/${1}.md"
}
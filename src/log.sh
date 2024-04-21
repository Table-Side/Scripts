#!/usr/bin/env bash

# -----------------------------------------------------------------------------

LOGGER_INCLUDED=true

function BANNER() {
    echo -e " _____      _     _      __ _     _      " >&2
    echo -e "/__   \__ _| |__ | | ___/ _(_) __| | ___ " >&2
    echo -e "  / /\/ _\` | '_ \| |/ _ \ \| |/ _\` |/ _ \\" >&2
    echo -e " / / | (_| | |_) | |  __/\ \ | (_| |  __/" >&2
    echo -e " \/   \__,_|_.__/|_|\___\__/_|\__,_|\___|" >&2
    echo -e "                                         " >&2
    echo -e "" >&2
    echo -e "     $1" >&2
    echo -e "" >&2
}

function SKIP_LINE() {
    echo -e "" >&2
}

function DEBUG() {
    if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "1" ]; then
        echo -e "\033[1;34mDEBUG: $1\033[0m" >&2
    fi
}

function INFO() {
    echo -e "\033[1;32mINFO: $1\033[0m" >&2
}

function WARN() {
    echo -e "\033[1;33mWARN: $1\033[0m" >&2
}

function ERROR() {
    echo -e "\033[1;31mERROR: $1\033[0m" >&2
}


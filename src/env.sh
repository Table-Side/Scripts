#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------

# User Credentials
USERNAME=""
PASSWORD=""

# OpenID Connect (OIDC) Configuration
CLIENT_ID=""
CLIENT_SECRET=""
GRANT_TYPE=""
SCOPE=""

# Base URLs for API
BASE_URL_OIDC_AUTH="https://auth.tableside.site"
BASE_URL_API="https://api.tableside.site"

# -----------------------------------------------------------------------------

# Load Environment Variables
# 
# This function loads the specified environment variable from the environment
# or from the environment file (.env) in the specified location.
#
# If the variable is not set and a default value is provided, the default value
# is used. If the variable is not set and no default value is provided, the
# user is prompted to enter the value.
#
# Usage:
#   load_env_var ENV_FILE_LOCATION VAR_NAME [DEFAULT_VALUE]
#
# Example:
#   load_env_var "/path/to/env" "USERNAME"
#   load_env_var "/path/to/env" "SCOPE" "openid"
function load_env_var() {
    # If $3 is set, it's the default value, otherwise the variable is required.
    if [ -z "${!2:-}" ]; then
        if [ -z "${3:-}" ]; then
            # If the variable contains the word 'PASSWORD', hide the input.
            if [[ "$2" == *"PASSWORD"* ]]; then
                read -rsp "Enter value for '$2' (output hidden): " "$2"
                echo
            else
                read -rp "Enter value for '$2': " "$2"
                echo
            fi

            # Return non-zero to indicate we did not use an explicit env file value.
            return 1
        else
            INFO "Using default value of '$3' for '$2' (as it wasn't specified in $1)"
            printf -v "$2" '%s' "$3"

            # Return non-zero to indicate we did not use an explicit env file value.
            return 1
        fi
    fi

    return 0
}

function load_env_from_dir() {
    # Load Environment Variables
    ENV_FILE="$1/.env"
    if [ -f "$ENV_FILE" ]; then
        DEBUG "Loading environment from '$ENV_FILE'..."
        source "$ENV_FILE"
    else
        WARN "Missing environment file '$ENV_FILE'"
    fi

    set +e
    NON_EXPLICIT=0

    # Load User Credentials
    DEBUG "Loading user credentials"
    load_env_var "$ENV_FILE" "USERNAME"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))
    load_env_var "$ENV_FILE" "PASSWORD"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))

    # Load OpenID Connect (OIDC) Configuration
    DEBUG "Loading OpenID Connect (OIDC) configuration"
    load_env_var "$ENV_FILE" "CLIENT_ID"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))
    load_env_var "$ENV_FILE" "CLIENT_SECRET"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))
    load_env_var "$ENV_FILE" "GRANT_TYPE" "password"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))
    load_env_var "$ENV_FILE" "SCOPE" "openid"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))

    # Load Base URLs for API
    DEBUG "Loading base URLs for API"
    load_env_var "$ENV_FILE" "BASE_URL_OIDC_AUTH" "https://auth.tableside.site"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))
    load_env_var "$ENV_FILE" "BASE_URL_API" "https://api.tableside.site"
    NON_EXPLICIT=$((NON_EXPLICIT + $?))

    set -e

    # If any values were not explicitly set, prompt the user to confirm the values
    if [ "$NON_EXPLICIT" -gt 0 ]; then
        summarize_env
    fi
}

function summarize_env() {
    # Obscure secrets/passwords with asterisks
    PASSWORD_OBSCURED=$(echo "$PASSWORD" | sed 's/./*/g')
    CLIENT_SECRET_OBSCURED=$(echo "$CLIENT_SECRET" | sed 's/./*/g')

    # Summarize Environment Variables
    # Ensure the table renders correctly by padding the values with spaces
    # print headers in bold
    HEADER_VAR_NAME_BOLD=""

    INFO ""
    INFO "--> Environment Summary:"
    INFO ""
    INFO "┌────────────────────────────┬────────────────────────────────────────────────────────────────────────────┐"
    INFO "│ Variable Name              │ Value                                                                      │"
    INFO "├────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤"
    INFO "│ USERNAME                   │ $(printf "%-74s" "$USERNAME") │"
    INFO "│ PASSWORD                   │ $(printf "%-74s" "$PASSWORD_OBSCURED") │"
    INFO "├────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤"
    INFO "│ CLIENT_ID                  │ $(printf "%-74s" "$CLIENT_ID") │"
    INFO "│ CLIENT_SECRET              │ $(printf "%-74s" "$CLIENT_SECRET_OBSCURED") │"
    INFO "│ GRANT_TYPE                 │ $(printf "%-74s" "$GRANT_TYPE") │"
    INFO "│ SCOPE                      │ $(printf "%-74s" "$SCOPE") │"
    INFO "├────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤"
    INFO "│ BASE_URL_OIDC_AUTH         │ $(printf "%-74s" "$BASE_URL_OIDC_AUTH") │"
    INFO "│ BASE_URL_API               │ $(printf "%-74s" "$BASE_URL_API") │"
    INFO "└────────────────────────────┴────────────────────────────────────────────────────────────────────────────┘"
    INFO ""

    # Prompt user to confirm environment variables
    read -rp "Do you want to continue with these environment variables? [y/N]: " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        ERROR "Cancelled."
        exit 1
    fi
}

# -----------------------------------------------------------------------------

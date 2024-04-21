#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------

# Given a response, check if the user has the required roles.
# Returns 0 if the user has the required roles, otherwise returns 1.
#
# Usage:
#   check_user_role RESPONSE ROLES
#
# Example:
#   check_user_roles "$RESPONSE" "customer"
#   check_user_roles "$RESPONSE" "customer restaurant"
function check_user_roles() {
    local RESPONSE=$1
    local ROLES=$2

    if [ -z "$RESPONSE" ]; then
        ERROR "The response is empty."
        exit 1
    fi

    if [ -z "$ROLES" ]; then
        ERROR "You must specify the roles to check_user_roles."
        ERROR "Usage: check_user_roles RESPONSE ROLES"
        exit 1
    fi

    # DEBUG "Checking for $role role..."

    local RAW_PAYLOAD=$(echo "$RESPONSE" | jq -r .access_token | cut -d "." -f 2)
    local PAYLOAD=$(base64_urlsafe_decode $RAW_PAYLOAD)

    local USER_NAME=$(echo "$PAYLOAD" | jq -r .name)
    local USER_EMAIL=$(echo "$PAYLOAD" | jq -r .email)
    INFO "Authenticated as $USER_NAME ($USER_EMAIL)"

    local USER_ROLES_MULTILINE=$(echo "$PAYLOAD" | jq -r '.realm_access.roles | .[]')

    # Convert the multiline string to an array.
    local USER_ROLES=$(multiline_string_to_array "$USER_ROLES_MULTILINE")

    for role in $ROLES; do
        DEBUG "Checking for $role role..."
        if [[ ! " ${USER_ROLES[@]} " =~ " ${role} " ]]; then
            ERROR "The user does not have the required role '$role'."
            exit 1
        fi
    done
}

# Get the access token from the OpenID Connect (OIDC) provider by logging in
# with the specified credentials.
#
# Usage:
#   login [REQUIRED_ROLES]
#
# Example:
#   login "customer"
#   login "restaurant"
#   login "customer restaurant"
function login() {
    if [ -z "$BASE_URL_OIDC_AUTH" ]; then
        ERROR "The required environment variable 'BASE_URL_OIDC_AUTH' is not set."
        exit 1
    fi

    for var in USERNAME PASSWORD CLIENT_ID CLIENT_SECRET GRANT_TYPE SCOPE; do
        if [ -z "${!var}" ]; then
            ERROR "The required environment variable '$var' is not set."
            exit 1
        fi
    done

    local RESPONSE=$(curl -s \
        -d "username=$USERNAME"             \
        -d "password=$PASSWORD"             \
        -d "grant_type=$GRANT_TYPE"         \
        -d "client_id=$CLIENT_ID"           \
        -d "client_secret=$CLIENT_SECRET"   \
        -d "scope=$SCOPE"                   \
        -XPOST "$BASE_URL_OIDC_AUTH/token")
    
    # If $1 is specified, it is a list of roles that need to be checked.
    if [ -n "${1:-}" ]; then
        DEBUG "Checking roles..."
        check_user_roles "$RESPONSE" "$1"
    fi

    echo $(echo "$RESPONSE" | jq -r .access_token)
}

# -----------------------------------------------------------------------------

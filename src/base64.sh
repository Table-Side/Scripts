#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------

# Map the RFC 4648 Base64 URL-safe alphabet (section 5) to the standard Base64
# alphabet.
function base64_urlsafe_to_standard() {
    echo -n "$1" | tr -- '+/' '-_'
}

# Map the standard Base64 alphabet to the RFC 4648 Base64 URL-safe alphabet
# (section 5).
function base64_standard_to_urlsafe() {
    echo -n "$1" | tr -- '-_' '+/'
}

# Pad the input string with '=' characters to make its length a multiple of 4.
function base64_pad() {
    local last_block=$(( ${#1} % 4 ))

    if [ $last_block -eq 0 ]; then
        echo -n "$1"
        return
    else
        local required_padding=$(( 4 - $last_block ))
        local padding=$(yes "=" | head -n $required_padding | tr -d '\n')
        echo -n "$1$padding"
        return
    fi
}

# Unpad the input string by removing any '=' characters from the end.
function base64_unpad() {
    echo -n "$1" | sed 's/=*$//'
}

# Decode a string from Base64 URL-safe encoding to standard Base64 encoding.
function base64_urlsafe_decode() {
    # Map the character set to the standard Base64 alphabet.
    local input=$(base64_urlsafe_to_standard "$1")
    # Add padding to the input string to conform to the standard Base64 encoding rules.
    local padded_input=$(base64_pad "$input")
    # Decode the padded input string.
    local decoded=`echo -n "$padded_input" | base64 --decode`
    # Echo the decoded string.
    echo -n "$decoded"
}

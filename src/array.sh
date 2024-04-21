#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------

# Convert a multiline string to an array where each line is a space-delimited
# element in the array. The output is echoed to stdout.
#
# Usage:
#   multiline_string_to_array INPUT
#
# Example:
#   MY_ARRAY=$(multiline_string_to_array "$MULTILINE_STRING")
function multiline_string_to_array() {
    local input=$1

    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'\n'      # Change IFS to newline char
    array=($input) # split the `input` string into an array
    IFS=$SAVEIFS   # Restore original IFS

    echo "${array[@]}"
}
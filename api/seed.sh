#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------

# Perform an authenticated PUT request to an endpoint used to create a resource.
#
# Usage:
#   put_request ENDPOINT TOKEN PAYLOAD
#
# Example:
#   put_request "/restaurants" "$TOKEN" "$RESTAURANT"
function put_request() {
    local ENDPOINT=$1
    local TOKEN=$2
    local PAYLOAD=$3

    curl -s -XPUT \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "$PAYLOAD" \
        "$BASE_URL_API$ENDPOINT"
}

# Create a new restaurant.
#
# Usage:
#   create_restaurant TOKEN RESTAURANT
#
# Example:
#   create_restaurant "$TOKEN" "$REST
function create_restaurant() {
    local TOKEN=$1
    local RESTAURANT=$2
    put_request "/restaurants" "$TOKEN" "$RESTAURANT"
}

function create_menu() {
    local TOKEN=$1
    local RESTAURANT_ID=$2
    local MENU=$3
    put_request "/restaurants/$RESTAURANT_ID/menus" "$TOKEN" "$MENU"
}

function create_menu_item() {
    local TOKEN=$1
    local RESTAURANT_ID=$2
    local MENU_ID=$3
    local ITEM=$4
    put_request "/restaurants/$RESTAURANT_ID/menus/$MENU_ID/items" "$TOKEN" "$ITEM"
}

# -----------------------------------------------------------------------------

# Log in and ensure the user has the 'restaurant' role.
ACCESS_TOKEN=$(login "restaurant")

# Load the mock data.
SEED_DATA=$(cat "$DIR/data/seed.json")

# -----------------------------------------------------------------------------

# Step 1: Create each of the restaurants.
jq -c '.[]' <<< "$SEED_DATA" | while read -r restaurant_entry; do
    restaurant=$(jq -c '.restaurant' <<< "$restaurant_entry")
    data=$(create_restaurant "$ACCESS_TOKEN" "$restaurant")

    RESTAURANT_ID=$(echo "$data" | jq -r .data.id)
    NAME=$(echo "$data" | jq -r .data.name)
    INFO "-> Created restaurant: $NAME ($RESTAURANT_ID)"

    # Step 2: Create the menu for the restaurant.
    jq -c '.menus.[]' <<< "$restaurant_entry" | while read -r menu_entry; do
        menu=$(jq -c '.menu' <<< "$menu_entry")
        data=$(create_menu "$ACCESS_TOKEN" "$RESTAURANT_ID" "$menu")

        MENU_ID=$(echo "$data" | jq -r .data.id)
        NAME=$(echo "$data" | jq -r .data.name)
        INFO "\t-> Created menu: $NAME ($RESTAURANT_ID/$MENU_ID)"

        # Step 3: Create the menu items for the menu.
        jq -c '.items.[]' <<< "$menu_entry" | while read -r menu_item; do
            data=$(create_menu_item "$ACCESS_TOKEN" "$RESTAURANT_ID" "$MENU_ID" "$menu_item")
            data=$(echo "$data" | jq -r '.data.items | last')

            ITEM_ID=$(echo "$data" | jq -r .id)
            DISPLAY_NAME=$(echo "$data" | jq -r .displayName)
            SHORT_NAME=$(echo "$data" | jq -r .shortName)

            INFO "\t\t-> Created menu item: $DISPLAY_NAME ($SHORT_NAME) ($RESTAURANT_ID/$MENU_ID/$ITEM_ID)"
        done
    done
done

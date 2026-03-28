#!/bin/bash

source "$SCRIPT_DIR/menu/gui_helpers.sh"

while true; do
    choice=$(zenity --list \
        --title="$(gui_window_title)" \
        --text="Main Menu" \
        --column="Action" \
        --hide-header \
        --width=380 --height=370 \
        "Create Database" \
        "List Databases" \
        "Connect To Database" \
        "Disconnect Database" \
        "Drop Database" \
        "Exit" 2>/dev/null)

    # Window closed with ✕
    [[ $? -ne 0 ]] && choice="Exit"

    case "$choice" in
        "Create Database")
            source "$SCRIPT_DIR/operations/main/create_database.sh"
            ;;
        "List Databases")
            source "$SCRIPT_DIR/operations/main/list_databases.sh"
            ;;
        "Connect To Database")
            source "$SCRIPT_DIR/operations/main/connect_to_database.sh"
            ;;
        "Disconnect Database")
            source "$SCRIPT_DIR/operations/main/disconnect_database.sh"
            ;;
        "Drop Database")
            source "$SCRIPT_DIR/operations/main/drop_database.sh"
            ;;
        "Exit")
            gui_confirm "Are you sure you want to exit?" && exit 0
            ;;
        *)
           
            ;;
    esac
done
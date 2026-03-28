#!/bin/bash

source "$SCRIPT_DIR/menu/gui_helpers.sh"

db_name=$(gui_entry "Create Database" "Enter new database name:")
[[ $? -ne 0 || -z "$db_name" ]] && return   # Cancelled or empty input


if [[ ! "$db_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    gui_error "Invalid name.\nUse letters, digits, and underscores only.\nMust start with a letter or underscore."
    return
fi

db_path="$DB_DIR/$db_name"

if [ -d "$db_path" ]; then
    gui_error "Database '$db_name' already exists."
else
    mkdir "$db_path"
    gui_info "✔ Database '$db_name' created successfully."
fi
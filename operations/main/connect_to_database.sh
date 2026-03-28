#!/bin/bash


source "$SCRIPT_DIR/menu/gui_helpers.sh"


db_names=()
for db in "$DB_DIR"/*/; do
    [ -d "$db" ] && db_names+=("$(basename "$db")")
done

if [ ${#db_names[@]} -eq 0 ]; then
    gui_error "No databases found.\nCreate one first."
    return
fi

# Build radiolist args
list_args=()
for db in "${db_names[@]}"; do
    list_args+=("FALSE" "$db")
done

db_name=$(zenity --list \
    --title="Connect To Database" \
    --text="Select a database to connect to:" \
    --radiolist \
    --column="Select" --column="Database" \
    --width=420 --height=380 \
    "${list_args[@]}" 2>/dev/null)

[[ $? -ne 0 || -z "$db_name" ]] && return   # Cancelled or no selection

export CURRENT_DB="$db_name"
export CURRENT_DB_PATH="$DB_DIR/$db_name"

gui_info "✔ Connected to database '$db_name' successfully."


source "$SCRIPT_DIR/menu/db_menu.sh"
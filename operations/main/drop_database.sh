source "$SCRIPT_DIR/menu/gui_helpers.sh"


db_names=()
for db in "$DB_DIR"/*/; do
    [ -d "$db" ] && db_names+=("$(basename "$db")")
done

if [ ${#db_names[@]} -eq 0 ]; then
    gui_error "No databases found."
    return
fi

list_args=()
for db in "${db_names[@]}"; do
    list_args+=("FALSE" "$db")
done

db_name=$(zenity --list \
    --title="Drop Database" \
    --text="Select a database to drop:" \
    --radiolist \
    --column="Select" --column="Database" \
    --width=420 --height=380 \
    "${list_args[@]}" 2>/dev/null)

[[ $? -ne 0 || -z "$db_name" ]] && return

if [ "$db_name" = "$CURRENT_DB" ]; then
    gui_error "Cannot drop '$db_name' — you are currently connected to it.\nDisconnect first, then drop it."
    return
fi


gui_confirm "Are you sure you want to drop '$db_name'?\nThis action is irreversible." || return

rm -rf "$DB_DIR/$db_name"
gui_info "✔ Database '$db_name' dropped."
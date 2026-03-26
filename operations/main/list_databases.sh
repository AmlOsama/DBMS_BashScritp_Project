source "$SCRIPT_DIR/menu/gui_helpers.sh"


list_args=() #collect databases with status for list dialog
found=0
for db in "$DB_DIR"/*/; do
    if [ -d "$db" ]; then
        name="$(basename "$db")"
        # Show connected status next to current DB
        if [[ "$name" == "$CURRENT_DB" ]]; then
            list_args+=("$name" "● connected")
        else
            list_args+=("$name" "")
        fi
        found=1
    fi
done

if [[ $found -eq 0 ]]; then
    gui_info "No databases found."
    return
fi

zenity --list \
    --title="List Databases" \
    --text="Available databases:" \
    --column="Database" --column="Status" \
    --width=420 --height=380 \
    "${list_args[@]}" 2>/dev/null
source "$SCRIPT_DIR/menu/gui_helpers.sh"

# Build table list 
table_names=()
for meta in "$CURRENT_DB_PATH"/*.meta; do
    [ -f "$meta" ] && table_names+=("$(basename "$meta" .meta)")
done

if [ ${#table_names[@]} -eq 0 ]; then
    gui_error "No tables found in '$CURRENT_DB'."
    return
fi

list_args=()
for t in "${table_names[@]}"; do
    list_args+=("FALSE" "$t")
done

table_name=$(zenity --list \
    --title="Drop Table" \
    --text="Select a table to drop:" \
    --radiolist \
    --column="Select" --column="Table" \
    --width=420 --height=380 \
    "${list_args[@]}" 2>/dev/null)

[[ $? -ne 0 || -z "$table_name" ]] && return


gui_confirm "Are you sure you want to drop '<b>$table_name</b>'?\nThis cannot be undone." || return

#  removes .meta and .data files
rm -f "$CURRENT_DB_PATH/$table_name.meta"
rm -f "$CURRENT_DB_PATH/$table_name.data"
# Also remove the raw data file (no extension) used by insert/select/etc.
rm -f "$CURRENT_DB_PATH/$table_name"

gui_info "✔ Table '$table_name' dropped."
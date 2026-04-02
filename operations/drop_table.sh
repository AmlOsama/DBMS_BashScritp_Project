# build table list 
table_names=()
for meta in "$CURRENT_DB_PATH"/*.meta; do
    [ -f "$meta" ] && table_names+=("$(basename "$meta" .meta)")
done

if [ ${#table_names[@]} -eq 0 ]; then
    echo "No tables found in '$CURRENT_DB'."
    read -rp "Press Enter to continue..."
    return
fi

#  pick a table 
echo "Select a table to drop:"
PS3=$'\nEnter number: '
select table_name in "${table_names[@]}" "Cancel"; do
    [ "$table_name" = "Cancel" ] || [ -z "$table_name" ] && break

    read -rp "Are you sure you want to drop '$table_name'? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        rm -f "$CURRENT_DB_PATH/$table_name.meta"
        rm -f "$CURRENT_DB_PATH/$table_name"
        echo "✔ Table '$table_name' dropped."
    else
        echo "Cancelled."
    fi
    break
done

read -rp "Press Enter to continue..."
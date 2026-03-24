db_names=()
for db in "$DB_DIR"/*/; do
    [ -d "$db" ] && db_names+=("$(basename "$db")")
done

if [ ${#db_names[@]} -eq 0 ]; then
    echo "No databases found. Create one first."
    read -rp "Press Enter to continue..."
    return
fi

echo "Select a database:"
PS3=$'\nEnter number: '
select db_name in "${db_names[@]}" "Cancel"; do
    [ "$db_name" = "Cancel" ] || [ -z "$db_name" ] && break
    
    export CURRENT_DB="$db_name"
    export CURRENT_DB_PATH="$DB_DIR/$db_name"
    echo ""
    echo "✔ Connected to database '$db_name' successfully."
    echo ""
    read -rp "Press Enter to continue..."
    
    source ./menu/db_menu.sh
    break
done

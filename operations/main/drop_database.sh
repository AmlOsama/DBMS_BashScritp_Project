db_names=()
for db in "$DB_DIR"/*/; do
    [ -d "$db" ] && db_names+=("$(basename "$db")")
done

if [ ${#db_names[@]} -eq 0 ]; then
    echo "No databases found."
    read -rp "Press Enter to continue..."
    return
fi

echo "Select a database to drop:"
PS3=$'\nEnter number: '
select db_name in "${db_names[@]}" "Cancel"; do
    [ "$db_name" = "Cancel" ] || [ -z "$db_name" ] && break

    # ──  CHECK  if the database is currently connected  so it will not be dropped──────────────────────────────────────────
    if [ "$db_name" = "$CURRENT_DB" ]; then
        echo "Error: Cannot drop '$db_name' — you are currently connected to it."
        echo "Exit the database first, then drop it."
        break
    fi
    # ───────────────────────────────────────────────────────

    read -rp "Are you sure you want to drop '$db_name'? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        rm -rf "$DB_DIR/$db_name"
        echo "✔ Database '$db_name' dropped."
    else
        echo "Cancelled."
    fi
    break
done

read -rp "Press Enter to continue..."
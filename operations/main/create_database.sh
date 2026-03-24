read -rp "Enter new database name: " db_name

if [[ ! "$db_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "Error: Invalid name. Use letters, digits, underscores only."
    read -rp "Press Enter to continue..."
    return
fi

db_path="$DB_DIR/$db_name"

if [ -d "$db_path" ]; then
    echo "Error: Database '$db_name' already exists."
else
    mkdir "$db_path"
    echo "✔ Database '$db_name' created."
fi

read -rp "Press Enter to continue..."
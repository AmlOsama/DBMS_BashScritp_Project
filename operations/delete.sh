#!/bin/bash

# 1. List and Select Table
echo "Available tables in database '$CURRENT_DB':"

tables=$(ls "$CURRENT_DB_PATH"/*.meta 2>/dev/null | xargs -n 1 basename -s .meta)

if [ -z "$tables" ]; then
    echo "No tables found in $CURRENT_DB."
    source "./menu/db_menu.sh"
    exit 1
fi

select selected_table in $tables; do
    if [[ -n "$selected_table" ]]; then
        echo "You selected: $selected_table"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Define Paths
meta_file="$CURRENT_DB_PATH/$selected_table.meta"

# Check if data file exists
if [[ -f "$CURRENT_DB_PATH/$selected_table" ]]; then
    data_file="$CURRENT_DB_PATH/$selected_table"
else 
    echo "The selected table data file is missing or empty."
    echo ""
    read -rp "Press Enter to continue..."
    source "./menu/db_menu.sh"
    exit 1
fi

# Check if data file has content
if [[ ! -s "$data_file" ]]; then
    echo "The table '$selected_table' is empty. No records to delete."
    echo ""
    read -rp "Press Enter to continue..."
    source "./menu/db_menu.sh"
    exit 1
fi

# 2. Identify Primary Key Column Position
pk_row=$(awk -F: '$3 == "true" { print NR; exit }' "$meta_file")

if [[ -z "$pk_row" ]]; then
    echo "Error: No Primary Key defined in metadata."
    source "./menu/db_menu.sh"
    exit 1
fi

echo "The primary key is defined at column position: $pk_row"

# 3. Show existing records
echo "Existing records in table '$selected_table':"
echo "-----------------------------------"
awk -F: -v pk="$pk_row" '{ print "Key: " $pk " | Record: " $0 }' "$data_file"
echo "-----------------------------------"

# 4. Find the Line Number in the Data File
key_value=""
while [[ -z "$key_value" ]]; do
    read -p "Enter the Key value of the row you wish to delete, or 'quit' to exit: " key_value

    if [[ "$key_value" == "quit" ]]; then
        echo "Operation cancelled."
        source "./menu/db_menu.sh"
        exit 1
    fi

    target_line=$(awk -F: -v pk="$pk_row" -v kv="$key_value" '$pk == kv { print NR; exit }' "$data_file")

    if [[ -z "$target_line" ]]; then
        echo "Error: Record with key '$key_value' not found in $selected_table."
        key_value=""
    fi
done

# Show the record to be deleted
record_to_delete=$(awk -F: -v line="$target_line" 'NR == line { print $0 }' "$data_file")
echo "Found record at line $target_line: $record_to_delete"

# 5. Confirm deletion
read -p "Are you sure you want to delete this record? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Deletion cancelled."
    source "./menu/db_menu.sh"
    exit 1
fi

# ------- Backup before deleting ---
cp "$data_file" "$data_file.bak" || { echo "Error: Could not create backup."; exit 1; }

# 6. Delete the specific line using sed
sed -i "${target_line}d" "$data_file"

echo "-----------------------------------"
echo "Success: Record with key '$key_value' has been deleted."
echo "Deleted Record: $record_to_delete"

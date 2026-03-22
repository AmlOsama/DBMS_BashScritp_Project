#!/bin/bash

# --- Configuration & Setup ---
current_db="test"

# 1. List and Select Table
echo "Available tables in database '$current_db':"
tables=$(ls "./databases/$current_db" 2>/dev/null)

if [ -z "$tables" ]; then
    echo "No tables found in $current_db."
    source "./menu/db_menu.sh"
fi

select table in $tables; do
    if [[ -n "$table" ]]; then
        selected_table="$table"
        echo "You selected: $selected_table"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Define Paths
meta_file="./databases/$current_db/$selected_table/$selected_table.meta"
data_file="./databases/$current_db/$selected_table/$selected_table"

# 2. Identify Primary Key Column Position
pk_row=$(awk -F: '$3 == "true" { print NR }' "$meta_file")

if [[ -z "$pk_row" ]]; then
    echo "Error: No Primary Key defined in metadata."
    source "./menu/db_menu.sh"
fi

echo "The primary key is defined at column position: $pk_row"

# 3. Find the Line Number in the Data File
while [[ -z "$key_value" ]]; do
    read -p "Enter the Key value of the row you wish to update, or 'quit' to exit: " key_value

    if [[ "$key_value" == "quit" ]]; then
        echo "Operation cancelled."
        source "./menu/db_menu.sh"
    fi

    target_line=$(awk -F: -v pk="$pk_row" -v kv="$key_value" '$pk == kv { print NR; exit }' "$data_file")

    if [[ -z "$target_line" ]]; then
        echo "Error: Record with key '$key_value' not found in $selected_table."
        key_value=""
    fi
done
echo "Found record at line $target_line. Please enter new details:"

#------- Backup before overwriting ---
cp "$data_file" "$data_file.bak" || { echo "Error: Could not create backup."; exit 1; }

# 4. Collect New Data based on Metadata
new_record=""
col_index=0

while IFS=: read -r col_name col_type is_pk <&3; do
    col_index=$(( col_index + 1 ))

    if [[ "$is_pk" == "true" ]]; then
        orig_pk=$(awk -F: -v line="$target_line" -v col="$col_index" \
            'NR == line { print $col }' "$data_file")
        new_record="${new_record:+$new_record:}$orig_pk"
        echo "Skipping primary key field '$col_name' (preserved: $orig_pk)"
        continue
    fi

    while true; do
        read -p "Enter value for $col_name ($col_type): " user_input
        if [[ "$col_type" == "int" ]]; then
            if [[ "$user_input"  ^[1-9][0-9]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                echo "Field '$col_name' must be an integer."
            fi
        elif [[ "$col_type" == "string" ]]; then
            if [[ "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                echo "Field '$col_name' cannot be empty."
            fi
        fi
        
    done

done 3< "$meta_file"

# 5. Overwrite the specific line using sed
sed -i "${target_line}s/.*/$new_record/" "$data_file"

echo "-----------------------------------"
echo "Success: Line $target_line has been updated."
echo "New Record: $new_record"
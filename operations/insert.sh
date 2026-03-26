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
if [[ -f "$CURRENT_DB_PATH/$selected_table" ]]; then
    data_file="$CURRENT_DB_PATH/$selected_table"
else
    echo "The selected table data file is missing or empty."
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

# 3. Collect New Record Data Based on Metadata
new_record=""
col_index=0

while IFS=: read -r col_name col_type is_pk <&3; do
    [[ -z "$col_name" ]] && continue
    col_index=$(( col_index + 1 ))

    if [[ "$is_pk" == "true" ]]; then
        # Validate uniqueness of PK
        while true; do
            read -p "Enter value for PRIMARY KEY '$col_name' ($col_type): " user_input
            if [[ "$col_type" == "int" && ! "$user_input" =~ ^[1-9][0-9]*$ ]]; then
                echo "Field '$col_name' must be a positive integer."
                continue
            fi
            # Check for duplicate PK
            duplicate=$(awk -F: -v pk="$pk_row" -v kv="$user_input" '$pk == kv' "$data_file")
            if [[ -n "$duplicate" ]]; then
                echo "Error: Primary key '$user_input' already exists. Must be unique."
            else
                new_record="${new_record:+$new_record:}$user_input"
                break
            fi
        done
        continue
    fi

    while true; do
        read -p "Enter value for '$col_name' ($col_type): " user_input
        if [[ "$col_type" == "int" ]]; then
            if [[ "$user_input" =~ ^[1-9][0-9]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                echo "Field '$col_name' must be a positive integer."
            fi
        elif [[ "$col_type" == "string" ]]; then
            if [[ "$user_input" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                echo "Field '$col_name' must start with a letter/underscore and contain no spaces."
            fi
        fi
    done
done 3< "$meta_file"

# 4. Backup Before Writing
cp "$data_file" "$data_file.bak" || { echo "Error: Could not create backup."; exit 1; }

# 5. Append the New Record
echo "$new_record" >> "$data_file"

echo "-----------------------------------"
echo "Success: New record inserted."
echo "New Record: $new_record"
echo "-----------------------------------"
echo ""
read -rp "Press Enter to continue..."
source "./menu/db_menu.sh"
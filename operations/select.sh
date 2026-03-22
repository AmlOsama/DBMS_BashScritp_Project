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

# 2. Show all available fields in the table

available_fields=$(awk -F: '{print $1}' "$meta_file")

select field in $available_fields; do
    if [[ -n "$field" ]]; then
        selected_field="$field"
        echo "You selected: $selected_field"
        read -p "Enter the new value for $selected_field: " search_value
        #display all the data in the table according to the selected field and the new value
        awk -F: -v field="$selected_field" -v value="$search_value" '
        BEGIN {
            OFS=":"
        }
        NR==FNR {
            if ($1 == field) {
                field_num = NR
            }
            next
        }
        {
            if ($field_num == value) {
                print $0
            }
        }' "$meta_file" "$data_file"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

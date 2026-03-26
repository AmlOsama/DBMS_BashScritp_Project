#!/bin/bash

echo "Available tables in database '$CURRENT_DB':"

# 1. Get clean names (strips the path and the .meta extension)
# This pipes the files through sed to clean them up instantly
tables=$(ls "$CURRENT_DB_PATH"/*.meta 2>/dev/null | xargs -n 1 basename -s .meta)

if [ -z "$tables" ]; then
    echo "No tables found in $CURRENT_DB."
    source "./menu/db_menu.sh"
    exit 1
fi

# 2. Let Bash's 'select' split them by line/space automatically
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
#check if "datafile path" exists if not return to db_menu
if [[ -f "$CURRENT_DB_PATH/$selected_table" ]]
then
    data_file="$CURRENT_DB_PATH/$selected_table"
else 
    echo "The selected table is empty."
    echo ""
    read -rp "Press Enter to continue..."
    source ./menu/db_menu.sh
fi
# 2. Show all available fields in the table
available_fields=$(awk -F: '{print $1}' "$meta_file")

select field in $available_fields; do
    if [[ -n "$field" ]]; then
        selected_field="$field"
        echo "You selected: $selected_field"
        read -p "Enter the value for $selected_field: " search_value
        
        # Display data from data_file based on meta_file definitions
        awk -F: -v field="$selected_field" -v value="$search_value" '
        BEGIN {
            print "====================================="
            print "Matching records for [" field " = " value "]:"
            print "====================================="
            OFS="\t"
        }
        
        NR == FNR {
            fields[FNR] = $1  # Save field name for headers
            if ($1 == field) {
                field_num = FNR
            }
            next
        }
        
        FNR == 1 {
            for (i=1; i<=length(fields); i++) {
                printf "%s\t", fields[i]
            }
            print "\n-------------------------------------"
        }
        
        {   
            if ($field_num ~ value) {
                for (i=1; i<=NF; i++) {
                    printf "%s\t", $i
                }
                print ""
                match_count++
            }
        }
        
        END {
            if (match_count == 0) {
                print "(No matching records found)"
            }
            print "====================================="
        }
        ' "$meta_file" "$data_file"
        
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
echo ""
read -rp "Press Enter to continue..."
source ./menu/db_menu.sh
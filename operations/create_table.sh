#!/bin/bash

# Create Table - requires current DB context
# TODO: Set current_db variable in main_menu connect
read -p "Enter table name: " table_name
read -p "Enter columns (name:type,name:type): " columns

echo "$columns" > "../databases/$current_db/${table_name}.meta"
echo "Table '$table_name' created in current DB."


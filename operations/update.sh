#!/bin/bash

# Update Table (basic: overwrite first line)
read -p "Enter table name: " table_name
read -p "New values for first row: " new_values
sed -i "1s/.*/$new_values/" "../databases/$current_db/$table_name"
echo "First row in '$table_name' updated."


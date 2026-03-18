#!/bin/bash

# Delete from Table (simple: delete all for now)
read -p "Enter table name: " table_name
> "../databases/$current_db/$table_name"
echo "Table '$table_name' cleared."


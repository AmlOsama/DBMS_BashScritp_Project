#!/bin/bash

# Select from Table
read -p "Enter table name: " table_name
echo "=== Data in $table_name ==="
cat "../databases/$current_db/$table_name"


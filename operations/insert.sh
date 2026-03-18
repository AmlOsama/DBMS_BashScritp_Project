#!/bin/bash

# Insert into Table
read -p "Enter table name: " table_name
read -p "Enter values (val1,val2): " values

echo "$values" >> "../databases/$current_db/$table_name"
echo "Data inserted into '$table_name'."


#!/bin/bash

# Create Database
read -p "Enter database name: " db_name
mkdir -p "../databases/$db_name"
echo "Database '$db_name' created."


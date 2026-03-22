#!/bin/bash

#initialize the database directory if it doesn't exist
DB_DIR="./databases"
if [ ! -d "$DB_DIR" ]; then
    mkdir "$DB_DIR"
fi

# DBMS Main Entry Point
source ./menu/main_menu.sh

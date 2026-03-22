#!/bin/bash


DB_DIR="$(dirname "$0")/databases"
mkdir -p "$DB_DIR" 

PS3=$'\nChoose an option [1-5]: '
while true; do
 clear
    echo "==============================="
    echo "   Bash DBMS - Main Menu"
    echo "==============================="

        select choice in "Create Database" "List Databases" "Connect To Database" "Drop Database" "Exit"
        do 
        case $choice in
            "Create Database")
            source ./menu/main/create_database.sh
            break
            ;;
            "List Databases")
            source ./menu/main/list_databases.sh
            break
            ;;
            "Connect To Database")
            source ./menu/main/connect_to_database.sh
            break
            ;;
            "Drop Database")
            source ./menu/main/drop_database.sh
            break
            ;;
            "Exit")    
            echo "Goodbye!"; exit 0 ;;
            *) 
            echo "Invalid option. Enter 1-5." 
            ;;
            
        esac
        done
done

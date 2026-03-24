#!/bin/bash


DB_DIR="$(dirname "$0")/databases"
mkdir -p "$DB_DIR" 

PS3=$'\nChoose an option [1,2,3,....]: '
while true; do
 clear
    echo "=============================== Current Database: ${CURRENT_DB:-None} ==============================="
    echo "==============================="
    echo "   Bash DBMS - Main Menu"
    echo "==============================="

        select choice in "Create Database" "List Databases" "Connect To Database" "Disconnect Database" "Drop Database" "Exit"
        do 
        case $choice in
            "Create Database")
            source ./operations/main/create_database.sh
            break
            ;;
            "List Databases")
            source ./operations/main/list_databases.sh
            break
            ;;
            "Connect To Database")
            source ./operations/main/connect_to_database.sh
            break
            ;;
            "Disconnect Database")
            source ./operations/main/disconnect_database.sh
            break
            ;;
            "Drop Database")
            source ./operations/main/drop_database.sh
            break
            ;;
            "Exit")    
            echo "Goodbye!"; exit 0 ;;
            *) 
            echo "Invalid option." 
            ;;
            
        esac
        done
done

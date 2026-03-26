#!/bin/bash

read -r  -p "Enter table name: " table_name
while [[ -f "./databases/${CURRENT_DB}/${table_name}.meta" || ! "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
do
    echo "Table '$table_name' already exists or has an invalid name. Please choose a different name."
    read -r -p "Enter table name: " table_name
done

read -r -p "Enter number of attributes: " attributes
while ! [[ "$attributes" =~ ^[1-9][0-9]*$ ]]
do
    echo "Invalid input. Please enter a positive integer for the number of attributes."
    read -r -p "Enter number of attributes: " attributes
done

pk_flag=true

while [[ $pk_flag == true ]]
do
    columns=""
    for ((i=1; i<=attributes; i++)) 
    do
        read -r -p "Enter name of attribute $i: " attr_name
        while [[ ! "$attr_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || "$columns" =~ (^|\\n)"$attr_name": ]];
        do
            echo "Attribute '$attr_name' already exists or has an invalid name. Please choose a different name."
            read -r -p "Enter name of attribute $i: " attr_name
        done
        echo "Choose data type for $attr_name:"
        select data_type in "string" "int";
        do
            case $data_type in
            "string")
                attr_type="string"
                break;
                ;;
            "int")        
                attr_type="int"
                break;
                ;;
            *)        echo "Invalid choice, please select again."
                ;;
            esac
        done 

        if [[ $pk_flag == true ]];
        then
            read -r -p "Is this a primary key? (y/n): " is_pk
            if [[ $is_pk == "y" ]];
            then
                is_pk="true"
                pk_flag=false
            else
                is_pk="false"
            fi
        else
            is_pk="false"
        fi

        columns+="$attr_name:$attr_type:$is_pk\n"
    done

    if [[ $pk_flag == true ]];
    then
        echo "At least one primary key is required. Please enter the attributes again."
    fi
done

touch "./databases/${CURRENT_DB}/${table_name}.meta"
touch "./databases/${CURRENT_DB}/${table_name}"

echo -e "$columns" > "./databases/${CURRENT_DB}/${table_name}.meta"
echo "Table '$table_name' created in current DB."
echo ""
read -rp "Press Enter to continue..."
source ./menu/db_menu.sh

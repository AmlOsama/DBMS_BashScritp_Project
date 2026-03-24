PS3=$'\nChoose an option [1,2,3,....]: '
while true; do
 clear
    echo "=============================== Current Database: ${CURRENT_DB:-None} ==============================="
    echo "==============================="
    echo "   Bash DBMS - Table Menu"
    echo "==============================="
    select query in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu" "Exit"
    do 
      case $query in
        "Create Table")
          source ./operations/create_table.sh
          ;;
        "List Tables")
          source ./operations/list_tables.sh
          ;;
        "Drop Table")
          source ./operations/drop_table.sh
          ;;
        "Insert into Table")
          source ./operations/insert.sh
          ;;
        "Select From Table")
          source ./operations/select.sh
          ;;
        "Delete From Table")
          source ./operations/delete.sh
          ;;
        "Update Table")
          source ./operations/update.sh
          ;;
        "Back to Main Menu")
          source ./menu/main_menu.sh
          ;;
        "Exit")    
              echo "Goodbye!"; exit 0 ;;
        *) 
              echo "Invalid option. Enter 1-5." 
          ;;
      esac
  done
done
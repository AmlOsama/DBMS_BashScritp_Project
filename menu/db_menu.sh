
select query in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu"
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
      break
      ;;
  esac
done
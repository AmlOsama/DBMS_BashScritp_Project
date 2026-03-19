#! /usr/bin/bash

#here I set configration
DB_DIR ="$(dirname "$0")/databases"  #$0 -> refer to script it self /ensures the databases folder is always created relative to where the script lives, not wherever you call it from.

mkdir -p "$DB _DIR"

#-------------------------------------------------------

print_header() {
    clear
    echo "========================================"
    echo "   $1"
    echo "========================================"
    echo ""
}
# echo "welcome"
#----------------------------------------------------------------------------------
pause() {
    echo ""
    read -rp "Press Enter to continue..."
    
}

: '
	read -rp  option r refer to raw mode raw mode: backslashes are taken literally, not as escape sequences.
	read -p "Name: " name    # user types  my\ndb  →  name = "my" (broken)
	read -rp "Name: " name   # user types  my\ndb  →  name = "my\ndb" (correct)
	
'
#----------------------------------------------------------------------------------------
 
validate_name(){
local name ="$1"
if [[ ! $name =~ ^[a-zA-Z_][a-zA-Z0-9]*$ ]]
	then
	echo "Error: Use letters, digits, underscores only (must start with a letter or underscore)."
	return1 # name is INVALID — signal failure
fi
	return 0  #  name is VALID — signal success


}
#----------------------------------------------------------------------------------------

: '
local keyword in a bash script is used exclusively inside a function to declare variables with a scope restricted to that function and any functions it calls. By default, all variables in bash are global. 
'

#----------main menu actions------------------------
create_database()
 {
	print_header "create Database"
	read -rp "Enter new database name:" db_name
	validate_name "$db_name" || {pause; return;}
	#{ pause; return; } — if validation failed: pause so the user sees the error message, then return exits this function immediately. Nothing below runs.
	
	local db_path="$DB_DIR/$db_name"   #db_path — combines the storage root ($DB_DIR) with the name the user typed ($db_name)
	if [ -d "$db_path" ]  #-d flag tests whether a path exists AND is a directory.

		then
		echo "Error : database '$db_name' already exists"
	else
		mkdir "$db_path"
		echo "Database '$db_name' created successfully."
	fi
	pause }




list_databases() {
    print_header "List Databases"
    local found=0
    for db in "$DB_DIR"/*/; do
        [ -d "$db" ] && echo "  • $(basename "$db")" && found=1
    done
    [ $found -eq 0 ] && echo "  (no databases found)"
    pause
}

connect_database(){
	print_header "connect to Database"
	
	#building an array of exisiting database name
	local db_names=()
	for db in "$DB_DIR"/*/   #Same glob pattern as list_databases. Iterates over every subdirectory in $DB_DIR. Each iteration, $db holds one full path 
	do
	[ -d $"db" ] && db_names+=("$(basename "$db")")
	done
	
	
	if [ ${#db_names[@]} -eq 0 ]; then  
        echo "  No databases available. Create one first."
        pause
        return
    fi
	
	echo "Select a database to drop:"
    	echo ""
    PS3=$'\nEnter number: ' #PS3 is the special bash variable that controls what select shows as its input prompt.
    select db_name in "${db_names[@]}" "Cancel"; do
        if [ "$db_name" = "Cancel" ] || [ -z "$db_name" ]; then
            echo "Cancelled."
            break
        fi
        echo ""
        read -rp "Are you sure you want to drop '$db_name'? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            rm -rf "$DB_DIR/$db_name"
            echo " Database '$db_name' dropped."
        else
            echo "Cancelled."
        fi
        break
    done
    pause
}



#------------DB menu placeholder --------------------------------

db_menu() {
    local db_name="$1"
    local db_path="$2"
    # TODO: implement full DB menu (tables, insert, select, etc.)
    print_header "Connected: $db_name"
    echo "  (DB menu coming soon — press Enter to go back)"
    pause
}


#main menu


 
main_menu() {
    local options=(
        "Create Database"
        "List Databases"
        "Connect to Database"
        "Drop Database"
        "Exit"
    )
 
    PS3=$'\nChoose an option: '
 
    while true; do
        print_header "Bash DBMS — Main Menu"
        select choice in "${options[@]}"; do
            case "$REPLY" in
                1) create_database    ; break ;;
                2) list_databases     ; break ;;
                3) connect_database   ; break ;;
                4) drop_database      ; break ;;
                5) echo "Goodbye!"; exit 0   ;;
                *) echo "Invalid option. Enter 1-5." ;;
            esac
        done
    done
}
 
main_menu



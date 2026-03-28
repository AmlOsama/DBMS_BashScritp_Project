source "$SCRIPT_DIR/menu/gui_helpers.sh"

while true; do
    query=$(zenity --list \
        --title="$(gui_window_title)" \
        --text="Table Menu  —  Database: <b>$CURRENT_DB</b>" \
        --column="Action" \
        --hide-header \
        --width=380 --height=440 \
        "Create Table" \
        "List Tables" \
        "Drop Table" \
        "Insert into Table" \
        "Select From Table" \
        "Delete From Table" \
        "Update Table" \
        "Back to Main Menu" \
        "Exit" 2>/dev/null)

    [[ $? -ne 0 ]] && query="Back to Main Menu"

    case "$query" in
        "Create Table")
            source "$SCRIPT_DIR/operations/create_table.sh"
            ;;
        "List Tables")
            source "$SCRIPT_DIR/operations/list_tables.sh"
            ;;
        "Drop Table")
            source "$SCRIPT_DIR/operations/drop_table.sh"
            ;;
        "Insert into Table")
            source "$SCRIPT_DIR/operations/insert.sh"
            ;;
        "Select From Table")
            source "$SCRIPT_DIR/operations/select.sh"
            ;;
        "Delete From Table")
            source "$SCRIPT_DIR/operations/delete.sh"
            ;;
        "Update Table")
            source "$SCRIPT_DIR/operations/update.sh"
            ;;
        "Back to Main Menu")
            source "$SCRIPT_DIR/menu/main_menu.sh"
            return
            ;;
        "Exit")
            gui_confirm "Are you sure you want to exit?" && exit 0
            ;;
        *)
            ;;
    esac
done

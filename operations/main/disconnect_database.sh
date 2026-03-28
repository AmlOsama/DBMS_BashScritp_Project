source "$SCRIPT_DIR/menu/gui_helpers.sh"

if [[ -z "$CURRENT_DB" ]]; then
    gui_error "No database is currently connected."
    return
fi

old_db="$CURRENT_DB"

export CURRENT_DB=""
export CURRENT_DB_PATH=""

gui_info "✔ Disconnected from database '$old_db' successfully."
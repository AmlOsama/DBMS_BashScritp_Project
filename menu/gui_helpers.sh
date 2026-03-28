#!/bin/bash


# ============================================================
#  gui_helpers.sh — shared zenity wrappers
# ============================================================

gui_info() {
    zenity --info \
        --title="Bash DBMS" \
        --text="$1" \
        --width=380 2>/dev/null
}

gui_error() {
    zenity --error \
        --title="Bash DBMS — Error" \
        --text="$1" \
        --width=380 2>/dev/null
}

gui_confirm() {
    # Returns 0 (yes) or 1 (no/cancel)
    zenity --question \
        --title="Bash DBMS" \
        --text="$1" \
        --width=380 2>/dev/null
}

gui_entry() {
    # $1 = window title  $2 = prompt text  $3 = optional prefill
    zenity --entry \
        --title="$1" \
        --text="$2" \
        --entry-text="${3:-}" \
        --width=420 2>/dev/null
}

gui_window_title() {
    if [[ -n "$CURRENT_DB" ]]; then
        echo "Bash DBMS  |  Connected: $CURRENT_DB"
    else
        echo "Bash DBMS  |  No database connected"
    fi
}

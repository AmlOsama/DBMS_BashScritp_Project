#!/bin/bash
source "$SCRIPT_DIR/menu/gui_helpers.sh"

# ── 1. Table name ────────────────────────────────────────────
while true; do
    table_name=$(gui_entry "Create Table" "Enter table name:")
    [[ $? -ne 0 ]] && return   # cancelled

    if [[ -f "./databases/${CURRENT_DB}/${table_name}.meta" || ! "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; 
    then
        gui_error "Table '$table_name' already exists or has an invalid name. Please choose a different name."
        continue
    fi
    break
done

# ── 2. Number of attributes ───────────────────────────────────
while true; do
    attributes=$(gui_entry "Create Table — Columns" \
        "Table: <b>$table_name</b>\n\nHow many attributes (columns)?")
    [[ $? -ne 0 ]] && return

    if [[ "$attributes" =~ ^[1-9][0-9]*$ ]]; then
        break
    else
        gui_error "Please enter a positive integer."
    fi
done

# ── 3. Collect each attribute ────────
pk_flag=true

while [[ $pk_flag == true ]]; do
    columns=""

    for (( i=1; i<=attributes; i++ )); do

        # ── 3a. Attribute name ──
        while true; do
            attr_name=$(gui_entry \
                "Attribute $i of $attributes" \
                "Table: <b>$table_name</b>\n\nEnter name for attribute $i:")
            [[ $? -ne 0 ]] && return

            if [[ ! "$attr_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                gui_error "Invalid attribute name.\nMust start with a letter or underscore."
                continue
            fi

            if echo -e "$columns" | grep -q "^${attr_name}:"; then
                gui_error "Attribute '$attr_name' already defined. Choose a different name."
                continue
            fi

            break
        done

        # ── 3b. Data type (string | int) ──
        attr_type=$(zenity --list \
            --title="Attribute $i — Data Type" \
            --text="Table: <b>$table_name</b>\nAttribute: <b>$attr_name</b>\n\nChoose data type:" \
            --radiolist \
            --column="Select" --column="Type" \
            --hide-header \
            --width=340 --height=240 \
            "TRUE"  "string" \
            "FALSE" "int" 2>/dev/null)
        [[ $? -ne 0 || -z "$attr_type" ]] && return

        # ── 3c. Primary Key? ──
        is_pk="false"
        if [[ $pk_flag == true ]]; then
            zenity --question \
                --title="Primary Key?" \
                --text="Is <b>$attr_name</b> the primary key?" \
                --width=340 2>/dev/null
            if [[ $? -eq 0 ]]; then
                is_pk="true"
                pk_flag=false
            fi
        fi

        columns+="${attr_name}:${attr_type}:${is_pk}\n"
    done

    if [[ $pk_flag == true ]]; then
        gui_error "At least one primary key is required.\nPlease re-enter the attributes."
    fi
done

# ── 4. Write .meta and data files ──────────
touch "$CURRENT_DB_PATH/$table_name.meta"
touch "$CURRENT_DB_PATH/$table_name"
echo -e "$columns" > "$CURRENT_DB_PATH/$table_name.meta"

gui_info "✔ Table '$table_name' created in database '$CURRENT_DB'."

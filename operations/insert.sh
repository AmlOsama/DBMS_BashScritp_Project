#!/bin/bash
# ============================================================
#  Reads .meta for column defs, validates int/string + PK uniqueness
# ============================================================

source "$SCRIPT_DIR/menu/gui_helpers.sh"

# ── 1. Pick table ─────────────────────────────────────────────
tables=$(ls "$CURRENT_DB_PATH"/*.meta 2>/dev/null | xargs -n1 basename -s .meta)
if [ -z "$tables" ]; then
    gui_error "No tables found in '$CURRENT_DB'."
    return
fi

list_args=()
while IFS= read -r t; do list_args+=("FALSE" "$t"); done <<< "$tables"

selected_table=$(zenity --list \
    --title="Insert into Table" \
    --text="Select a table:" \
    --radiolist \
    --column="Select" --column="Table" \
    --width=420 --height=380 \
    "${list_args[@]}" 2>/dev/null)

[[ $? -ne 0 || -z "$selected_table" ]] && return

# ── 2. Resolve paths ──────────────────────────────────────────
meta_file="$CURRENT_DB_PATH/$selected_table.meta"
data_file="$CURRENT_DB_PATH/$selected_table"

if [[ ! -f "$data_file" ]]; then
    gui_error "The selected table data file is missing or empty."
    return
fi

# ── 3. Find Primary Key column position ───────────────────────
pk_row=$(awk -F: '$3 == "true" { print NR; exit }' "$meta_file")
if [[ -z "$pk_row" ]]; then
    gui_error "Error: No Primary Key defined in metadata."
    return
fi

# ── 4. Collect values field-by-field  ──
new_record=""
col_index=0

while IFS=: read -r col_name col_type is_pk; do
    [[ -z "$col_name" ]] && continue
    col_index=$(( col_index + 1 ))

    if [[ "$is_pk" == "true" ]]; then
        # PK: must be unique
        while true; do
            user_input=$(gui_entry \
                "Insert — $selected_table" \
                "Field: <b>$col_name</b>  (type: $col_type)  [PRIMARY KEY]\n\nEnter a unique value:")
            [[ $? -ne 0 ]] && return

            # int validation (positive integer)
            if [[ "$col_type" == "int" && ! "$user_input" =~ ^[1-9][0-9]*$ ]]; then
                gui_error "Field '$col_name' must be a positive integer."
                continue
            fi

            # PK uniqueness check
            duplicate=$(awk -F: -v pk="$pk_row" -v kv="$user_input" '$pk == kv' "$data_file")
            if [[ -n "$duplicate" ]]; then
                gui_error "Primary key '$user_input' already exists. Must be unique."
                continue
            fi

            new_record="${new_record:+$new_record:}$user_input"
            break
        done
        continue
    fi

    # Non-PK field
    while true; do
        user_input=$(gui_entry \
            "Insert — $selected_table" \
            "Field: <b>$col_name</b>  (type: $col_type)\n\nEnter value:")
        [[ $? -ne 0 ]] && return

        if [[ "$col_type" == "int" ]]; then
            if [[ "$user_input" =~ ^[1-9][0-9]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                gui_error "Field '$col_name' must be a positive integer."
            fi
        elif [[ "$col_type" == "string" ]]; then
            
            if [[ "$user_input" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                new_record="${new_record:+$new_record:}$user_input"
                break
            else
                gui_error "Field '$col_name' must start with a letter or underscore\nand contain no spaces or special characters."
            fi
        fi
    done
done < "$meta_file"

# ── 5. Backup then append  ──────────────────
cp "$data_file" "$data_file.bak" || { gui_error "Could not create backup."; return; }
echo "$new_record" >> "$data_file"

gui_info "✔ New record inserted into '$selected_table'.\n\nRecord: $new_record"
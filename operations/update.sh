#!/bin/bash
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
    --title="Update Table" \
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

# ── 3. Identify Primary Key column position ───────────────────
pk_row=$(awk -F: '$3 == "true" { print NR; exit }' "$meta_file")
if [[ -z "$pk_row" ]]; then
    gui_error "No Primary Key defined in metadata."
    return
fi

pk_col_name=$(awk -F: 'NR=='"$pk_row"' { print $1 }' "$meta_file")

# ── 4. Show existing records ──────────────────────────────────
col_headers=()
while IFS=: read -r col_name _rest; do
    [[ -n "$col_name" ]] && col_headers+=("$col_name")
done < "$meta_file"

col_args=()
for h in "${col_headers[@]}"; do col_args+=("--column=$h"); done

all_rows=()
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    IFS=: read -ra fields <<< "$line"
    for f in "${fields[@]}"; do all_rows+=("$f"); done
done < "$data_file"

if [[ ${#all_rows[@]} -gt 0 ]]; then
    zenity --list \
        --title="Update $selected_table — Current Records" \
        --text="Current records in <b>$selected_table</b>.\nNote the <b>$pk_col_name</b> (PK) value you want to update:" \
        "${col_args[@]}" \
        --width=700 --height=420 \
        "${all_rows[@]}" 2>/dev/null
fi

# ── 5. Enter PK key value (loop until found or cancelled) ─────
while true; do
    key_value=$(gui_entry \
        "Update $selected_table" \
        "Primary Key column: <b>$pk_col_name</b>\n\nEnter the key value of the row to update\n(or cancel to go back):")
    [[ $? -ne 0 ]] && return

    target_line=$(awk -F: -v pk="$pk_row" -v kv="$key_value" \
        '$pk == kv { print NR; exit }' "$data_file")

    if [[ -z "$target_line" ]]; then
        gui_error "Record with key '$key_value' not found in '$selected_table'."
        continue
    fi
    break
done

# ── 6. Collect new values field-by-field ──────────────────────

new_record=""
col_index=0

while IFS=: read -r col_name col_type is_pk; do
    [[ -z "$col_name" ]] && continue
    col_index=$(( col_index + 1 ))

    if [[ "$is_pk" == "true" ]]; then
        # Preserve original PK value — same as original
        orig_pk=$(awk -F: -v line="$target_line" -v col="$col_index" \
            'NR == line { print $col }' "$data_file")
        new_record="${new_record:+$new_record:}$orig_pk"
        continue
    fi

    while true; do
        user_input=$(gui_entry \
            "Update $selected_table — New Values" \
            "Field: <b>$col_name</b>  (type: $col_type)\n\nEnter new value:")
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

# ── 7. Backup + sed replace  ────────────────
cp "$data_file" "$data_file.bak" || { gui_error "Could not create backup."; return; }
sed -i "${target_line}s/.*/$new_record/" "$data_file"

gui_info "✔ Line $target_line updated successfully.\n\nNew record: $new_record"

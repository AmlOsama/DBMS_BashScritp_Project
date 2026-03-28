#!/bin/bash
# ============================================================
#  Flow: pick table -> identify PK col -> show existing records
#        -> enter key value -> confirm -> backup + sed delete
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
    --title="Delete From Table" \
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

if [[ ! -s "$data_file" ]]; then
    gui_info "The table '$selected_table' is empty. No records to delete."
    return
fi

# ── 3. Identify Primary Key column position ───────────────────
pk_row=$(awk -F: '$3 == "true" { print NR; exit }' "$meta_file")
if [[ -z "$pk_row" ]]; then
    gui_error "No Primary Key defined in metadata."
    return
fi

# Get PK column name for the prompt
pk_col_name=$(awk -F: 'NR=='"$pk_row"' { print $1 }' "$meta_file")

# ── 4. Show existing records ───
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

# Show records (read-only preview) — 
if [[ ${#all_rows[@]} -gt 0 ]]; then
    zenity --list \
        --title="Delete From $selected_table — Current Records" \
        --text="Current records in <b>$selected_table</b>.\nNote the <b>$pk_col_name</b> (PK) value you want to delete:" \
        "${col_args[@]}" \
        --width=700 --height=420 \
        "${all_rows[@]}" 2>/dev/null
fi

# ── 5. Enter PK value to delete  ─
while true; do
    key_value=$(gui_entry \
        "Delete From $selected_table" \
        "Primary Key column: <b>$pk_col_name</b>\n\nEnter the key value of the row to delete\n(or cancel to go back):")
    [[ $? -ne 0 ]] && return   # cancel = quit

    target_line=$(awk -F: -v pk="$pk_row" -v kv="$key_value" \
        '$pk == kv { print NR; exit }' "$data_file")

    if [[ -z "$target_line" ]]; then
        gui_error "Record with key '$key_value' not found in '$selected_table'."
        continue
    fi
    break
done

# ── 6. Show record to be deleted and confirm ──────────────────
record_to_delete=$(awk -F: -v line="$target_line" 'NR == line { print $0 }' "$data_file")

gui_confirm "Found record at line $target_line:\n<b>$record_to_delete</b>\n\nAre you sure you want to delete this record?" || return

# ── 7. Backup + sed delete  ─────────────────
cp "$data_file" "$data_file.bak" || { gui_error "Could not create backup."; return; }
sed -i "${target_line}d" "$data_file"

gui_info "✔ Record with key '$key_value' has been deleted.\n\nDeleted: $record_to_delete"
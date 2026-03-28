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
    --title="Select From Table" \
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
    gui_error "The selected table is empty or missing."
    return
fi

# ── 3. Pick field to search on ─
field_list=()
while IFS=: read -r col_name col_type is_pk; do
    [[ -z "$col_name" ]] && continue
    field_list+=("FALSE" "$col_name")
done < "$meta_file"

selected_field=$(zenity --list \
    --title="Select — $selected_table" \
    --text="Choose a field to search by:" \
    --radiolist \
    --column="Select" --column="Field" \
    --width=380 --height=360 \
    "${field_list[@]}" 2>/dev/null)

[[ $? -ne 0 || -z "$selected_field" ]] && return

# ── 4. Enter search value ─────────────────────────────────────
search_value=$(gui_entry \
    "Select — $selected_table" \
    "Field: <b>$selected_field</b>\n\nEnter value to search for:")
[[ $? -ne 0 ]] && return

# ── 5. Run the  awk query ─────────────────────
# Collect column headers
col_headers=()
while IFS=: read -r col_name _rest; do
    [[ -n "$col_name" ]] && col_headers+=("$col_name")
done < "$meta_file"

# Find field index
field_num=0
idx=0
while IFS=: read -r col_name _rest; do
    [[ -z "$col_name" ]] && continue
    idx=$(( idx + 1 ))
    if [[ "$col_name" == "$selected_field" ]]; then
        field_num=$idx
        break
    fi
done < "$meta_file"

# Collect matching rows
match_rows=()
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    IFS=: read -ra fields <<< "$line"
    cell="${fields[$((field_num-1))]}"
    if [[ "$cell" == *"$search_value"* ]]; then
        for f in "${fields[@]}"; do
            match_rows+=("$f")
        done
    fi
done < "$data_file"

if [[ ${#match_rows[@]} -eq 0 ]]; then
    gui_info "No matching records found\nfor [$selected_field = $search_value] in '$selected_table'."
    return
fi

# Build --column args
col_args=()
for h in "${col_headers[@]}"; do
    col_args+=("--column=$h")
done

zenity --list \
    --title="Results: $selected_table  [ $selected_field = $search_value ]" \
    --text="Matching records in <b>$selected_table</b>  where <b>$selected_field</b> = '$search_value':" \
    "${col_args[@]}" \
    --width=700 --height=450 \
    "${match_rows[@]}" 2>/dev/null

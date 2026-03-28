#!/bin/bash
# ============================================================
#  Shows: table name + all attributes with type and PK flag
# ============================================================

source "$SCRIPT_DIR/menu/gui_helpers.sh"

found=0
list_args=()

for meta in "$CURRENT_DB_PATH"/*.meta; do
    [ -f "$meta" ] || continue

    table_name=$(basename "$meta" .meta)

    # Build attributes string name(type)[PK]
    attributes=""
    while IFS=: read -r col_name col_type is_pk; do
        [[ -z "$col_name" ]] && continue
        if [[ "$is_pk" == "true" ]]; then
            attributes+="$col_name($col_type)[PK]  "
        else
            attributes+="$col_name($col_type)  "
        fi
    done < "$meta"

    list_args+=("$table_name" "$attributes")
    found=1
done

if [[ $found -eq 0 ]]; then
    gui_info "No tables found in '$CURRENT_DB'."
    return
fi

zenity --list \
    --title="Tables in '$CURRENT_DB'" \
    --text="Tables in database: <b>$CURRENT_DB</b>" \
    --column="Table" --column="Attributes" \
    --width=680 --height=400 \
    "${list_args[@]}" 2>/dev/null
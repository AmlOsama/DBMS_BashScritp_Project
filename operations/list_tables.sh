:' echo ""
echo "==============================="
echo "   Tables in '$CURRENT_DB'"
echo "==============================="

found=0
for meta in "$CURRENT_DB_PATH"/*.meta; do
    [ -f "$meta" ] && echo "  • $(basename "$meta" .meta)" && found=1
done

[ $found -eq 0 ] && echo "  (no tables found)"
echo ""
read -rp "Press Enter to continue..."
source "./menu/db_menu.sh" '

echo ""
echo "==============================="
echo "   Tables in '$CURRENT_DB'"
echo "==============================="

found=0
for meta in "$CURRENT_DB_PATH"/*.meta; do
    if [ -f "$meta" ]; then
        table_name=$(basename "$meta" .meta)
        echo "  $table_name"
        
        # Read and display attributes in a single line
        attributes=""
        while IFS=: read -r col_name col_type is_pk; do
            if [[ "$is_pk" == "true" ]]; then
                attributes="$attributes $col_name($col_type)[PK],"
            else
                attributes="$attributes $col_name($col_type),"
            fi
        done < "$meta"
        
        # Remove trailing comma and display
        attributes=$(echo "$attributes" | sed 's/,$//')
        echo "     Attributes:$attributes"
        echo ""
        found=1
    fi
done

[ $found -eq 0 ] && echo "  (no tables found)"
echo ""
read -rp "Press Enter to continue..."
source "./menu/db_menu.sh"
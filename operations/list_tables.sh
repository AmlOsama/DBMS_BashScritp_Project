echo ""
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
source "./menu/db_menu.sh"
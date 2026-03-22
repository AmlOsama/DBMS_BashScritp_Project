echo ""
echo "Available databases:"
echo "----------------------------"

found=0
for db in "$DB_DIR"/*/; do
    if [ -d "$db" ]; then
        echo "  • $(basename "$db")"
        found=1
    fi
done

[ $found -eq 0 ] && echo "  (no databases found)"
echo ""
read -rp "Press Enter to continue..."
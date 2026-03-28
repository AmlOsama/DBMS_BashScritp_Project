#!/bin/bash
# ============================================================
#  Bash DBMS — Zenity GUI Entry Point
# ============================================================

export SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export DB_DIR="$SCRIPT_DIR/databases"
mkdir -p "$DB_DIR"

export CURRENT_DB=""
export CURRENT_DB_PATH=""

source "$SCRIPT_DIR/menu/main_menu.sh"

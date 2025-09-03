#!/bin/bash
# backup_csv.sh - Wrangle + Incremental Backup CSV files with timestamped filenames
# Usage: ./backup_csv.sh <source_dir> <backup_dir>

set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

LOG_FILE="./backup.log"

log() {
    msg="[$(date '+%a %b %d %I:%M:%S %p %Z %Y')] $1"
    echo -e "$msg" | tee -a "$LOG_FILE"
}

# --- Input check ---
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <source_dir> <backup_dir>"
    exit 1
fi

src="$1"
dest="$2"

if [[ ! -d "$src" ]]; then
    echo -e "${RED}Source directory does not exist: $src${NC}"
    exit 1
fi

mkdir -p "$dest"

# --- File to track modification times ---
mtime_file="$dest/.file_mtimes"
touch "$mtime_file"

# --- Wrangling Function ---
wrangle_file() {
    local file="$1"
    local base="$(basename -- "$file")"
    local name="${base%.*}"
    local ext="${base##*.}"

    echo -e "\n🔹 Wrangling file: $file"

    echo "Choose a wrangling option:
    1) Remove duplicates
    2) Extract specific columns
    3) Sort by a column
    4) Filter rows by numeric condition
    5) Count unique values in a column
    6) Skip wrangling"

    read -rp "Enter choice [1-6]: " choice

    case "$choice" in
        1) awk '!seen[$0]++' "$file" > "$src/${name}_deduped.${ext}" ;;
        2) read -rp "Enter column numbers (comma-separated, e.g. 1,3): " cols
           cut -d, -f"$cols" "$file" > "$src/${name}_cols_${cols}.${ext}" ;;
        3) read -rp "Enter column number to sort by: " col
           sort -t, -k"$col","$col" "$file" > "$src/${name}_sorted.${ext}" ;;
        4) read -rp "Enter column number for filtering: " col
           read -rp "Enter condition (e.g. >1000): " cond
           awk -F, "NR==1 || \$${col}${cond}" "$file" > "$src/${name}_filtered.${ext}" ;;
        5) read -rp "Enter column number to count unique values: " col
           cut -d, -f"$col" "$file" | sort | uniq -c > "$src/${name}_unique_counts.txt" ;;
        6) echo "Skipping $file" ;;
        *) echo "Invalid choice, skipping $file" ;;
    esac
}

# --- Ask for Wrangling ---
csv_files=("$src"/*.csv)
total=${#csv_files[@]}

if [[ $total -eq 0 ]]; then
    log "${YELLOW}⚠️ No CSV files found in $src${NC}"
    exit 0
fi

echo -e "Found $total CSV files in $src"
read -rp "How many files do you want to wrangle (0-$total)? " num

if (( num > 0 )); then
    for ((i=0; i<num; i++)); do
        echo "[$((i+1))/$num] Choose a file to wrangle:"
        select f in "${csv_files[@]}"; do
            wrangle_file "$f"
            break
        done
    done
else
    echo "Skipping wrangling step."
fi

# --- Incremental Backup Step ---
log "Backup started..."
for file in "$src"/*.csv; do
    [[ -e "$file" ]] || continue

    basename="$(basename -- "$file")"
    filename="${basename%.*}"
    ext="${basename##*.}"
    safe_name="$(echo "$filename" | tr -cd '[:alnum:]_-')"

    # Get current modification time
    current_mtime=$(stat -c %Y "$file")

    # Get last recorded modification time
    last_mtime=$(grep -F "$file" "$mtime_file" | awk '{print $2}' || echo "")

    if [[ "$current_mtime" != "$last_mtime" ]]; then
        timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
        backup_file="$dest/${safe_name}_backup_${timestamp}.${ext}"
        cp "$file" "$backup_file"
        log "${GREEN}✅ $file -> $backup_file${NC}"

        # Update mtime record
        grep -v -F "$file" "$mtime_file" > "$mtime_file.tmp" || true
        mv "$mtime_file.tmp" "$mtime_file"
        echo "$file $current_mtime" >> "$mtime_file"
    else
        log "${YELLOW}No changes in $file, skipping backup.${NC}"
    fi
done
log "Backup completed!"

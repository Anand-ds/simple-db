#!/bin/bash

DB_FILE="database"
DELIM=$'\t'

db_set () {
  # Remove existing entry for the key
  grep -v "^$1${DELIM}" "${DB_FILE}" > "${DB_FILE}.tmp" 2>/dev/null
  mv "${DB_FILE}.tmp" "${DB_FILE}"
  echo -e "$1${DELIM}$2" >> "${DB_FILE}"
  awk -F"${DELIM}" -v key="$1" '$1 == key { value = $2 } END { if (value) print value }' "${DB_FILE}"
}

db_get () {
  grep "^$1${DELIM}" "${DB_FILE}" | sed -e "s/^$1${DELIM}//" | tail -n 1
}

# --- CLI interface ---
command="$1"
key="$2"
value="$3"

case "$command" in
  set)
    db_set "$key" "$value"
    ;;
  get)
    db_get "$key"
    echo "Usage:"
    echo "  ./db set <key> <value>"
    echo "  ./db get <key>"
    echo "Note: Keys and values containing commas or special characters may not work as expected."
    echo "  ./db set <key> <value>"
    echo "  ./db get <key>"
    ;;
esac


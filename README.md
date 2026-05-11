# simple-db
A tiny, append-only key–value store implemented in pure Bash (a text file and a couple of Bash functions). Demonstrates database use of append-only logs.

## Features at a glance
1. Append‑only durability — every write is preserved
2. Human‑readable log — the database is a text file
3. Supports arbitrary values — JSON, XML, blobs, anything
4. Zero dependencies — works anywhere Bash does

Educational — mirrors the core of real database internals

## How it works
Each call to db_set appends a line to a log file:
```
Example log entry:
username,anand
```

This is the same principle behind Write‑Ahead Logs (WAL) | Event sourcing | LSM‑tree storage engines (used by LevelDB, RocksDB, Cassandra)
The difference? Here, the entire “database engine” fits in a few lines of Bash.
You can,

```bash
git clone https://github.com/anand_ds/simple-db.git
cd simple-db
chmod +x db.sh
```

```
# Make sure you are in the 'simple-db' directory before sourcing, (codespaces its workspaces\simple-db)
# because the script uses a relative path ('./db.sh') to load the database functions.
```

```
source ./db.sh
```

```
# Note: Run db_set and db_get commands in the same shell session after sourcing db.sh,
# so that the functions are available in your environment.
# By default, the database log file is stored as 'db.log' in the current directory.
```

```
# To use a different log file, set the DB_FILE environment variable before running commands:
# Set the DB_FILE environment variable in the same shell session before sourcing or running commands:
# Run this before sourcing db.sh or running any db_set/db_get commands:
# export DB_FILE=/path/to/your-db.log
```

```
# Note: When using db_set, always quote the value argument if it contains spaces, braces, or special characters to prevent Bash parsing errors.
db_set user:001 '{"name":"Anand","role":"admin"}'
db_set user:002 '{"name":"Lakshmi","role":"editor"}'
db_set user:001 '{"name":"Anand","role":"superadmin"}'
```

```
# The following command is repeated to show that writing the same key-value pair multiple times does not change the stored value or affect the log's semantics (idempotency):
db_set user:001 '{"name":"Anand","role":"superadmin"}'
db_get user:001  {"name":"Anand","role":"superadmin"}
db_set city:london '{"name":"London","population":9304016,"tags":["capital","uk","europe"]}'
db_get city:london
```

```
# Note: To store binary data (such as images), encode it as base64 first, since Bash and text files do not handle raw binary data reliably.
encoded=$(base64 < photo.jpg)
db_set avatar:42 "$encoded"
# To decode and restore the original file:
# echo "$encoded" | base64 --decode > photo.jpg
# To retrieve and decode the image:
# db_get avatar:42 | base64 --decode > photo-out.jpg
```

```
db_set "event:$(date +%s)" "User logged in"
```

```
# A tiny ledger (numeric-only values)
# For numeric-only logs (like a ledger), use a unique delimiter (e.g., TAB) to avoid issues with commas in values:
db_set() { echo -e "$1\t$2" >> "${DB_FILE:-simple-db.log}"; }
db_set balance:anand +10
db_set balance:anand -3
db_set balance:anand +7
# Now sum the balances safely using TAB as the delimiter:
grep -P "^balance:anand\t" simple-db.log | awk -F'\t' '{sum+=$2} END {print sum}'
# Warning: If you use commas as delimiters, values containing commas (such as JSON) will break field parsing.
# For general key-value storage (especially with JSON), stick to the original comma delimiter, but for numeric-only logs, prefer a delimiter that cannot appear in the value.
# To sum the balance, extract the numeric values from the log file (assumed to be 'simple-db.log'):
grep "^balance:anand" simple-db.log | awk -F',' '{sum+=$2} END {print sum}'
```

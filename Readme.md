# CSV Backup & Data Wrangling Automation

## Overview

This project automates the process of wrangling and backing up CSV files.
It allows the user to:

- Wrangle CSV files interactively (remove duplicates, filter, sort, extract columns, count unique values).
- Perform incremental backups — only files that are new or changed are backed up.
- Maintain timestamped backups and logs for easy tracking.

## Features

- Interactive wrangling options:
  - Remove duplicates
  - Extract specific columns
  - Sort by a column
  - Filter rows by numeric conditions
  - Count unique values in a column
- Incremental backup based on file modification times.
- Automatic detection of new files added to the source folder.
- Backup files named with timestamps for easy versioning.
- Logs all operations to `backup.log`.
- Written entirely in Bash, no external dependencies needed.


## Prerequisites

- Linux or macOS environment
- Bash shell
- Standard Linux commands: `awk`, `cut`, `sort`, `uniq`, `stat`, `cp`, `grep`, `tee`
- No extra installations are required.

## Usage

### 1. Generate CSV files (optional)

If you need test CSVs, use `generate_csvs.py`:

```bash
python3 generate_csvs.py --num-files 10 --size-mb 50 --output-dir ./data
```

### 2. Run the backup + wrangling script 
```bash
./scripts/backup_csv.sh ./data ./backup
```


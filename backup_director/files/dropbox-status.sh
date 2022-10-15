#!/bin/sh

# Bacula helper script to report the current Dropbox status via the bacula
# console.

echo "Reporting current Dropbox status"

~/dropbox.py status

exit 0

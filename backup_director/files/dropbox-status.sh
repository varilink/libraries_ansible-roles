#!/bin/sh

# Bacula helper script to report the current Dropbox status via the bacula
# console.

HOME=/var/local/bacula

echo "Reporting current Dropbox status"

/var/lib/bacula/dropbox.py status

exit 0

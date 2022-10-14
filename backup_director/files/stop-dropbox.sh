#!/usr/bin/env bash

# Bacula helper script to stop the Dropbox daemon. This is run at the start of
# each backup job so that Dropbox is not attempting synchronisation while the
# job is writing to the Dropbox folder.

echo "Reporting Dropbox status at start of job:"
~/dropbox.py status

# Stop Dropbox
~/dropbox.py stop

# Pause for the command that we just issued to take effect
sleep 10

echo "Reporting Dropbox status after stop command issued:"
~/dropbox.py status

exit 0

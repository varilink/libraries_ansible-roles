#!/usr/bin/env bash

# Bacula helper script to start the Dropbox daemon. This is run at the end of
# each backup job so that Dropbox may renew synchronisation of any new content
# in the Dropbox folder that the backup job has written.

# Sort out ownership of any boostrap files. By default these are owned by
# root:root but since Dropbox is installed for the bacula user they won't
# synchronise to Dropbox if we change their ownership to bacula:bacula
chown bacula:bacula /var/lib/bacula/Dropbox/bacula-test/*.bsr

echo "Reporting Dropbox status at end of job:"
gosu bacula bash -c '~/dropbox.py status'

# Start Dropbox filtering out Python informational messages
gosu bacula bash -c '~/dropbox.py start 2>/dev/null'

# Pause for the command that we just issued to take effect
sleep 10

echo "Reporting Dropbox status after start command issued:"
gosu bacula bash -c '~/dropbox.py status'

exit 0

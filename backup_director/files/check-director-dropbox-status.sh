#!/usr/bin/env bash
# Script to check the current Dropbox status on the backup director. This is
# "Run Before Job" for an admin job so that its success or failure status is
# reflected in the success or failure status of the job itself.

echo 'Checking current Dropbox status'
status=$(/var/lib/bacula/dropbox.py status)
echo $status

if [[ $status == 'Up to date' ]]; then
  # Consider status 'Up to date' to be success
  exit 0
else
  # Consider any status other than 'Up to date' to be failure
  exit 1
fi

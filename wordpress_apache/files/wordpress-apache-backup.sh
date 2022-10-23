# This script finds the WordPress websites that are installed on this server and
# for each of those websites, it does the following:
# 1. Echo the path of the folder that contains all the files for the website.
# 2. Delete from the /tmp folder any database export files for the website that
#    have previously been created by this script.
# 3. Export the database for the website to a file in the /tmp folder.
# 4. Echo the path of the file that contains the database export just created.
#
# This script is invoked by the bacula director via a pipe that returns its
# output to a File value within the FileSet snippet for the role that is applied
# WordPress hosts. Thus it informs the bacula director of what files to backup
# for all the WordPress sites on this server, having also created the lastest
# database exports for those sites.
#
# Note this requires that the find package for the wp-cli is installed via
# wp package install wp-cli/find-command

# Go into the /tmp folder so that database exports are written there.
cd /tmp

# Find all the WordPress websites that use Apache on the server.
for SITE in $(                                                                 \
  wp --allow-root find --format=json /var/www |                                \
  jq '.[].version_path'                       |                                \
  cut --delimiter=/ --fields=4                                                 \
)
do
  echo /var/www/$SITE/html
  TR_SITE=`echo $SITE|tr . _`
  for DUMP in $(ls /tmp/${TR_SITE}*.sql 2>/dev/null)
  do
    rm $DUMP
  done
  EXPORT=$(                                                                    \
    wp --allow-root --path=/var/www/$SITE/html db export --porcelain           \
  )
  echo /tmp/$EXPORT
done

# Return to initial folder. This is here for when testing this script in-situ on
# a WordPress host. It's irrelevant when the script is run via a backup job.
cd - > /dev/null

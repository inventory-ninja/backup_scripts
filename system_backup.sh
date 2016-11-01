#!/bin/bash
# S.Groundwater 2016
# Backup Drupal and Apache Files

# Email From Address
FROM="bar@example"
# Email To Address
EMAIL="foo@example.com"
SUBJECT="Inventory System Backup"
EMAILMESSAGE="msg.txt"
sitename="Inventory.Ninja"
database_name="ninja"
database_user="ninja"
database_password="ninja"

# File Name Setup
NOW=$(date +"%Y%m%d")
STATIC_HTDOC_FILES="Inventory_HTDOCS.$NOW.tgz"
STATIC_SERVER_FILES="Inventory_Server_Files.$NOW.tgz"
SQL_FILES="$sitename.SQL.$NOW.sql"
SQL_ZIP="$sitename.SQL.$NOW.tgz"

# Backup Master Drupal Site Files, HTDOCS
tar cvfz /var/backups/inventory/$STATIC_HTDOC_FILES \
 /var/www/html/inventory.ninja/ 2>>tar_error.txt
echo "Inventory HTDOCS Backup Status" >> $EMAILMESSAGE
cat tar_error.txt >> $EMAILMESSAGE
echo "--------------------------" >> $EMAILMESSAGE

# Backup Apache Site Config Files and Misc Scripts
tar cvfz /var/backups/inventory/$STATIC_SERVER_FILES /etc/apache2/sites-available \
/etc/ssl /etc/apache2 /var/backups/scripts /usr/lib/apache2 
echo "Inventory Apache Site Backup Status and Misc Scripts" >> $EMAILMESSAGE
cat tar_error.txt >> $EMAILMESSAGE
echo "--------------------------" >> $EMAILMESSAGE

#Backup MySQL Databases
mysqldump -u$database_user -p$database_password $database_name > /var/backups/inventory/$SQL_FILES 2>>sql_error.txt
#Zip SQL Files
tar cvfz /var/backups/inventory/$SQL_ZIP /var/backups/inventory/*.sql 2>>tar_error.txt
#Cleanup SQL files
#rm /var/backups/inventory/$sitename/*.sql

echo "SQL Backup Status" >> $EMAILMESSAGE
cat sql_error.txt >> $EMAILMESSAGE
echo "-------------------------">> $EMAILMESSAGE


# Test for command results and drop in tmp file
date >> $EMAILMESSAGE
echo $? >> $EMAILMESSAGE
echo "Date / Time Run" >>$EMAILMESSAGE
echo "--------------------------">> $EMAILMESSAGE
echo "Current Disk Usage:">> $EMAILMESSAGE
df -H >> $EMAILMESSAGE
echo "Server Uptime"
uptime >> $EMAILMESSAGE
# send an email using /bin/mail
#/usr/bin/mail -s "$SUBJECT" "$EMAIL" < $EMAILMESSAGE
xargs -a email_addresses.txt mail --append="Content-type: text/html" -s "$SUBJECT" -a "From:$FROM" < $EMAILMESSAGE

# Cleanup Tmp Fies
rm tar_error.txt
rm msg.txt

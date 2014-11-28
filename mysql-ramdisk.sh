#!/bin/bash

RAMDISK_SIZE_MB=200

RAMDISK_NAME='mysql-ramdisk'
PORT=3307
USER=mysql

MYSQL_INSTALL_DIR="/usr/local/mysql"
MYSQLD="$MYSQL_INSTALL_DIR/bin/mysqld"
MYSQL="$MYSQL_INSTALL_DIR/bin/mysql"
MYSQL_INSTALL_DB="$MYSQL_INSTALL_DIR/scripts/mysql_install_db"

#You need to specify the size in 512K blocks. Use this formula to calculate the number of blocks to use in the ram argument below.
RAMDISK_BLOCK_COUNT=$((RAMDISK_SIZE_MB*1024*1024/512))

diskutil erasevolume HFS+ "$RAMDISK_NAME" `hdiutil attach -nomount ram://$RAMDISK_BLOCK_COUNT`

#Install new DB

$MYSQL_INSTALL_DB \
    --user=$USER \
    --basedir=$MYSQL_INSTALL_DIR \
    --datadir=/Volumes/$RAMDISK_NAME


#Start MySQL
$MYSQLD \
    --basedir=$MYSQL_INSTALL_DIR \
    --datadir=/Volumes/$RAMDISK_NAME \
    --user=$USER \
    --log-error=/Volumes/$RAMDISK_NAME/mysql.ramdisk.err \
    --pid-file=/Volumes/$RAMDISK_NAME/mysql.ramdisk.pid \
    --port=$PORT \
    --socket=/tmp/mysql_ram.sock

#Test connection
$MYSQL \
    -u root \
    --socket=/tmp/mysql_ram.sock \
    -e "SHOW DATABASES;"
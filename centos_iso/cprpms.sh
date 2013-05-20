#!/bin/sh

ALL_RPMS_DIR=/mnt/cdrom/CentOS
TO_RPMS_DIR=/los/CentOS

package_list=/root/packages.list

while read line
do

if [ -f $ALL_RPMS_DIR/$line.rpm ]; then
    echo "cp $ALL_RPMS_DIR/$line.rpm"
    cp $ALL_RPMS_DIR/$line.rpm /los/CentOS
else
    echo "do not have $ALL_RPMS_DIR/$line.rpm"
fi


done < $package_list


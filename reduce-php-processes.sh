#!/bin/bash
FILES=`ls -1 *.conf`
for file in $FILES
do
        sed -i -e "s@^pm.start_servers = 5@pm.start_servers = 2@g" \
            -e "s@^pm.min_spare_servers = 5@pm.min_spare_servers = 2@g" \
            -e "s@^pm.max_spare_servers = 35@pm.max_spare_servers = 5@g" \
            -e "s@^pm.max_children = 50@pm.max_children = 25@g" $file
        echo "$file cambiado ...."
done

#!/bin/bash

echo "----Wiki Sdditional Setup----"

echo "Adding "wiki" to group 'docker'"

usermod -aG docker wiki

echo "Import Nginx configuration"

cp wiki.conf /etc/nginx/include/wiki.conf

echo "Moving compose file to home"
cp compose.yml /home/wiki

echo "Creating '/home/wiki/data' directory and contents"
mkdir /home/wiki/data
touch /home/wiki/data/wiki.db

echo "Ensuring correct rights"
chmod 744 -R /home/wiki
chown wiki:wiki -R /home/wiki
chmod 777 -R /home/wiki/data/

echo "Fetching certificates to add to the image"
mkdir certs
cp /var/certs/* certs/
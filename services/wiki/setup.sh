#!/bin/bash

echo "Creating '/home/wiki/wiki' directory"

mkdir /home/wiki/wiki
chown wiki:wiki /home/wiki/wiki

cp wiki.conf /etc/nginx/include/wiki.conf
touch /home/wiki/wiki/wiki.db
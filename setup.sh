#!/bin/bash

# Ensure installations
# pacman -Syu nano nginx docker docker-compose

# Ensure root
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

# Ensure /etc/nginx/include
echo "Ensure '/etc/nginx/include' exists"
d="/etc/nginx/include"
if [ ! -d "$d" ]; then
    mkdir "$d"
    chmod 744 "$d"
    chown root:root "$d"
fi

# Ensure nginx includes confs
echo "Ensure nginx includes confs"
echo "Editor will open to edit /etc/nginx/nginx.conf, make sure there's an 'include include/*.conf' clause in the http section."
pause
nano /etc/nginx/

# Setup generic services
echo "Setup generic services"

for s in services/*; do
    g=$(basename "$s")
    service="$s/$g.service"

    echo "Setting up '$g' service"

    if [ ! -f "$service" ]; then
        echo "No service file, skipping setup"
        continue
    fi

    groupadd $g
    if [ ! -z $? ]; then
        echo "Group '$g' already exists, skipping setup"
        continue
    fi

    useradd -m -g $g $g
    if [ ! -z $? ]; then
        echo "User '$g' already exists, skipping setup"
        continue
    fi

    cp "$service" "/etc/systemd/system/$g.service"
    chmod 744 "/etc/systemd/system/$g.service"
    chown $g:$g "/etc/systemd/system/$g.service"

    if [ -f "$s/setup.sh" ]; then
        echo "Running file '"$s/setup.sh"'"
        "$s/setup.sh"
    fi
done

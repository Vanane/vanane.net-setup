#!/bin/bash

# Ensure installations
# pacman -Syu nano nginx docker docker-compose

# Ensure root
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

# Setup generic services
echo "Setup generic services"

for s in services/*; do
    g=$(basename "$s")
    service="$s/$g.service"

    echo "Cleaning up '$g' service"

    if [ ! -f "$service" ]; then
        echo "No service file, skipping cleanup"
        continue
    fi

    systemctl disable "$g"

    userdel $g
    groupdel $g

    if [ -f "$s/cleanup.sh" ]; then
        echo "Running file '"$s/cleanup.sh"'"
        _cd=$(pwd)
        cd "$s"
        source cleanup.sh
        cd $_cd
    fi

done

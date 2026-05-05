#!/bin/bash

# Ensure installations
# pacman -Syu nano nginx docker docker-compose

# Ensure root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Ensure needed packages
echo "Ensuring that all needed packages are present"
p="certbot certbot-nginx nano nginx docker docker-compose"
missing=""

for i in $p; do
    $i --version &>/dev/null
    if [ $? -eq 127 ]; then
        missing="$missing $i"
    fi
done


if [ ! -z "$missing" ]; then
    echo "Packages are missing :$missing."
    echo "Aborting."
    exit 2
fi

# Ensure certs
echo "Ensuring the existence of SSL certificates"
d="/var/certs"
if [ ! -d "$d" ]; then
    echo "Please create directory '/var/certs' and store the server's certificate keys."
    echo "Use 'certbot certonly --nginx' to generate them."
    exit 3
fi

# Ensure /etc/nginx/include
echo "Ensuring '/etc/nginx/include' exists"
d="/etc/nginx/include"
if [ ! -d "$d" ]; then
    echo "    Creating it"
    mkdir "$d"
    chmod 744 "$d"
    chown root:root "$d"
fi

# Ensure nginx includes confs
echo "Ensuring nginx includes confs"
echo "    Editor will now open '/etc/nginx/nginx.conf', make sure there's an 'include include/*.conf' clause in the http section."
read -p "Press any keys to continue..."
nano /etc/nginx/nginx.conf

# Setup generic services
echo "----Setup generic services----"

for s in services/*; do
    g=$(basename "$s")
    service="$s/$g.service"

    echo "Setting up '$g' service"

    if [ ! -f "$service" ]; then
        echo "    No service file, skipping setup"
        continue
    fi

    groupadd $g
    if [ "$?" == "9" ]; then
        echo "    Group '$g' already exists, skipping setup"
        continue
    fi

    useradd -m -g $g $g
    if [ "$?" == "9" ]; then
        echo "    User '$g' already exists, skipping setup"
        continue
    fi

    cp "$service" "/etc/systemd/system/$g.service"
    chmod 744 "/etc/systemd/system/$g.service"
    chown $g:$g "/etc/systemd/system/$g.service"

    if [ -f "$s/setup.sh" ]; then
        echo "Running file '"$s/setup.sh"'"
        _cd=$(pwd)
        cd "$s"
        source setup.sh
        cd $_cd
    fi

    systemctl enable "$g"
done

nginx -t && nginx -s reload
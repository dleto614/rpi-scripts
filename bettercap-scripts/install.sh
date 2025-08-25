#!/usr/bin/env bash

echo "Installing packages"

sudo apt update && sudo apt upgrade --assume-yes && sudo apt install --assume-yes tcpdump aircrack-ng bettercap

echo "Creating directories"

sudo mkdir -p /var/log/bettercap_handshakes/
sudo mkdir -p /usr/local/share/bettercap/caplets/

echo "Copying files to their respective locations"

sudo cp pwnagotchi.cap /usr/local/share/bettercap/caplets/pwnagotchi.cap
sudo cp bettercap-launcher /usr/bin/bettercap-launcher && sudo chmod +x /usr/bin/bettercap-launcher
sudo cp bettercap.service /etc/systemd/system/bettercap.service && sudo chmod +x /etc/systemd/system/bettercap.service

echo "Starting bettercap service"

sudo systemctl daemon-reload
sudo systemctl start bettercap.service
sudo systemctl enable bettercap.service

echo "Done!"
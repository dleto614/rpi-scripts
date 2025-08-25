#!/usr/bin/env bash

echo "Installing packages"

sudo apt update && sudo apt upgrade --assume-yes && sudo apt install tcpdump

echo "Copying files to their respective locations"

sudo cp start_tcpdump.sh /root/start_tcpdump.sh && sudo chmod +x /root/start_tcpdump.sh
sudo cp start-tcpdump.service /etc/systemd/system/start-tcpdump.service && sudo chmod +x /etc/systemd/system/start-tcpdump.service

echo "Starting responder service"

sudo systemctl daemon-reload
sudo systemctl start start-tcpdump.service
sudo systemctl enable start-tcpdump.service

echo "Done!"
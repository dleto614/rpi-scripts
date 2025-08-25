#!/usr/bin/env bash

echo "Installing packages"

sudo apt update && sudo apt upgrade --assume-yes && sudo apt install responder

echo "Copying files to their respective locations"

sudo cp start_responder.sh /root/start_responder.sh && sudo chmod +x /root/start_responder.sh
sudo cp start-responder.service /etc/systemd/system/start-responder.service && sudo chmod +x /etc/systemd/system/start-responder.service

echo "Starting responder service"

sudo systemctl daemon-reload
sudo systemctl start start-responder.service
sudo systemctl enable start-responder.service

echo "Done!"
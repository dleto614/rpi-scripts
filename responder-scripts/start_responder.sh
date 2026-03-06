#!/bin/bash

# Add a feature where it checks if responder successfully was created in screen.

screen -S responder -d -m responder -I eth0
exit
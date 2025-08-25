#!/bin/bash

tcpdump -i eth0 -s 0 -w /var/log/tcpdump/dump_$(date +%Y-%m-%d-%H%M%S).pcap &>/dev/null &
exit

# Scripts:

This folder is just to hold generic scripts that I use either to extract data or to configure certain things.

------

For the `extract_handshakes.sh` script, you need to install `cap2hccapx` so the pcap created by bettercap can be converted to format that hashcat uses.

For the `extract-kerberos.sh` and `extract-ntlm.sh`, you need tshark installed. For Kerberos, there is a small python3 script (ew) that needs to be used for one of the hashes which for some reason is in a different field which you can't extract or decode using tshark. For that, you also need impacket installed.

------

------

For the `create-hotpsot.sh` script, you just need nmcli installed and required arguments are `-s` and `-i` which are SSID and wireless interface such as wlan0 or wlan1.

------

Future plans:

- ~~Write a script to enable the AP hotspot via nmcli~~ (finished, but not tested since I don't have network manager running on my main systems, but it should work just fine since the commands are exactly the same that I've used for my RPi)
- Probably more install scripts or similar

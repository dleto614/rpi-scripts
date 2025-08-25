# Scripts:

This folder is just to hold generic scripts that I use either to extract data or to configure certain things.

------

For the `extract_handshakes.sh` script, you need to install `cap2hccapx` so the pcap created by bettercap can be converted to format that hashcat uses.

For the `extract-kerberos.sh` and `extract-ntlm.sh`, you need tshark installed. For Kerberos, there is a small python3 script (ew) that needs to be used for one of the hashes which for some reason is in a different field which you can't extract or decode using tshark. For that, you also need impacket installed.

------

Future plans:

- Write a script to enable the AP hotspot via nmcli
- Probably more install scripts or similar
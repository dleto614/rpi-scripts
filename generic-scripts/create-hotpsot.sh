#!/usr/bin/env bash

# Create hotspot using nmcli (ew)

SSID=""
PASSWORD=""
INTERFACE=""

OPEN=false
TEMP=false

usage() { # Print the usage
  echo "Usage: $0 [ -s NAME FOR THE AP HOTSPOT (SSID) ]
                  [ -i WIRELESS INTERFACE (e.g. wlan0) ]
                  [ -p PASSWORD (Default action would be to prompt for password) ]
                  [ --open SET IF YOU WANT AN OPEN HOTSPOT OR NOT (true or false and default is false) ]
                  [ --temp SET IF YOU WANT A PERMAMENT HOTSPOT OR TEMPORARY (true or false and default is false) ]
                  [ -h --help HELP ]" 1>&2
}

exit_error() { # Function: Exit with error

  usage
  echo "-------------"
  echo "Exiting!"
  exit 1

}

while [[ $# -gt 0 ]]
do
  case "$1" in
    -s)
      SSID="$2"
      shift 2
      ;;
    -i)
      INTERFACE="$2"
      shift 2
      ;;
    -p)
      PASSWORD="$2"
      shift 2
      ;;
    --open)
      OPEN=true
      shift
      ;;
    --temp)
      TEMP=true
      shift
      ;;
    -h|--help)
      echo "---------------"
      exit_error
      ;;
    *)
      echo "Unknown option: $1"
      exit_error
      ;;
  esac
done

if [[ -z "$SSID" || -z "$INTERFACE" ]]
then
  exit_error
  exit 1
fi

# Only ask for ap password if --open flag is not passed.

if [[ "$OPEN" == false && -z "$PASSWORD" ]]
then
  read -s -p "Input hotspot password: " PASSWORD
  echo
fi

# The main block to setup the aps based on flag inputs.
# This is a clusterfuck. Will fix later. -.-

# Check if temp flag was passed.

if [[ "$TEMP" == true ]]
then
  if [[ "$OPEN" == true ]]
  then

    echo "[*] Setting up temporary open ap"
    echo ""

    nmcli con add type wifi ifname "$INTERFACE" con-name "$SSID" ssid "$SSID"
    
    nmcli con modify "$SSID" 802-11-wireless.mode ap
    nmcli con modify "$SSID" ipv4.method shared
    nmcli con modify "$SSID" ipv6.method shared
    nmcli con modify "$SSID" connection.autoconnect no # This is needed to avoid saving the connections so they won't be brought up on boot.
    
    nmcli con up "$SSID"

  else

    echo ""
    echo "[*] Setting up temporary wpa2 ap"
    echo ""

    nmcli con add type wifi ifname "$INTERFACE" con-name "$SSID" ssid "$SSID"
    
    nmcli con modify "$SSID" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
    nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
    nmcli con modify "$SSID" wifi-sec.psk "$PASSWORD"
    nmcli con modify "$SSID" 802-11-wireless-security.proto rsn
    nmcli con modify "$SSID" 802-11-wireless-security.group ccmp
    nmcli con modify "$SSID" 802-11-wireless-security.pairwise ccmp
    nmcli con modify "$SSID" connection.autoconnect no
    
    nmcli con up "$SSID"

  fi
else
  if [[ "$OPEN" == true ]]
  then

    # Setup open wifi hotspot (persistent)

    echo "[*] Setting up open wifi hotspot"
    echo ""

    nmcli con add type wifi ifname "$INTERFACE" con-name "$SSID" ssid "$SSID"
    
    nmcli con modify "$SSID" 802-11-wireless.mode ap
    nmcli con modify "$SSID" ipv4.method shared
    nmcli con modify "$SSID" ipv6.method shared
    nmcli con modify "$SSID" connection.autoconnect yes
    
    nmcli con up "$SSID"

  else

    # Setup password protected wpa2-psk wifi hotspot (persistent)

    echo ""
    echo "[*] Setting up wpa2 ap"
    echo ""

    nmcli con add type wifi ifname "$INTERFACE" con-name "$SSID" ssid "$SSID"

    nmcli con modify "$SSID" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
    nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
    nmcli con modify "$SSID" wifi-sec.psk "$PASSWORD"
    nmcli con modify "$SSID" 802-11-wireless-security.proto rsn
    nmcli con modify "$SSID" 802-11-wireless-security.group ccmp
    nmcli con modify "$SSID" 802-11-wireless-security.pairwise ccmp
    nmcli con modify "$SSID" connection.autoconnect yes
    
    nmcli con up "$SSID"

  fi
fi


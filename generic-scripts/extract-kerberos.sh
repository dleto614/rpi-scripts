#!/usr/bin/env bash

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
            exit_exit
            ;;
    esac
done

if [[ -z "$pcap_file" ]]
then
    exit_error
    exit 1
fi

echo "[*] Extracting Kerberos hashes from $pcap_file"

# Handle AS-REP and TGS-REP (using tshark)
tshark -r "$pcap_file" -Y "kerberos.msg_type == 11 || kerberos.msg_type == 13" -T fields \
  -e frame.number \
  -e kerberos.msg_type \
  -e kerberos.realm \
  -e kerberos.CNameString \
  -e kerberos.etype \
  -e kerberos.cipher | while IFS=$'\t' read -r frame msg_type crealm cname etype cipher; do

  [[ -z "$msg_type" || -z "$crealm" || -z "$cname" || -z "$etype" || -z "$cipher" ]] && continue

  realm_upper=$(echo "$crealm" | tr '[:lower:]' '[:upper:]')
  cname_clean=$(echo "$cname" | tr -d ' ,\r\n')
  etype_clean=$(echo "$etype" | cut -d',' -f1)
  cipher_clean=$(echo "$cipher" | tr -d ' ,\r\n')

  case "$msg_type" in
    11)
      checksum="${cipher_clean:0:32}"
      encrypted_data="${cipher_clean:32}"
      
      if [[ -n "$output_file" ]]
      then
        echo "Found hash: \$krb5asrep\$${etype_clean}\$${cname_clean}@${realm_upper}:${checksum}\$${encrypted_data}"
        echo "\$krb5asrep\$${etype_clean}\$${cname_clean}@${realm_upper}:${checksum}\$${encrypted_data}" >> "$output_file"
      fi
      
      ;;
    13)
      service="krbtgt/${realm_upper}*"
      checksum="${cipher_clean:0:32}"
      encrypted_ticket="${cipher_clean:32}"

      if [[ -n "$output_file" ]]
      then
        echo "Found hash: \$krb5tgs\$${etype_clean}\$*${cname_clean}\$${realm_upper}\$${service}\$${checksum}\$${encrypted_ticket}"
        echo "\$krb5tgs\$${etype_clean}\$*${cname_clean}\$${realm_upper}\$${service}\$${checksum}\$${encrypted_ticket}" >> "$output_file"
      fi

      ;;
  esac
done

# Handle AS-REQ (msg_type 10, using padata_value instead of cipher)
tshark -r "$pcap_file" -Y "kerberos.msg_type == 10" -T fields \
  -e frame.number \
  -e kerberos.msg_type \
  -e kerberos.realm \
  -e kerberos.etype \
  -e kerberos.padata_value | while IFS=$'\t' read -r frame msg_type crealm etype padata; do

  [[ -z "$msg_type" || -z "$crealm" || -z "$etype" || -z "$padata" ]] && continue

  etype_name() {
    case "$1" in
      1) echo "des-cbc-crc" ;;
      3) echo "des-cbc-md5" ;;
      16) echo "des3" ;;
      17) echo "aes128" ;;
      18) echo "aes256" ;;
      23) echo "u5" ;;  # RC4-HMAC
      *) echo "etype$1" ;;  # fallback, unknown etype
    esac
  }

  realm_upper=$(echo "$crealm" | tr '[:lower:]' '[:upper:]')
  etype_clean=$(echo "$etype" | cut -d',' -f1 | tr -d '[:space:]')
  padata_clean=$(echo "$padata" | cut -d',' -f1 | tr -d '[:space:]')

  encryption_name=$(etype_name $etype_clean)
  
  final_hash=$(python3 ./extract-padata.py "$padata_clean")

  if [[ -n "$final_hash" && -n "$output_file" ]]
  then
    echo "Found hash: \$krb5pa\$${etype_clean}\$${encryption_name}\$${realm_upper}\$dummy\$${final_hash}"
    echo "\$krb5pa\$${etype_clean}\$${encryption_name}\$${realm_upper}\$"dummy"\$${final_hash}" >> "$output_file"
  fi
done

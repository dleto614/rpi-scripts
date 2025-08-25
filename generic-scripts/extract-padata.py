import sys
from impacket.krb5.asn1 import EncryptedData
from pyasn1.codec.der.decoder import decode as der_decode

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <padata_value_hex>")
        sys.exit(1)
    
    padata_hex = sys.argv[1]
    try:
        padata_bytes = bytes.fromhex(padata_hex)
        enc_data, _ = der_decode(padata_bytes, asn1Spec=EncryptedData())
        cipher = bytes(enc_data['cipher']).hex()
        checksum = cipher[:32]
        encrypted_data = cipher[32:]
        final_hash = encrypted_data + checksum
        print(final_hash)
    except Exception as e:
        # print(f"Error decoding padata_value: {e}", file=sys.stderr)
        sys.exit(2)

if __name__ == "__main__":
    main()

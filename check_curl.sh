openssl pkcs12 -in client.p12 -out file.key.pem -nocerts -nodes
openssl pkcs12 -in client.p12 -out file.crt.pem -clcerts -nokeys
curl -k -L -E  ./file.crt.pem --key ./file.key.pem <ip>

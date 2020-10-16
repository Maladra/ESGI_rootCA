## Get client Key for connection
openssl pkcs12 -in client.p12 -out file.key.pem -nocerts -nodes
## Get client cert for connection
openssl pkcs12 -in client.p12 -out file.crt.pem -clcerts -nokeys
## Try connection
curl -k -L -E  ./file.crt.pem --key ./file.key.pem <ip>

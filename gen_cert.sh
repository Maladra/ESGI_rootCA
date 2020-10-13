#/bin/bash

apt-get -y install nginx
##VAR
country="FR"
state="France"
locality="Paris"
organisation_ca="certificat_autorithy"
organisation_ca_unit="CA"
organisation_crt="client_certificat"
organisation_crt="CC"
password="ESGI2020?"
username="maladra"

# Create the CA Key for signing Client Certs
openssl genrsa -des3 -passout pass:"$password" -out "ca.key" 4096

# Create the CA Certificate for signing certs
openssl req -new -x509 -days 365 -key "ca.key" -out "ca.crt" -passin pass:"$password" -subj "/C=$country/ST=$state/L=$locality/O=$organisation_ca/OU=$organisation_ca_unit/CN=/emailAddress="

# Create key for web server
openssl genrsa -out "server.key" 4096

# Create req cert for web server
openssl req -new -key "server.key" -out "server.req" -sha256 -passin pass:$password -subj "/C=$country/ST=$state/L=$locality/O=$organisation_crt/OU=$organisation_crt/CN=/emailAddress="

# Create cert for web server
openssl x509 -req -in "server.req" -CA "ca.crt" -CAkey "ca.key" -set_serial 100 -extensions server -days 1460 -outform PEM -out "server.crt" -sha256 -passin pass:$password

# Create the Client Key and CSR
openssl genrsa -des3 -passout pass:"$password" -out "client.key" 4096
openssl req -new -key "client.key" -out "client.csr" -passin pass:$password -subj "/C=$country/ST=$state/L=$locality/O=$organisation_crt/OU=$organisation_crt/CN=/emailAddress="

# Sign the client certificate with our CA cert
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key  -passin pass:$password -set_serial 01 -out client.crt

# Convert to .p12 to import in web navigator
openssl pkcs12 -export -clcerts -inkey client.key -passin pass:$password -in client.crt -out client.p12 -name "MyKey" -passout pass:$password

## Delete useless file
rm server.req
rm client.key
rm client.crt
rm client.csr
mkdir ./ca
mkdir ./server
mkdir ./client

mv ca.crt ./ca
mv ca.key ./ca

mv server.crt ./server
mv server.key ./server

mv client.p12 ./client

mkdir /etc/nginx/certs
mv ./server/* /etc/nginx/certs
mv ./ca/ca.crt /etc/nginx/certs
chgrp www-data /etc/nginx/certs/ -R
chmod 740 /etc/nginx/certs/*
chown $username ./client/client.p12


rm /etc/nginx/sites-enabled/default
rm /etc/nginx/nginx.conf

cp ./nginx.conf /etc/nginx/nginx.conf
chmod 644 /etc/nginx/nginx.conf


echo "Reload Nginx thx bye"

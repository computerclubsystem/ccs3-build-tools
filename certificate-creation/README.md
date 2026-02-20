# ComputerClubSystem certificate creation

## Build the image
The image `computerclubsystem/create-certs` is already published to Docker Hub but if you need to build it locally, navigate to the folder where the files `create-ca.sh`, `create-cert.sh`, `openssl.cnf` and `Dockerfile` are and execute:
```bash
docker buildx build -t computerclubsystem/create-certs .
```

## Prepare local folder for certificate files
Create a folder where the certificate files will be created and provide it as volume ("d:\dev\computerclubsystem\sample-certs" in the samples below):

## Create CA certificate
Use the sample below to create CA certificate which will be used later to sign client certificates. Provide strong password instead of `password-ca`. Also change `YourTown` and `YourCompany` with the corresponding values:
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-ca "password-ca" "/C=BG/ST=YourTown/O=YourCompany/OU=CCS3/CN=CCS3-CA" "DNS:ccs3-ca"
```
This will create files named `ca.crt` and `ca.key` in the specified folder.

## Create client certificate for the client computer
Use the sample below to create client certificate used by the client computer to connect to the server. Change `PC20` with the real name of the computer and `password-PC20` with strong password for the certificate for PC20 computer, `password-ca` must be changed with the password of the CA certificate created above. Also change `YourTown` and `YourCompany` with the corresponding values:
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert PC20 client "password-PC20" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=PC20" "DNS:PC20"
```

Certificate file with name `PC20.pfx` will be created - install it on the PC20 computer in "Local Machine" - "Personal".

## Create server certificate for the client computer
Use the sample below to create server certificate used by the client computer to accept connections from the client app. Change `PC20` with the real name of the computer and `password-PC20` with strong password for the certificate for PC20 computer, `password-ca` must be changed with the password of the CA certificate created above. Also change `YourTown` and `YourCompany` with the corresponding values, do not change `localhost`:
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert PC20.localhost server "password-PC20" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=localhost" "DNS:localhost"
```

Certificate file with name `PC20.localhost.pfx` will be created - install this on the PC20 computer in "Local Machine" - "Personal".

Repeat `Create client certificate for the client computer` and `Create server certificate for client computer` for all client computers.

## Create certificates for system services
These certificates should be provided to Kubernetes as secrets for the services to use them. You can change `DNS:servername` with the name of the server computer, where the system is running. `password-ca` must be changed with the password of the CA certificate created above.
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert operator-connector server "password-operator-connector" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=operator-connector" "DNS:servername"
```
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert pc-connector server "password-pc-connector" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=pc-connector" "DNS:servername"
```
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert qrcode-signin server "password-qrcode-signin" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=qrcode-signin" "DNS:servername"
```
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert static-files-service server "password-static-files-service" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=static-files-service" "DNS:servername"
```
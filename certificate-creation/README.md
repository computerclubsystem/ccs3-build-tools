# ComputerClubSystem certificate creation

## The image computerclubsystem/create-certs is already published to Docker Hub but if you need to build the image, navigate to the folder with create-ca.sh, create-cert.sh, openssl.cnf and Dockerfile and execute
```bash
docker buildx build -t computerclubsystem/create-certs .
```

## Create a folder where the certificate files will be created and provide it as volume ("d:\dev\computerclubsystem\sample-certs" in the samples below):

## Create CA certificate and provide strong password (this sample uses "password-ca"):
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-ca "password-ca" "/C=BG/ST=YourTown/O=YourCompany/OU=CCS3/CN=CCS3-CA" "DNS:ccs3-ca"
```
This will create files named `ca.crt` and `ca.key` in the specified folder in the volume.


## Create client certificate for the client computer - change "PC20" with the real name of the computer and "password-PC20" with the password for the certificate for PC20 computer, "password-ca" must be changed with the password of the CA certificate created above:
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert PC20 client "password-PC20" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=PC20" "DNS:PC20"
```

Certificate file with name `PC20.pfx` will be created - install this on the PC20 computer in "Local Machine" - "Personal"


## Create server certificate for the client computer - change "PC20" with the real name of the computer and "password-PC20" with the password for the certificate for PC20 computer, "password-ca" must be changed with the password of the CA certificate created above:
```bash
docker run --rm -it -v "d:\dev\computerclubsystem\sample-certs:/pki" computerclubsystem/create-certs create-cert PC20.localhost server "password-PC20" "password-ca" "/C=bg/ST=YourTown/O=YourCompany/CN=localhost" "DNS:localhost"
```

Certificate file with name `PC20.localhost.pfx` will be created - install this on the PC20 computer in "Local Machine" - "Personal"

Repeat `Create client certificate for the client computer` and `Create server certificate for client computer` for all client computers.

## Create certificates for system services
You can change `DNS:servername` with the name of the server computer, where the system is running.
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
#!/bin/bash -e

echo "Setting credentials to $USERNAME:$PASSWORD"
PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $PASSWORD)
echo "User exists? "`id -u $USERNAME`
id -u $USERNAME &>/dev/null || useradd --shell /bin/sh --create-home --password $PASSWORD $USERNAME
chown -R $USERNAME:$USERNAME /ftpdata
echo "chown -R $USERNAME:$USERNAME /ftpdata done."

mkdir /etc/proftpd/ssl
cd /etc/proftpd/ssl
openssl req -new -newkey rsa:4096 -days 9365 -nodes -x509 -subj "/C=CA/ST=QC/L=$CSR_CITY/O=Dis/CN=$PR_MASQ_HOST" -in $PR_MASQ_HOST.csr -keyout $PR_MASQ_HOST.key -out $PR_MASQ_HOST.cert

cat > /etc/proftpd/proftpd.conf << EOF
ServerName "tech-cl ftp server"
DefaultRoot /ftpdata
User root
PassivePorts $PR_PASSIVE_PORTS
MasqueradeAddress $PR_MASQ_HOST
RootLogin off
ServerIdent  Off
IdentLookups off
<Anonymous ~ftp>
RequireValidShell off
MaxClients 10
<Directory *>
<Limit READ>
DenyAll
</Limit>
<Limit WRITE>
DenyAll
</Limit>
</Directory>
</Anonymous>
Include /etc/proftpd/tls.conf
EOF

cat > /etc/proftpd/tls.conf << EOF
<IfModule mod_dso.c>
# If mod_tls was built as a shared/DSO module, load it
LoadModule mod_tls.c
</IfModule>
<IfModule mod_tls.c>
TLSEngine                  on
TLSLog                     /var/log/proftpd/tls.log
TLSProtocol TLSv1.2
TLSCipherSuite AES128+EECDH:AES128+EDH
TLSOptions                 NoCertRequest AllowClientRenegotiations
TLSRSACertificateFile      /etc/proftpd/ssl/$PR_MASQ_HOST.cert
TLSRSACertificateKeyFile   /etc/proftpd/ssl/$PR_MASQ_HOST.key
TLSVerifyClient            off
TLSRequired                on
RequireValidShell          no
</IfModule>
EOF

chown root:root /etc/proftpd/*.conf
echo "chown root:root /etc/proftpd/*.conf done."
echo "starting service..."
proftpd --nodaemon

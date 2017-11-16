#!/bin/bash -e

echo "Setting credentials to $USERNAME:$PASSWORD"
PASSWORD=$(perl -e 'print crypt($ARGV[0], "password")' $PASSWORD)
id -u $USERNAME &>/dev/null || useradd --shell /bin/sh --create-home --password $PASSWORD $USERNAME
chown -R $USERNAME:$USERNAME /ftpdata

cat > /etc/proftpd/proftpd.conf << EOF
ServerName "tech-cl ftp server"
DefaultRoot /ftpdata
User root
PassivePorts $PR_PASSIVE_PORTS
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
EOF
chown root:root /etc/proftpd/proftpd.conf

proftpd --nodaemon

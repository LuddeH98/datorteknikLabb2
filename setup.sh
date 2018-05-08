#!/bin/bash

user=pi
host=''
ip=$1
sshDir='.ssh/'
idFile=''
if [[ $1 == '' || ($2 != 'NEW' && $2 != 'OLD') ]]; then
	echo "Usage: $0 IP [NEW|OLD]"
	exit 1
fi
	echo '[+] Getting remote host name'
	host=$(ssh $user@$ip 'hostname')
	idFile=$sshDir$host"_rsa"

if [[ $2 == 'NEW' ]]; then
	echo "[+] Generating SSH keys..."
	ssh $user@$ip "mkdir $sshDir 2> /dev/null; ssh-keygen -t rsa -b 4096 -N '' -f $idFile"
	ssh $user@$ip "cat $idFile.pub >> "$sshDir"authorized_keys"
fi

echo "[+] Copying SSH keys to local machine..."
scp $user@$ip:$idFile ~/$idFile

if [[ $? == 0 ]]; then
echo "[+] Adding info to SSH configuration"
	cd ~/.ssh
	echo "Host $host" >> config
	echo "HostName $ip" >> config
	echo "User $user" >> config
	echo 'IdentityFile ~/'$idFile >> config
else
	echo '[-] Failed to fetch SSH key'
fi

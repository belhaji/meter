#!/bin/bash

# creating the email group
groupadd email

# add all users into the group
for u in $(awk -F: '/\/home/ && ($3 >= 1000) {printf "%s ",$1}' /etc/passwd); do
	useradd -G email $u
done

# install the app in /opt
mkdir /opt/msger
cp * /opt/msger
cp /opt/msger/email /bin
chmod +x /bin/email && chmod +x /opt/msger/email.sh

# setup sudo permission
echo "%email	ALL=(ALL:ALL) NOPASSWD:SETENV:   /opt/msger/email.sh" >> /etc/sudoers

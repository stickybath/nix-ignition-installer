#!/usr/bin/env bash

#
# ignition-setup.sh
# Keith Miller
# 09APR2019
#
# 1.0 - initial release
#

#ensure root user is being used
if [ $EUID -ne 0 ]; then
	echo "This script must be run as root."
	exit 1
fi

#set variables
ignitionUrl='http://159.203.117.161/ignition-installer.run'

#configure firewall
printf "Installing firewall rules:\n"
firewall-cmd --zone=public --permanent --add-port=8088/tcp
firewall-cmd --zone=public --permanent --add-port=8043/tcp
firewall-cmd --zone=public --permanent --add-port=5432/tcp

#disable SELinux
printf "checking if SELinux is disabled..."
cmd="$(getenforce)"
if [ "$cmd" -eq "Enforcing" ]; then
    printf " [failed]\n"
    printf "SELinux shall be disabled and the server shall be rebooted.\n"
    printf "re-run this script after reboot completes.\n"
    sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
    read -p "Press [Enter] to continue."
    reboot
fi
printf " [passed]\n"

#install JRE
printf "Installing OpenJDK 7 JRE (version 1.8.0):\n"
yum install -y java-1.8.0-openjdk

#install ignition
printf "Downloading Ignition installer:\n"
cmd="$(curl -o ignition-installer.run ${ignitionUrl})"
echo $cmd
printf "Running Ignition installer\n:"
chmod +x ./ignition-installer.run
./ignition-installer.run --mode unattended --prefix /usr/local/bin/ignition --serviceuser ignition --unattendedmodeui none
chown -R ignition:ignition /usr/local/bin/ignition
/etc/init.d/ignition installstart

#install PostgreSQL
printf "Installing PostgreSQL:\n"
install -y postgresql-server
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql

#configure PostgreSQL
sudo passwd postgres
printf "Enter postgres database user password: "
read -s password
sudo su - postgres -c "psql -d template1 -c \"ALTER USER postgres WITH PASSWORD '$password';\""
sudo su - postgres -c "psql -c \"CREATE DATABASE ignition OWNER postgres\""

#prompt user to show ip address:
printf "Using a web browser navigate to the ip address shown below with port 8088. "
printf "(e.g. \"http://OCT0.OCT1.OCT2.OCT3:8088\"):\n"
ip addr show | grep -v "inet6" | grep -v "127.0.0.1" | grep --color=never inet 


#https://support.plesk.com/hc/en-us/articles/115003321434-How-to-enable-remote-access-to-PostgreSQL-server-
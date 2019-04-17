# nix-ignition-installer
Ignition by Inductive Automation installer for Linux. At the moment, this script only supports distros utilizing the Yum package manager and has only been tested on CentOS.

## Using the Script
The following shell commands, executed on a distro utilizing the Yum package manager, will grab and execute the script. Due to the nature of Ignition's installer binary it must be run as root (and therefore so must this script). The following bash commands assume that you are already logged in as root.

```
# install git
yum install -y git

# clone this repository
git clone https://github.com/stickybath/nix-ignition-installer.git

# allow the script to be executed
chmod +x ./nix-ignition-installer/nix-ignition-installer.sh

# execute the script
./nix-ignition-installer/nix-ignition-installer.sh
```

If SELinux is enabled on your system this script will disable it and reboot (this will be the case until I finish the SELinux module I am working on for Ignition). If this happens simply run the script again after booting to complete the installation process:

```
# execute the script again
sudo ./nix-ignition-installer/nix-ignition-installer.sh
```

## Todo
This script is still a work in progress. At the time of writing there is a bug with the Postgres database security configuration which needs to be addressed, and the SELinux module still isn't complete. The next release of this script will have the Postgres issue resolved, and the release following that will address the SELinux module.

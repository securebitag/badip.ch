#!/bin/bash
#--------------------------------------------------------------------#
# Copyright 2018 by Kevin Buehl <kevin.buehl@securebit.cloud>        #
#--------------------------------------------------------------------#
#     _____                          _     _ _              _____    #
#    / ____|                        | |   (_) |       /\   / ____|   #
#   | (___   ___  ___ _   _ _ __ ___| |__  _| |_     /  \ | |  __    #
#    \___ \ / _ \/ __| | | | '__/ _ \ '_ \| | __|   / /\ \| | |_ |   #
#    ____) |  __/ (__| |_| | | |  __/ |_) | | |_   / ____ \ |__| |   #
#   |_____/ \___|\___|\__,_|_|  \___|_.__/|_|\__| /_/    \_\_____|   #
#                                                                    #
# No part of this script or any of its contents may be reproduced,   #
# copied, modified or adapted, without the prior written consent of  #
# the author, unless otherwise indicated for stand-alone materials.  #
# For more Information visit www.securebit.cloud.                    #
# This notice must remain untouched at any time.                     #
#--------------------------------------------------------------------#

# check if running on supported os
if ! [ -f "/etc/debian_version" ]; then
   echo "Only Debian/Ubuntu are supported. Please be patient or install it manually."
   exit 1
fi
# check if script run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# first of all we take a look for system update
apt-get -qq update && apt-get -qq upgrade

# check if cron is installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' cron|grep "install ok installed")
echo Checking for cron: $PKG_OK
if [ "" == "$PKG_OK" ]; then
   echo "No cron installed. Installing cron."
   apt-get -qq install cron
fi
# check if fail2ban is installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' fail2ban|grep "install ok installed")
echo Checking for Fail2Ban: $PKG_OK
if [ "" == "$PKG_OK" ]; then
   echo "No Fail2Ban installed. Installing Fail2Ban."
   apt-get -qq install fail2ban
fi

# create black.list 
if [ -f "/etc/fail2ban/black.list" ]; then
   echo "black.list already exist."
else
   touch /etc/fail2ban/black.list
   echo "Blacklist file created."
fi

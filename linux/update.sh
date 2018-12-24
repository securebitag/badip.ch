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
DSTDIR="/opt/badip"

# check if apikey file exist
if ! [ -f "${DSTDIR}/api.key" ]; then
   echo "Please use our install script." 1>&2
   exit 1
else
   APIKEY=$(cat ${DSTDIR}/api.key)
fi
# check if script run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
# check if fail2ban installed
if [ ! -d "/etc/fail2ban/" ]; then
   echo "please install fail2ban"
   exit 1
elif [ ! -e "/etc/fail2ban/ip.blacklist" ]; then
   touch /etc/fail2ban/ip.blacklist
fi
# check if apikey not empty
if [ -z "$APIKEY" ]; then
   echo "Please enter your APIKEY in file /opt/4b42/api.key"
fi
# files
IPS=$(cat /etc/fail2ban/black.list)
status=`wget --header="APIKEY:${APIKEY}" --post-data="ips=$IPS" -O /tmp/black.list https://api.badip.ch/all.txt --no-check-certificate 2>&1|awk '/^  HTTP/{print $2}'
if [ "$status" == 200 ]; then
   rm -f /etc/fail2ban/black.list
   mv /tmp/black.list /etc/fail2ban/black.list
elif [ -e "/tmp/black.list" ]; then
   echo $(cat /tmp/black.list);
fi
# reload fail2ban service
service fail2ban reload

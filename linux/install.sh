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
# create badip.list 
if [ -f "/etc/fail2ban/badip.list" ]; then
   echo "badip.list already exist."
else
   touch /etc/fail2ban/badip.list
   echo "BadIP.list file created."
fi

# get modified iptables-multiport.conf
wget -O /tmp/iptables-multiport.conf https://raw.githubusercontent.com/securebitag/badip.ch/master/linux/fail2ban/action.d/iptables-multiport.conf --no-check-certificate
if [ -f "/tmp/iptables-multiport.conf" ]; then
   diff /etc/fail2ban/action.d/iptables-multiport.conf /tmp/iptables-multiport.conf > /dev/null 2>&1
   if [ "$?" -eq 0 ]; then
      rm -f /tmp/iptables-multiport.conf
      echo "No modification on iptables-multiport.conf needed."
   else
      if [ -f "/etc/fail2ban/action.d/iptables-multiport.conf" ]; then
         mv /etc/fail2ban/action.d/iptables-multiport.conf /etc/fail2ban/action.d/iptables-multiport.conf.bak
         mv /tmp/iptables-multiport.conf /etc/fail2ban/action.d/iptables-multiport.conf
         echo "Got modified iptables-multiport.conf"
      else
         mv /tmp/iptables-multiport.conf /etc/fail2ban/action.d/iptables-multiport.conf
         echo "iptables-multiport.conf installed."
      fi
   fi
else
   echo "Failure getting modified iptables-multiport.conf. Please contact Securebit support."
   exit
fi

# get update.sh
if ! [ -d ${DSTDIR} ]; then
   mkdir -p ${DSTDIR}
fi
wget -O /tmp/update.sh https://raw.githubusercontent.com/securebitag/badip.ch/master/linux/update.sh --no-check-certificate
if [ -f "/tmp/update.sh" ]; then
   diff ${DSTDIR}/update.sh /tmp/update.sh > /dev/null 2>&1
   if [ "$?" -eq 0 ]; then
      rm -f /tmp/update.sh
      echo "No new version of update.sh available."
   else
      if [ -f "${DSTDIR}/update.sh" ]; then
         mv ${DSTDIR}/update.sh ${DSTDIR}/update.sh.bak
         mv /tmp/update.sh ${DSTDIR}/update.sh
         chmod +x ${DSTDIR}/update.sh
         echo "New Version was downloaded. Old one are backed up."
      else
         read -p "Please insert your API-Key." APIKEY
         echo $APIKEY > ${DSTDIR}/api.key
         chmod 700 ${DSTDIR}/api.key
         mv /tmp/update.sh ${DSTDIR}/update.sh
         chmod +x ${DSTDIR}/update.sh
         echo "update.sh downloaded."
      fi
   fi
else
   echo "Failure getting update.sh. Please contact Securebit support."
   exit
fi

# create crontab
if [ -f "${DSTDIR}/badip_cron" ]; then
   echo "Crontab already exist. Let's do a fail2ban reload."
   ${DSTDIR}/update.sh
else
   crontab -l > ${DSTDIR}/badip_cron
   echo "0 0 * * * ${DSTDIR}/update.sh" >> ${DSTDIR}/badip_cron
   crontab ${DSTDIR}/badip_cron
   echo "Crontab created to run every day 12AM. Please use 'crontab -e' to modify."
   ${DSTDIR}/update.sh
fi
exit

#--------------------------------------------------------------------#
# Copyright 2018-2019 by Kevin Buehl <kevin.buehl@securebit.cloud>   #
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
/system scheduler
remove [find name=BadipImport]
/system script
remove [find name=BadipImport]
add dont-require-permissions=no name=BadipImport owner=admin policy=\
    read,write,test source="# download current blacklist\r\
    \n/tool fetch check-certificate=no dst-path=\"blacklist.rsc\" mode=https u\
    rl=https://api.badip.ch/ipv4.rsc\r\
    \n# import blacklist filter script\r\
    \n/import blacklist.rsc\r\
    \n# remove blacklist filter script\r\
    \n/file remove blacklist.rsc"
/system scheduler
add interval=1d name=BadipImport on-event=BadipImport policy=read,write,test \
    start-date=jan/01/2019 start-time=02:00:00

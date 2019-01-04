# IP-Addresss Blacklist Service - badip.ch
Secure your infrastructure today against targeted and automated attacks and potential security holes!

# Reporting
## Fail2Ban
Fail2ban is the easiest way to report ip addresses of attackers attacking your Linux systems.
The installation is very simple:
```
wget --no-check-certificate https://raw.githubusercontent.com/securebitag/badip.ch/master/linux/install.sh -O /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh
```
## Manual
If needed you can create own scripts to parse logfiles and report bad ip-addresses:
```
curl -X POST -H 'APIKEY:<YOUR-API-KEY>' -d 'ip=10.10.10.10' https://api.badip.ch/ipv4.txt
```

# Using
## MikroTik
Create firewall filter at the top, to block ip addresses in address-list badip:
```
/ip firewall filter
add action=drop chain=input src-address-list=badip
add action=drop chain=forward src-address-list=badip
add action=drop chain=forward dst-address-list=badip
add action=drop chain=output dst-address-list=badip
```

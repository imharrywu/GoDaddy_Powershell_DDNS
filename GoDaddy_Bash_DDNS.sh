#!/bin/bash

# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server(OTE) and one for the production server(Production)
# Get a key and secret for the production server
#
#Update the first 4 variables with your information

domain="your.domain.to.update"   # your domain
name="name_of_host"     # name of A record to update, e.g. `@'
key="key"     # key for godaddy developer API
secret="secret"   # secret for godaddy developer API

headers="Authorization: sso-key $key:$secret"

# echo $headers

result=$(curl -s -X GET -H "$headers" \
 "https://api.godaddy.com/v1/domains/$domain/records/A/$name")

dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
# echo "dnsIp:" $dnsIp

# Get public ip address there are several websites that can do this.
#ret=$(curl -s GET "https://ipinfo.io/json")
#ret=$(curl -s GET "https://myip.ipip.net/json")
ret=$(curl -s -X GET 'http://myip.ipip.net/json' \
      -H 'Connection: keep-alive' \
      -H 'Cache-Control: max-age=0' \
      -H 'Upgrade-Insecure-Requests: 1' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36' \
      -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
      -H 'Accept-Encoding: gzip, deflate' \
      -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' \
      --compressed --insecure)
currentIp=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
# echo "currentIp:" $currentIp

if [ x"$dnsIp" = x"$currentIp" ];
#      echo "Ips are equal"
then
#       echo "Ips are not equal"
        request='[{"data":"'$currentIp'","ttl":3600}]'
#       echo $request
        nresult=$(curl -i -s -X PUT \
            -H "$headers" \
            -H "Content-Type: application/json" \
            -d $request "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
#       echo $nresult
fi

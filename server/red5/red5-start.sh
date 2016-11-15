#!/bin/sh
# configuration REST API access
echo "CONFIGURING REST API"

# allow all
printf "\n*\n" >> red5/webapps/api/WEB-INF/security/hosts.txt

# extra security to add specific IPs
# TODO: pass in a list of IPs as a docker argument
#echo "172.17.0.4" >> red5/webapps/api/WEB-INF/security/hosts.txt
#echo "192.168.1.125" >> red5/webapps/api/WEB-INF/security/hosts.txt
if [ -n $REST_API_ACCESS_TOKEN ]; then
  perl -pi -e "s/security.accessToken=.*/security.accessToken=$REST_API_ACCESS_TOKEN/" red5/webapps/api/WEB-INF/red5-web.properties
else
  echo "MISSING ACCESS TOKEN: not setting up rest api"
fi
# start red5
cd red5
./red5.sh

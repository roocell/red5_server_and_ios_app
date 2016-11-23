#------------------------------------------------------
# APNS
# in order to use APNS we need to keep track of a user and their push device token
# so now this will introduce a user table in our mysql database
#
# the following is the process of creating certs to
#------------------------------------------------------
# certificate generation
http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1


# generate CSR (dont need a new one everytime)
# open "Keychain Access" app


1. goto developer.apple.com, member centre, certificates
2. select "Apple Push Notification service SSL Cert (Sandox & Production)
3. select teleport appID
4. upload CSR (from rayw's URL above)
5. download the .cer file (save as teleport.ces)

# install the cer file into the keychain on the mac.
# select the certificate right click and export as p12.  

#now we create the PEM file
openssl pkcs12 -in teleport.p12 -out teleport.pem -nodes -clcerts
openssl pkcs12 -in teleport_production.p12 -out teleport_production.pem -nodes -clcerts

# to test
openssl s_client -connect gateway.push.apple.com:2195 -cert teleport.pem -key teleport.pem
openssl s_client -connect gateway.push.apple.com:2195 -cert teleport_production.pem -key teleport_production.pem


# copy the teleport.pem file into the APNS  directory on the web server

# can also use PHP
docker exec -i -t myphp bash
php apns/push.php

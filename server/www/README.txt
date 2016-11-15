# WEB server
# create a www directory, download phpmyadmin
curl https://files.phpmyadmin.net/phpMyAdmin/4.6.4/phpMyAdmin-4.6.4-english.tar.gz -o phpMyAdmin-4.6.4-english.tar.gz

# untar phpmyadmin into www, mv config.inc.php and adjust params (blowfish)

# update phpmyadmin config with mysql container ip
sed -i .bak "s/.*Servers.*'host'.*/\$cfg['Servers'][\$i]['host'] = '$(docker inspect --format='{{.NetworkSettings.IPAddress}}' mysql):3306';/" ~/teleport/www/phpmyadmin/config.inc.php


# create a volume container (with the web files present on the host - for dev purposes)
docker create -v ~/teleport/www:/var/www/html/ --name www roocell/phpapache /bin/true


# start the web server container
# using roocell/phpapache because it has some special osx permissions script in it.
docker run --volumes-from www -d -p 11111:80 -p 11112:443 -it --link mysql:mysql \
-v ~/teleport/config/php.ini:/usr/local/etc/php/php.ini \
 --name myphp roocell/phpapache


# run phpapache, passing in variable for red5 container
docker run --volumes-from www -d -p 11111:80 -p 11112:443 \
-e RED5IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' myred5) \
-v ~/teleport/config/php.ini:/usr/local/etc/php/php.ini \
-it --link mysql:mysql --name myphp roocell/phpapache

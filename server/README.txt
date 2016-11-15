There is an order the docker containers need to run because each depends on variables from the other

1. mysql
2. red5
3. phpapache


# restart script
docker-machine start default
docker rm -f mysql
docker rm -f myphp
docker rm -f myred5

docker run  -p 3900:3306 --name mysql -e MYSQL_ROOT_PASSWORD=admin123 -v ~/teleport/server/mysql/datadir:/var/lib/mysql -d osx_localdb_mysql
sed -i .bak "s/.*Servers.*'host'.*/\$cfg['Servers'][\$i]['host'] = '$(docker inspect --format='{{.NetworkSettings.IPAddress}}' mysql):3306';/" ~/teleport/server/www/phpmyadmin/config.inc.php
docker create -v ~/teleport/server/www:/var/www/html/ --name www roocell/phpapache /bin/true
docker run --volumes-from www -d -p 11111:80 -p 11112:443 -e RED5IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' myred5) -v ~/teleport/server/config/php.ini:/usr/local/etc/php/php.ini -it --link mysql:mysql --name myphp roocell/phpapache

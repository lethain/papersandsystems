run:
	env GH_BASIC_CLIENT_ID=0a1856ce59bb1af7c9df \
	    GH_BASIC_SECRET_ID=6da60f8f00e29e9fd2c9c713df981f64cd648f7a \
	    MYSQL_HOST=localhost \
	    MYSQL_USER=root \
	    MYSQL_PASS= \
	    MYSQL_DB=papers \
	    MEMCACHE_HOSTS=127.0.0.1:11211 \
	    DOMAIN=http://localhost:9292 \
	bundle exec rackup

prod:
	env GH_BASIC_CLIENT_ID=c76ce9793829d5c6205a \
	    GH_BASIC_SECRET_ID=ea2ca8f0bc3846764a185a544779483d1b719a95 \
	    MYSQL_HOST=localhost \
	    MYSQL_USER=root \
	    MYSQL_PASS= \
	    MYSQL_DB=papers \
	    MEMCACHE_HOSTS=127.0.0.1:11211 \
	    DOMAIN=https://systemsandpapers.com \
	bundle exec rackup

mysql:
	mysql.server start

memcached:
	/usr/local/opt/memcached/bin/memcached

mongo:
	mongod --config /usr/local/etc/mongod.conf

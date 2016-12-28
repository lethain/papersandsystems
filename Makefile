run:
	env GH_BASIC_CLIENT_ID=0a1856ce59bb1af7c9df GH_BASIC_SECRET_ID=6da60f8f00e29e9fd2c9c713df981f64cd648f7a bundle exec rackup

mongo:
	mongod --config /usr/local/etc/mongod.conf

user www-data;
pid /run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 409600;

events {
	worker_connections 4096;
	multi_accept on;
}

http {
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	server_tokens off;
	log_not_found off;
	types_hash_max_size 2048;
	client_max_body_size 16M;

	# MIME
	include mime.types;
	default_type application/octet-stream;

	# logging
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log warn;

	# load configs
	include /etc/nginx/conf.d/*-http.conf;
}

stream {
  include /etc/nginx/conf.d/*-stream.conf;
}
upstream influxdb {
	server influxdb.docker:8086;
}

server {
	listen 25255 udp;
	listen [::]:25255 udp;
  proxy_pass influxdb;
	proxy_responses 0;
	# proxy_redirect default;
	# proxy_set_header Host $host;
	# proxy_set_header X-Real-IP $remote_addr;
	# proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
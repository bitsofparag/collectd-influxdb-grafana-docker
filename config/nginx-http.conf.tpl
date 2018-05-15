#log formats
log_format grafana '$time_iso8601 $remote_addr - $remote_user
$proxy_host$request$cookie_grafanasess "$request" $status $body_bytes_sent
$request_time' ;
log_format influx '$time_iso8601 $remote_addr - $remote_user
"$scheme://$server_name/$uri" $status $body_bytes_sent $request_time' ;
log_format cloud '$time_iso8601 cloud:$remote_addr - $remote_user
"$scheme://$server_name/$uri" $status $body_bytes_sent $request_time' ;

upstream grafana {
	server grafana.docker:3000;
	keepalive 15;
}

upstream influx {
	server influxdb.docker:8083;
	keepalive 10;
}

upstream cloud_backend {
  server 10.0.1.137:8000;
}

server {
	listen 80;
	listen [::]:80;
	server_name $hostname *.docker;

  location /api/monitoring/ {
    proxy_pass http://cloud_backend/api/monitoring/;
    proxy_redirect default;
    proxy_set_header Host $host;
	  proxy_set_header X-Real-IP $remote_addr;
	  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Authorization "Basic YWRtaW46dGVzdDEyMzQ=";
    access_log /var/log/nginx/ops-access.log cloud buffer=1024 flush=5m;
  }

  location /influx/ {
    proxy_pass http://influx/;
    proxy_redirect default;
    proxy_set_header Host $host;
	  proxy_set_header X-Real-IP $remote_addr;
	  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    access_log /var/log/nginx/ops-access.log influx buffer=1024 flush=5m;
  }

  location /grafana/ {
    proxy_pass http://grafana/;
    proxy_redirect default;
    proxy_set_header Host $host;
	  proxy_set_header X-Real-IP $remote_addr;
	  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    access_log /var/log/nginx/ops-access.log grafana buffer=1024 flush=5m;
  }
}
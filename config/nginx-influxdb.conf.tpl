#log formats
log_format grafana '$time_iso8601 $remote_addr - $remote_user $proxy_host$request$cookie_grafanasess "$request" $status $body_bytes_sent $request_time' ;
log_format influx '$time_iso8601 $remote_addr - $remote_user "$scheme://$server_name/$uri" $status $body_bytes_sent $request_time' ;

map $http_referer $proxyloc {
		~*influx influx;
}

map $request_uri $backend {
		~*query influxdb;
		~*write influxdb;
		~*ping  influxdb;
}

upstream grafana {
		server grafana:3000;
		keepalive 15;
}

upstream influx {
		server influxdb:8083;
		keepalive 10;
}

upstream influxdb {
		server influxdb:8086;
		keepalive 10;
}

server {
    listen 8080;
    listen [::]:8080;

    server_name api.local

    location /  {
             access_log         /var/log/nginx/influx-access.log influx buffer=1024 flush=5m;
			       proxy_pass         http://influxdb/;
			       proxy_redirect     default;
			       proxy_set_header   Host  $host;
			       proxy_set_header   X-Real-IP  $remote_addr;
			       proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}

server {
    listen 80;
    listen [::]:80;

    server_name ops.local

    location /grafana/  {
             proxy_pass         http://grafana/;
             proxy_set_header   Host  $host;
			       proxy_set_header   X-Real-IP  $remote_addr;
			       proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
			       access_log         /var/log/nginx/grafana-access.log grafana buffer=1024 flush=5m;
			       proxy_redirect     default;
		}

    location /influx/ {
             access_log         /var/log/nginx/influx-access.log influx buffer=1024 flush=5m;
			       proxy_pass         http://influx/;
			       proxy_redirect     default;
			       proxy_set_header   Host  $host;
			       proxy_set_header   X-Real-IP	$remote_addr;
			       proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
			       proxy_set_header   Authorization "";
    }

    location /  {
			  if ($backend) {
				    return 302 /$backend/$request_uri;
			  }

			  if ($proxyloc) {
				    return 302 /$proxyloc/$uri;
			  }
			  return 302 /grafana/;
		}
}

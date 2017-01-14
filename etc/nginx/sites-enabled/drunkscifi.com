##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

server {
	listen 80;
	server_name *.drunkscifi.com;
	rewrite ^ https://drunkscifi.com$request_uri? redirect;
}

server {
	client_max_body_size 1G;
	# SSL configuration
	#
	listen 443 ssl default_server;
	ssl_certificate /etc/letsencrypt/live/drunkscifi.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/drunkscifi.com/privkey.pem;

	ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

	ssl_prefer_server_ciphers on;

	ssl_protocols TLSv1.2;
	
	root /var/www/drunkscifi.com;
	index index.php;

        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
        ssl_session_cache shared:SSL:10m;
   	
	location / {
        	try_files $uri $uri/ /index.php?$args;
    	}

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

    	location ~ \.php$ {
		fastcgi_split_path_info ^(.+?\.php)(/.*)$;
		if (!-f $document_root$fastcgi_script_name) {
		        return 404;
    		}

		# Mitigate https://httpoxy.org/ vulnerabilities
 		fastcgi_param HTTP_PROXY "";
		fastcgi_intercept_errors on;
		fastcgi_pass unix:/var/run/php/php7.0-fpm.sock; 
		include fastcgi.conf;
    	}

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}

 echo -n 'CREATE DATABASE [DBNAME] DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;' | mysql
 echo -n "GRANT ALL ON [DBNAME].* TO '[USERNAME]'@'localhost' IDENTIFIED BY '[PASSWORD]';" | mysql
 sudo apt install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
 sudo systemctl restart php7.2-fpm
 curl -LO https://wordpress.org/latest.tar.gz
 tar xzvf latest.tar.gz
 cp wordpress/wp-config-sample.php wp-config.php
 cp -a wordpress/. /var/www/wordpress
 sudo chown -R www-data:www-data /var/www/wordpress
 curl -s https://api.wordpress.org/secret-key/1.1/salt/ > gen_keys.txt
 cat gen_keys.txt >> wp-config.php
 [open wp-config, move generate keys to correct location, overwrite old keys, update DB_ADMIN/DB_PASSWORD/DB_NAME, replace ^M with nothing]
 echo -n "define('FS_METHOD', 'direct');" >> wp-config.php
 [make sure wp-config.php is in /var/www/wordpress]
 rename var wordpress, something like:
 [mv wordpress/ drunkscifi.com] in /var/www
 chown www-data:www-data wp-config.php
 So I got an error like so:
 "connect() to unix:/var/run/php/php7.0-fpm.sock failed (2: No such file or directory)"
 Because I needed to update this line:
 fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
 In my wordpress sites-available (nginx conf) from 7.0 to 7.2 (updated in saved config, but may need updating next time around)
 DB connection isssues.. had to login to mysql and explicitly flush privileges, and mess around for a bit trying to log in on command, FIK
 After that, all good... Just had to set titles, edit first post, etc.
 
 I also updated the do agent, because, reasons:
 curl -sSL https://insights.nyc3.cdn.digitaloceanspaces.com/install.sh | sudo bash

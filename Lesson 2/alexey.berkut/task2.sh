#!/bin/bash
if [[ "$EUID" -ne 0 ]] # EUID 0 - root for the current process
then
	echo "Please run as root";
	exit 0;
fi

# Install Nginx
apt update && apt install -y curl gnupg2 ca-certificates lsb-release;
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
	| tee /etc/apt/sources.list.d/nginx.list    
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-key fingerprint ABF5BD827BD9BF62
apt update && apt install -y nginx=1.14.2-1~bionic
nginx -v # Show version
# Install Nginx. End

echo -e "\033[31;1m";
nginx -t # Test nginx
echo -e "\033[0m";

num=`cat /etc/nginx/nginx.conf | awk '/./{line=$0} END{print NR}'`; # Get the last no-empty line number
cd /etc/nginx/ && mv nginx.conf defaultNginx.conf && sed "$num i\    include /etc/nginx/sites-enabled/\*.conf;" defaultNginx.conf > nginx.conf && mkdir sites-available/ sites-enabled/;
	# Create backup nginx.conf (defaultNginx.conf)
	# Create nginx.conf with included folder sites-enabled
	# Create folders sites-available & sites-enabled

mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/;
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/;

# systemctl restart nginx.service;
service nginx restart;

curl -X GET 127.0.0.1 | grep -o "Welcome to nginx!" | head -1;

exit 0;
#!/bin/bash
################################################################################
# Script for installing Nginx and Certbot on Ubuntu 16.04, 18.04 and 20.04 (could be used for other version too)
# Author: Sumit Khanna
#-------------------------------------------------------------------------------
# This script will install Docker compose on your Ubuntu server.
#-------------------------------------------------------------------------------
# Make a new file:
# sudo nano certbot_install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x certbot_install.sh
# Execute the script to install docker:
# ./certbot_install
################################################################################

# VARIABLES
INSTALL_NGINX="y"
ENABLE_SSL="y"
ADMIN_EMAIL="test@example.com"
WEBSITE_NAME="_"
OE_PORT="80"

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
# universe package is for Ubuntu 18.x
sudo add-apt-repository universe
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install Nginx if needed
#--------------------------------------------------
echo -e "Do you want to install nginx (y/n)"
read INSTALL_NGINX
echo "Please enter website name"
read WEBSITE_NAME

if [[ $INSTALL_NGINX == [yY] ]] && [[ $WEBSITE_NAME != "_" ]]; then
  echo -e "\n---- Installing Nginx ----"
  INSTALL_NGINX="y"
  sudo apt install nginx -y
else
  echo -e  "Nginx isn't installed due to choice of the user or because of a misconfiguration!"
fi

if [[ $INSTALL_NGINX == [yY] ]]; then
    echo -e "\n---- Please Enter Port ----"
    read OE_PORT
    echo -e "\n---- Setting up Nginx ----"
    cat <<EOF > ~/odoo
server {
  listen 80;

  # set proper server name after domain set
  server_name $WEBSITE_NAME;

  #   odoo    log files
  access_log  /var/log/nginx/access.log;
  error_log       /var/log/nginx/error.log;

  #   increase    proxy   buffer  size
  proxy_buffers   16  64k;
  proxy_buffer_size   128k;

  proxy_read_timeout 900s;
  proxy_connect_timeout 900s;
  proxy_send_timeout 900s;

  #   force   timeouts    if  the backend dies
  proxy_next_upstream error   timeout invalid_header  http_500    http_502
  http_503;

  #   enable  data    compression
  gzip    on;
  gzip_min_length 1100;
  gzip_buffers    4   32k;
  gzip_types  text/css text/less text/plain text/xml application/xml application/json application/javascript application/pdf image/jpeg image/png;
  gzip_vary   on;
  client_header_buffer_size 4k;
  large_client_header_buffers 4 64k;
  client_max_body_size 0;

  location / {
    proxy_pass    http://127.0.0.1:$OE_PORT;
    # by default, do not forward anything
    proxy_redirect off;
  }
}
EOF

  sudo mv ~/odoo /etc/nginx/sites-available/$WEBSITE_NAME
  sudo ln -s /etc/nginx/sites-available/$WEBSITE_NAME /etc/nginx/sites-enabled/$WEBSITE_NAME
  sudo rm /etc/nginx/sites-enabled/default
  sudo service nginx reload
  sudo su root -c "printf 'proxy_mode = True\n' >> /etc/${OE_CONFIG}.conf"
fi

#--------------------------------------------------
# Enable ssl with certbot
#--------------------------------------------------
echo "Do you want to Enable SSL (Default Yes): (y/n)"
read ENABLE_SSL
if [[ $ENABLE_SSL == [yY] ]];then
  echo "Please enter Email"
  read ADMIN_EMAIL
  if [ $ADMIN_EMAIL != "test@example.com" ] && [ $WEBSITE_NAME != "_" ]; then
      sudo add-apt-repository ppa:certbot/certbot -y && sudo apt-get update -y
      sudo apt-get install python3-certbot-nginx -y
      sudo certbot --nginx -d $WEBSITE_NAME --noninteractive --agree-tos --email $ADMIN_EMAIL --redirect
      sudo service nginx reload
      echo "SSL/HTTPS is enabled!"
  else
    echo "SSL/HTTPS isn't enabled due to invalid email or website name"
  fi
else
  echo "SSL/HTTPS isn't enabled due to choice of the user or because of a misconfiguration!"
fi


echo "-----------------------------------------------------------"
if [[ $INSTALL_NGINX == [yY] ]]; then
  echo "Done! The Nginx is up and running."
  echo "Start Nginx service: sudo service nginx start"
  echo "Stop Nginx service: sudo service nginx stop"
  echo "Restart Nginx service: sudo service nginx restart"
  echo "Check Nginx service status: sudo service nginx status"
fi
if [ $WEBSITE_NAME != "_" ]; then
  echo "Nginx configuration file: /etc/nginx/sites-available/$WEBSITE_NAME"
  echo "Check SSL Auto-renew: sudo certbot renew --dry-run"
fi
echo "-----------------------------------------------------------"

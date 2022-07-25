#!/usr/bin/env bash

#############################################################################
#Environment variable

export DOMAIN_NAME='example.com'
export DOMAIN_ALIAS_NAME='www.example.com'
export CERT_FILE=${DOMAIN_NAME//./_}

#############################################################################
################################
#install the required packages
################################

. pkg/installation
###########################################################################################
#################################
#apache server  configuration
#################################

# allow override none to all for /var/www
sudo sed -i -e '172 s/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

#configure X-frame-options
sudo echo -e "Header set X-Frame-Options: \"sameorigin\"" >> /etc/apache2/conf-available/security.conf

# write the protocol for http2 
sudo sed -i "4 i Protocols h2 http/1.1" /etc/apache2/sites-available/default-ssl.conf

# http to https redirect write at virtual host
sudo sed -i "4 i Redirect permanent / https://${DOMAIN_NAME}/" /etc/apache2/sites-available/000-default.conf

#ssl file create at location /var/www/sslkeys
sudo mkdir -p /var/www/sslkeys

touch /var/www/sslkeys/${DOMAIN_NAME}.csr /var/www/sslkeys/${DOMAIN_NAME}.key /var/www/sslkeys/${DOMAIN_NAME}.ca-bundle

#comment the default ssl file path line at default-ssl.conf
sudo sed -i -e '33 s/SSLCertificateFile/#SSLCertificateFile/g' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i -e '34 s/SSLCertificateKeyFile/#SSLCertificateKeyFile/g' /etc/apache2/sites-available/default-ssl.conf

#insert the ssl certificate , private key , ca-bundle 
sudo sed -i "35 i SSLCertificateFile /var/www/sslkeys/${CERT_FILE}.csr" /etc/apache2/sites-available/default-ssl.conf
sudo sed -i "36 i SSLCertificateKeyFile /var/www/sslkeys/${CERT_FILE}.key" /etc/apache2/sites-available/default-ssl.conf
sudo sed -i "37 i SSLCertificateChainFile /var/www/sslkeys/${CERT_FILE}.ca-bundle" /etc/apache2/sites-available/default-ssl.conf

#servername & server alias name 
sudo sed -i "2 i ServerName ${DOMAIN_NAME}" /etc/apache2/sites-available/000-default.conf
sudo sed -i "3 i ServerAlias ${DOMAIN_ALIAS_NAME}" /etc/apache2/sites-available/000-default.conf
sudo sed -i "5 i ServerName ${DOMAIN_NAME}" /etc/apache2/sites-available/default-ssl.conf
sudo sed -i "6 i ServerAlias ${DOMAIN_ALIAS_NAME}" /etc/apache2/sites-available/default-ssl.conf

#add the proxy name
sudo sed -i '135 i <Proxy *>\nOrder deny,allow\nAllow from all' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '138 i </Proxy>\nSSLProxyEngine On\nProxyRequests Off\nProxyPreserveHost On' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '142 i ProxyPass / http://127.0.0.1:2053/\nProxyPassReverse / http://127.0.0.1:2053/' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '144 i ProxyPass / http://127.0.0.1:2053/v1\nProxyPassReverse / http://127.0.0.1:2053/v1' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '146 i ProxyPass / http://127.0.0.1:2053/images\nProxyPassReverse / http://127.0.0.1:2053/images' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '148 i ProxyPass / http://127.0.0.1:2053/nftImg\nProxyPassReverse / http://127.0.0.1:2053/nftImg' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i '150 i ProxyPass / http://127.0.0.1:2053/compressedImage\nProxyPassReverse / http://127.0.0.1:2053/compressedImage' /etc/apache2/sites-available/default-ssl.conf

#enable the ssl-virtualhost file
sudo a2ensite default-ssl.conf

#enable http2 htaccess rewrite
sudo a2enmod http2 headers rewrite ssl proxy proxy_ssl proxy_balancer 

#test the configuration are completed with or without error
sudo apach2ctl configtest

#restart the server 
sudo systemctl restart apache2
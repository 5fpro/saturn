echo "Make sure you have set nginx config and point target domain to this server on DNS setting, or you can run:"
echo ""
echo "  bash <(curl -s http://saturn.5fpro.com/nginx/site.sh)"
echo ""
echo "to setup."
echo "(press ENTER to continue)"
read GO

echo "Domain name?"
read DOMAIN_NAME

echo "Nginx config file under /etc/nginx/sites-available/ ?"
read NGINX_CONF

nginx_conf="/etc/nginx/sites-available/$NGINX_CONF"
ori_content=`cat $nginx_conf`

rm -rf ~/dehydrated/
cd ~; git clone https://github.com/lukas2511/dehydrated.git
cd dehydrated/
mkdir -p /etc/dehydrated/
cp ~/dehydrated/dehydrated /etc/dehydrated/
chmod a+x /etc/dehydrated/dehydrated
mkdir -p /var/www/dehydrated/
if grep -q "acme\-challenge" $nginx_conf; then
  echo "configed..."
else
  line_for_ssl="\
  location /.well-known/acme-challenge/ { alias /var/www/dehydrated/; }
  "
  sed -i "/listen 80/a ${line_for_ssl}" $nginx_conf
  echo 'nginx reloading...'
  service nginx restart
fi

/etc/dehydrated/dehydrated -c -d $DOMAIN_NAME

if grep -q "listen 443" $nginx_conf; then
  sed -i "s@# listen 443@listen 443@" $nginx_conf
  sed -i "s@# ssl@ssl@" $nginx_conf
else
  sed -i "0,/listen 80/a\
    listen 443;
    ssl on;
    ssl_certificate /etc/dehydrated/certs/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /etc/dehydrated/certs/${DOMAIN_NAME}/privkey.pem;
  " >> $nginx_conf
fi

echo "Force ssl? (Y/n)"
read force_ssl
if [[ $force_ssl == 'n' || $force_ssl == 'N' ]]; then
  echo ""
else
  sed -i '/acme\-challenge/d' $nginx_conf
  sed -i '0,/listen 80/{//d;}' $nginx_conf
  echo "\
  server {
    listen 80;
    server_name ${DOMAIN_NAME};
    location /.well-known/acme-challenge/ { alias /var/www/dehydrated/; }
    rewrite     ^   https://${DOMAIN_NAME}\$request_uri? permanent;
  }
  " >> $nginx_conf
fi

echo "Done!"
service nginx restart

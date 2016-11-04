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

rm -rf ~/dehydrated/
cd ~; git clone https://github.com/lukas2511/dehydrated.git
cd dehydrated/
mkdir -p /etc/dehydrated/
cp ~/dehydrated/dehydrated /etc/dehydrated/
chmod a+x /etc/dehydrated/dehydrated
mkdir -p /var/www/dehydrated/
if grep -Fxq "acme-challenge" $nginx_conf
then
  echo "configed..."
else
  sed -i '/listen 80/a      location /.well-known/acme-challenge/ { alias /var/www/dehydrated/; }' $nginx_conf
  echo 'nginx reloading...'
  service nginx reload
fi

/etc/dehydrated/dehydrated -c -d $DOMAIN_NAME
echo "Paste following content to $nginx_conf inside 'server { ... }' and reload nginx:"
echo ""
echo "    listen 443;"
echo "    ssl on;"
echo "    ssl_certificate /etc/dehydrated/certs/$DOMAIN_NAME/fullchain.pem;"
echo "    ssl_certificate_key /etc/dehydrated/certs/$DOMAIN_NAME/privkey.pem;"
echo ""
echo "Done!"
sed -i "s@# listen 443@listen 443@" $nginx_conf
sed -i "s@# ssl@ssl@" $nginx_conf

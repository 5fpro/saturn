nginx_conf="/etc/monit/conf.d/nginx"
curl -o $nginx_conf -sSL http://saturn.5fpro.com/monit/nginx/monit.conf

echo "nginx pid file? (/var/run/nginx.pid)"
read NGINX_PID
if [ "$NGINX_PID" == "" ]; then NGINX_PID="/var/run/nginx.pid"; fi;
sed -i "s@{{NGINX_PID}}@${NGINX_PID}@" $nginx_conf

echo "start nginx? (/etc/init.d/nginx start)"
read NGINX_START
if [ "$NGINX_START" == "" ]; then NGINX_START="/etc/init.d/nginx start"; fi;
sed -i "s@{{NGINX_START}}@${NGINX_START}@" $nginx_conf

echo "stop nginx? (/etc/init.d/nginx stop)"
read NGINX_STOP
if [ "$NGINX_STOP" == "" ]; then NGINX_STOP="/etc/init.d/nginx stop"; fi;
sed -i "s@{{NGINX_STOP}}@${NGINX_STOP}@" $nginx_conf

echo "Writing conf file to ${nginx_conf}"
echo "restarting monit..."
/etc/init.d/monit reload

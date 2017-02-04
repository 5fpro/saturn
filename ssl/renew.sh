echo "Domain name?"
read DOMAIN_NAME

cron_file="/etc/cron.monthly/ssl-renewal-${DOMAIN_NAME}"
renew_cmd="(/etc/dehydrated/dehydrated -c -d ${DOMAIN_NAME}) && (/etc/init.d/nginx restart)"
touch $cron_file
echo $renew_cmd >> $cron_file

echo "Test?(y/N)"
read run
if [[ $run == 'y' ]]; then
  bash -c "$renew_cmd"
fi

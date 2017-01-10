echo "rails dir or app name?"
read APP_NAME

bin_file="/etc/init.d/puma-${APP_NAME}"
curl -o $bin_file -sSL http://saturn.5fpro.com/monit/puma/bin.sh
chmod +x $bin_file

conf_file="/etc/monit/conf.d/puma-${APP_NAME}"
curl -o $conf_file -sSL http://saturn.5fpro.com/monit/puma/monit.conf
sed -i "s@{{BIN_FILE}}@${bin_file}@" $conf_file

sed -i "s@{{APP_NAME}}@${APP_NAME}-unicorn@" $conf_file

echo "Your app full path (don't include current)?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $bin_file

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $bin_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $bin_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $bin_file

PID_FILE_PATH="${APP_ROOT}/shared/tmp/pids/puma.pid"
sed -i "s@{{PID_FILE_PATH}}@${PID_FILE_PATH}@" $conf_file

mkdir /root/monit-notify
notify_slack_file="/root/monit-notify/${APP_NAME}-puma-restart-notify-to-slack.sh"
notify_flowdock_file="/root/monit-notify/${APP_NAME}-puma-restart-notify-to-flowdock.sh"
touch $notify_slack_file

cmd_notify=""
echo "flowdock token? (ENTER to skip)"
read flow_token
if [ "$flow_token" == "" ]; then
  touch $notify_flowdock_file
else
  curl -o $notify_flowdock_file -sSL http://saturn.5fpro.com/monit/puma/flowdock-notify.sh
  sed -i "s@{{flow_token}}@${flow_token}@" $notify_flowdock_file
  sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $notify_flowdock_file
  cmd_notify="$cmd_notify && $notify_flowdock_file"
fi;
chmod +x $notify_flowdock_file

echo "slack webhook? (ENTER to skip)"
read slack_webhook
if [ "$slack_webhook" == "" ]; then
  touch $notify_slack_file
else
  echo "target (channel or user) to notify?"
  read slack_target
  curl -o $notify_slack_file -sSL http://saturn.5fpro.com/monit/puma/slack-notify.sh
  sed -i "s@{{slack_webhook}}@${slack_webhook}@" $notify_slack_file
  sed -i "s@{{slack_target}}@${slack_target}@" $notify_slack_file
  sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $notify_slack_file
  cmd_notify="$cmd_notify && $notify_flowdock_file"
fi;
chmod +x $notify_slack_file
sed -i "s@{{cmd_notify}}@${cmd_notify}@" $conf_file

echo "generating bin file in ${bin_file}"
echo "generating conf file to ${conf_file}"
echo "append '${bin_file} start' to /etc/rc.local"
if grep -q "${bin_file} start" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$bin_file"' start\n' /etc/rc.local; fi;
echo "restarting monit..."
/etc/init.d/monit reload

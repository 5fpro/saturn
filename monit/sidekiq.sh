echo "rails app name?"
read APP_NAME

sidekiq_file="/etc/init.d/sidekiq-${APP_NAME}"
curl -o $sidekiq_file -sSL http://saturn.5fpro.com/monit/sidekiq/bin.sh
chmod +x $sidekiq_file

sidekiq_conf="/etc/monit/conf.d/sidekiq-${APP_NAME}"
curl -o $sidekiq_conf -sSL http://saturn.5fpro.com/monit/sidekiq/monit.conf
sed -i "s@{{SIDEKIQ_BIN_FILE}}@${sidekiq_file}@" $sidekiq_conf
sed -i "s@{{APP_NAME}}@${APP_NAME}-sidekiq@" $sidekiq_conf

echo "Your app full path with current dir?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $sidekiq_file

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $sidekiq_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $sidekiq_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $sidekiq_file

echo "sidekiq pid dir path? (${APP_ROOT}/tmp/pids)"
read SIDEKIQ_PID_PATH
if [ "$SIDEKIQ_PID_PATH" == "" ]; then SIDEKIQ_PID_PATH="${APP_ROOT}/tmp/pids"; fi;
sed -i "s@{{SIDEKIQ_PID_PATH}}@${SIDEKIQ_PID_PATH}@" $sidekiq_file

echo "sidekiq pid file path? (${SIDEKIQ_PID_PATH}/sidekiq-0.pid)"
read SIDEKIQ_PID
if [ "$SIDEKIQ_PID" == "" ]; then SIDEKIQ_PID="${SIDEKIQ_PID_PATH}/sidekiq-0.pid"; fi;
sed -i "s@{{SIDEKIQ_PID}}@${SIDEKIQ_PID}@" $sidekiq_file
sed -i "s@{{SIDEKIQ_PID}}@${SIDEKIQ_PID}@" $sidekiq_conf

echo "sidekiq config file path? (${APP_ROOT}/config/sidekiq.yml)"
read SIDEKIQ_CONFIG_FILE
if [ "$SIDEKIQ_CONFIG_FILE" == "" ]; then SIDEKIQ_CONFIG_FILE="${APP_ROOT}/config/sidekiq.yml"; fi;
sed -i "s@{{SIDEKIQ_CONFIG_FILE}}@${SIDEKIQ_CONFIG_FILE}@" $sidekiq_file

echo "sidekiq log file path? (${APP_ROOT}/log/sidekiq.log)"
read SIDEKIQ_LOG_FILE
if [ "$SIDEKIQ_LOG_FILE" == "" ]; then SIDEKIQ_LOG_FILE="${APP_ROOT}/log/sidekiq.log"; fi;
sed -i "s@{{SIDEKIQ_LOG_FILE}}@${SIDEKIQ_LOG_FILE}@" $sidekiq_file

echo "generating bin file in ${sidekiq_file}"
echo "generating conf file to ${sidekiq_conf}"
echo "append '${sidekiq_file} start' to /etc/rc.local"
if grep -q "${sidekiq_file} start" "/etc/rc.local"; then echo "already appened"; else sed -i -e '$i '"$sidekiq_file"' start\n' /etc/rc.local; fi;
echo "restarting monit..."
/etc/init.d/monit reload

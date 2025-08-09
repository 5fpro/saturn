echo "rails dir or app name?"
read APP_NAME

bin_file="/etc/init.d/puma-${APP_NAME}"
curl -o $bin_file -sSL http://saturn.5fpro.com/systemd/puma/bin.sh
chmod +x $bin_file

systemd_service="/etc/systemd/system/puma-${APP_NAME}.service"
test -f $systemd_service && (rm $systemd_service) && (systemctl daemon-reload)
curl -o $systemd_service -sSL http://saturn.5fpro.com/systemd/puma/systemd.service
chmod 644 $systemd_service
sed -i "s@{{APP_NAME}}@${APP_NAME}@" $systemd_service

start_cmd="$bin_file start"
stop_cmd="$bin_file stop"
restart_cmd="$bin_file restart"
sed -i "s@{{START_CMD}}@${start_cmd}@" $systemd_service
sed -i "s@{{STOP_CMD}}@${stop_cmd}@" $systemd_service
sed -i "s@{{RESTART_CMD}}@${restart_cmd}@" $systemd_service

echo "Your app full path WITHOUT current dir?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $bin_file
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $systemd_service

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

echo "puma pid dir path? (${APP_ROOT}/current/tmp/pids)"
read PUMA_PID_PATH
if [ "$PUMA_PID_PATH" == "" ]; then PUMA_PID_PATH="${APP_ROOT}/current/tmp/pids"; fi;
sed -i "s@{{PUMA_PID_PATH}}@${PUMA_PID_PATH}@" $bin_file

echo "puma pid file path? (${PUMA_PID_PATH}/puma.pid)"
read PUMA_PID
if [ "$PUMA_PID" == "" ]; then PUMA_PID="${PUMA_PID_PATH}/puma.pid"; fi;
sed -i "s@{{PUMA_PID}}@${PUMA_PID}@" $bin_file
sed -i "s@{{PID_FILE_PATH}}@${PUMA_PID}@" $systemd_service

echo "puma config file path? (${APP_ROOT}/current/config/puma/${RAILS_ENV}.rb)"
read PUMA_CONFIG_FILE
if [ "$PUMA_CONFIG_FILE" == "" ]; then PUMA_CONFIG_FILE="${APP_ROOT}/current/config/puma/${RAILS_ENV}.rb"; fi;
sed -i "s@{{PUMA_CONFIG_FILE}}@${PUMA_CONFIG_FILE}@" $bin_file

echo "Enabling systemd service..."
systemctl daemon-reload
systemctl enable puma-$APP_NAME
systemctl start puma-$APP_NAME

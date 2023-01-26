echo "rails app name?"
read APP_NAME

systemd_service="/etc/systemd/system/sidekiq-${APP_NAME}.service"
test -f $systemd_service && (rm $systemd_service) && (systemctl daemon-reload)
curl -o $systemd_service -sSL http://saturn.5fpro.com/systemd/sidekiq/systemd.service
chmod 644 $systemd_service
sed -i "s@{{APP_NAME}}@${APP_NAME}@" $systemd_service

echo "Your app full path WITHOUT current dir?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $systemd_service

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $systemd_service

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $systemd_service

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $systemd_service

echo "sidekiq config file path? (${APP_ROOT}/current/config/sidekiq.yml)"
read SIDEKIQ_CONFIG_FILE
if [ "$SIDEKIQ_CONFIG_FILE" == "" ]; then SIDEKIQ_CONFIG_FILE="${APP_ROOT}/current/config/sidekiq.yml"; fi;
sed -i "s@{{SIDEKIQ_CONFIG_FILE}}@${SIDEKIQ_CONFIG_FILE}@" $systemd_service

echo "sidekiq log file path? (${APP_ROOT}/current/log/sidekiq.log)"
read SIDEKIQ_LOG_FILE
if [ "$SIDEKIQ_LOG_FILE" == "" ]; then SIDEKIQ_LOG_FILE="${APP_ROOT}/current/log/sidekiq.log"; fi;
sed -i "s@{{SIDEKIQ_LOG_FILE}}@${SIDEKIQ_LOG_FILE}@" $systemd_service

echo "Enabling systemd service..."
systemctl daemon-reload
systemctl enable sidekiq-$APP_NAME
systemctl start sidekiq-$APP_NAME

echo "modifying sudoers..."
sudoer_start="${DEPLOY_USER} ALL = NOPASSWD: /bin/systemctl start sidekiq-${APP_NAME}"
sudoer_stop="${DEPLOY_USER} ALL = NOPASSWD: /bin/systemctl stop sidekiq-${APP_NAME}"
sudoer_restart="${DEPLOY_USER} ALL = NOPASSWD: /bin/systemctl restart sidekiq-${APP_NAME}"
if grep -q "${sudoer_start}" "/etc/sudoers"; then echo "appended"; else echo $sudoer_start >> /etc/sudoers; fi;
if grep -q "${sudoer_stop}" "/etc/sudoers"; then echo "appended"; else echo $sudoer_stop >> /etc/sudoers; fi;
if grep -q "${sudoer_restart}" "/etc/sudoers"; then echo "appended"; else echo $sudoer_restart >> /etc/sudoers; fi;

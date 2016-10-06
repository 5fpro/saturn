echo "Your app name? (lowcase)"
read APP_NAME

unicorn_file="/etc/init.d/unicorn-${APP_NAME}"
curl -o $unicorn_file -sSL https://gist.githubusercontent.com/marsz/32a8dead9373df326d7bf5fe27d92b89/raw/bbf749e6ec39a82fe9728624cb3dde76b7894266/unicorn.sh
chmod +x $unicorn_file

echo "Your app path?"
read APP_ROOT
sed -i "s@{{APP_ROOT}}@${APP_ROOT}@" $unicorn_file

echo "rails env? (staging)"
read RAILS_ENV
if [ "$RAILS_ENV" == "" ]; then RAILS_ENV="staging"; fi;
sed -i "s@{{RAILS_ENV}}@${RAILS_ENV}@" $unicorn_file

echo "deploy user? (apps)"
read DEPLOY_USER
if [ "$DEPLOY_USER" == "" ]; then DEPLOY_USER="apps"; fi;
sed -i "s@{{DEPLOY_USER}}@${DEPLOY_USER}@" $unicorn_file

echo "deploy group? (apps)"
read DEPLOY_GROUP
if [ "$DEPLOY_GROUP" == "" ]; then DEPLOY_GROUP="apps"; fi;
sed -i "s@{{DEPLOY_GROUP}}@${DEPLOY_GROUP}@" $unicorn_file

echo "unicorn pid dir path? (${APP_ROOT}/tmp/pids)"
read UNICORN_PID_PATH
if [ "$UNICORN_PID_PATH" == "" ]; then UNICORN_PID_PATH="${APP_ROOT}/tmp/pids"; fi;
sed -i "s@{{UNICORN_PID_PATH}}@${UNICORN_PID_PATH}@" $unicorn_file

echo "unicorn pid file path? (${PID_PATH}/unicorn.pid)"
read UNICORN_PID
if [ "$UNICORN_PID" == "" ]; then UNICORN_PID="${PID_PATH}/unicorn.pid"; fi;
sed -i "s@{{UNICORN_PID}}@${UNICORN_PID}@" $unicorn_file

echo "unicorn config file path? (${APP_ROOT}/config/unicorn/${RAILS_ENV}.rb)"
read UNICORN_CONFIG_FILE
if [ "$UNICORN_CONFIG_FILE" == "" ]; then UNICORN_CONFIG_FILE="${APP_ROOT}/config/unicorn/${RAILS_ENV}.rb"; fi;
sed -i "s@{{UNICORN_CONFIG_FILE}}@${UNICORN_CONFIG_FILE}@" $unicorn_file


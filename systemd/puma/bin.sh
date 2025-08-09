#!/bin/sh
### BEGIN INIT INFO
# Provides: unicorn
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop:
### END INIT INFO
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

### Unicorn Variables ###

TIMEOUT=60

# 你的 rails app dir
APP_ROOT={{APP_ROOT}}
APP_ROOT_CURRENT={{APP_ROOT}}/current

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# puma pid dir
PUMA_PID_PATH={{PUMA_PID_PATH}}

# puma pid file path
PUMA_PID={{PUMA_PID}}

# puma config, 不同環境用不同檔名
PUMA_CONFIG_FILE={{PUMA_CONFIG_FILE}}

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION=`cat ${APP_ROOT_CURRENT}/.ruby-version`
BUNDLE_PREFIX="EXECJS_RUNTIME=Node NODE_ENV=production PATH=\$PATH:$USER_HOME/.nvm/versions/node/`cat $USER_HOME/.nvm/alias/default`/bin RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"

me=$(whoami)

# full command
PUMA_STATE_FILE="${APP_ROOT}/shared/tmp/pids/puma.state"
CMD_PREFIX="cd ${APP_ROOT_CURRENT} && RAILS_ENV=\"${RAILS_ENV}\" ${BUNDLE_PREFIX} bundle exec "
START_CMD="${CMD_PREFIX} puma -e ${RAILS_ENV} -C \"${PUMA_CONFIG_FILE}\""
STOP_CMD="${CMD_PREFIX} pumactl -S \"${PUMA_STATE_FILE}\" stop"
RESTART_CMD="${CMD_PREFIX} pumactl -S \"${PUMA_STATE_FILE}\" phased-restart"

if [ $me = "root" ]; then
  START_CMD="sudo -H -u $DEPLOY_USER bash -c \"$START_CMD\""
  STOP_CMD="sudo -H -u $DEPLOY_USER bash -c \"$STOP_CMD\""
  RESTART_CMD="sudo -H -u $DEPLOY_USER bash -c \"$RESTART_CMD\""
fi;

action="$1"
set -u

# 檢查PID, 並且砍掉該服務
sig () {
  test -n $pid_number && kill -$1 $pid_number
}

# 檢查路徑, 如果不存在就自行開路徑
create_if_not_exists () {
  test -d $PUMA_PID_PATH || (mkdir -p $PUMA_PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $PUMA_PID_PATH)
}

puma_running() {
  [[ -f "$PUMA_STATE_FILE" && -f "$PUMA_PID" ]] && kill -0 "$(cat "$PUMA_PID")" 2>/dev/null
}

case $action in
start)
  create_if_not_exists
  bash -c "$START_CMD"
;;
stop)
  if puma_running; then
    bash -c "$STOP_CMD"
  else
    echo "Puma is not running"
  fi
;;
restart)
  if puma_running; then
    echo "[INFO] Puma running; doing phased restart..."
    bash -c "$RESTART_CMD"
  else
    echo "[WARN] Puma not running; starting it..."
    create_if_not_exists
    bash -c "$START_CMD"
  fi
;;
*)
  echo >&2 "Usage: $0 <start|stop|restart>"
  exit 1
;;
esac

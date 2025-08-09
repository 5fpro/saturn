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

# --- 固定變數 ---
APP_ROOT={{APP_ROOT}}
APP_ROOT_CURRENT={{APP_ROOT}}/current
RAILS_ENV={{RAILS_ENV}}
DEPLOY_USER={{DEPLOY_USER}}
DEPLOY_GROUP={{DEPLOY_GROUP}}

PUMA_STATE_FILE="${APP_ROOT}/shared/tmp/pids/puma.state"
PUMA_PID="${APP_ROOT}/shared/tmp/pids/puma.pid"
PUMA_SOCK="${APP_ROOT}/shared/tmp/sockets/puma.sock"
PUMA_LOG_DIR="${APP_ROOT}/shared/log"
PUMA_CONFIG_FILE="${APP_ROOT_CURRENT}/config/puma/${RAILS_ENV}.rb"

USER_HOME="/home/${DEPLOY_USER}"
RUBY_VERSION="$(cat "${APP_ROOT_CURRENT}/.ruby-version")"
BUNDLE_PREFIX="EXECJS_RUNTIME=Node NODE_ENV=production PATH=\$PATH:$USER_HOME/.nvm/versions/node/$(cat $USER_HOME/.nvm/alias/default)/bin RBENV_ROOT=$USER_HOME/.rbenv RBENV_VERSION=$RUBY_VERSION $USER_HOME/.rbenv/bin/rbenv exec"

CMD_PREFIX="cd ${APP_ROOT_CURRENT} && RAILS_ENV=\"${RAILS_ENV}\" ${BUNDLE_PREFIX} bundle exec "
START_CMD="${CMD_PREFIX} puma -e ${RAILS_ENV} -C \"${PUMA_CONFIG_FILE}\" --pidfile \"${PUMA_PID}\""
STOP_CMD="${CMD_PREFIX} pumactl -S \"${PUMA_STATE_FILE}\" stop"
RESTART_CMD="${CMD_PREFIX} pumactl -S \"${PUMA_STATE_FILE}\" phased-restart"

if [ "$(whoami)" = "root" ]; then
  START_CMD="sudo -H -u $DEPLOY_USER bash -c \"$START_CMD\""
  STOP_CMD="sudo -H -u $DEPLOY_USER bash -c \"$STOP_CMD\""
  RESTART_CMD="sudo -H -u $DEPLOY_USER bash -c \"$RESTART_CMD\""
fi

# 建目錄：shared 下的 pids/sockets/log
create_if_not_exists () {
  for d in "${APP_ROOT}/shared/tmp/pids" "${APP_ROOT}/shared/tmp/sockets" "${PUMA_LOG_DIR}"; do
    [ -d "$d" ] || (mkdir -p "$d" && chown $DEPLOY_USER.$DEPLOY_GROUP "$d")
  done
}

# 以 shared 上的 pid+state 判斷 Puma 是否在跑
puma_running() {
  [ -f "$PUMA_STATE_FILE" ] && [ -f "$PUMA_PID" ] && kill -0 "$(cat "$PUMA_PID")" 2>/dev/null
}

action="$1"
set -u

case "$action" in
  start)
    create_if_not_exists
    bash -c "$START_CMD"
    ;;
  stop)
    if puma_running; then
      bash -c "$STOP_CMD"
    else
      echo "[INFO] Puma not running; nothing to stop."
    fi
    ;;
  restart)
    if puma_running; then
      echo "[INFO] Puma running; phased restart..."
      bash -c "$RESTART_CMD"
    else
      echo "[WARN] Puma not running; starting..."
      create_if_not_exists
      bash -c "$START_CMD"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}" >&2
    exit 1
    ;;
esac

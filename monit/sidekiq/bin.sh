#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

# 你的 rails app dir
APP_ROOT={{APP_ROOT}}

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# sidekiq pid dir
SIDEKIQ_PID_PATH={{SIDEKIQ_PID_PATH}}

# sidekiq pid file path
SIDEKIQ_PID={{SIDEKIQ_PID}}

# sidekiq config yml file path
SIDEKIQ_CONFIG_FILE={{SIDEKIQ_CONFIG_FILE}}

# sidekiq log file path
SIDEKIQ_LOG_FILE={{SIDEKIQ_LOG_FILE}}


# full command
CMD="cd ${APP_ROOT} && /usr/local/rvm/bin/rvm default do bundle exec sidekiq --index 0 --pidfile ${SIDEKIQ_PID} --environment ${RAILS_ENV} --logfile ${SIDEKIQ_LOG_FILE} --config ${SIDEKIQ_CONFIG_FILE} --daemon"
# echo "DEBUG:"
# echo $CMD

action="$1"
set -u

# 檢查PID, 並且砍掉該服務
sig () {
  test -s "$SIDEKIQ_PID" && kill -$1 `cat $SIDEKIQ_PID`
}

# 檢查路徑, 如果不存在就自行開路徑
create_SIDEKIQ_PID_PATH () {
  test -d $SIDEKIQ_PID_PATH || (mkdir -p $SIDEKIQ_PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $SIDEKIQ_PID_PATH)
}

case $action in
start)
  create_SIDEKIQ_PID_PATH
  sig 0 && echo >&2 "Already running" && exit 0
  sudo -H -u $DEPLOY_USER bash -c "$CMD" # 使用 $DEPLOY_USER 執行指令
;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
;;
*)
  echo >&2 "Usage: $0 <start|stop>"
  exit 1
;;
esac

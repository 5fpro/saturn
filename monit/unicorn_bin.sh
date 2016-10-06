# Put this file at /etc/init.d and chmod +x
# also you can add /etc/init.d/unicorn-musico.staging.sh to /etc/rc.local

#!/bin/sh
set -e

# Include Bundler path
PATH=$PATH:/usr/local/bin

### Unicorn Variables ###

TIMEOUT=60

# 你的 rails app dir
APP_ROOT={{APP_ROOT}}

# rails env
RAILS_ENV={{RAILS_ENV}}

# deploy user
DEPLOY_USER={{DEPLOY_USER}}

# deploy group
DEPLOY_GROUP={{DEPLOY_GROUP}}

# unicorn pid dir
UNICORN_PID_PATH={{UNICORN_PID_PATH}}

# unicorn pid file path
UNICORN_PID={{UNICORN_PID}}

# unicorn config, 不同環境用不同檔名
UNICORN_CONFIG_FILE={{UNICORN_CONFIG_FILE}}

# full command
CMD="cd ${APP_ROOT} && ( export RAILS_ENV=\"${RAILS_ENV}\" ; /usr/local/rvm/bin/rvm default do bundle exec unicorn -c ${CONFIG_FILE} -E deployment -D )"
# echo "DEBUG:"
# echo $CMD

action="$1"
set -u

sig () {
 test -s "$UNICORN_PID" && kill -$1 `cat $UNICORN_PID`
}

create_pid_path () {
 test -d $UNICORN_PID_PATH || (mkdir -p $UNICORN_PID_PATH && chown $DEPLOY_USER.$DEPLOY_GROUP $UNICORN_PID_PATH)
}

case $action in
start)
 create_pid_path
 sig 0 && echo >&2 "Already running" && exit 0
 sudo -H -u $DEPLOY_USER bash -c "$CMD"
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

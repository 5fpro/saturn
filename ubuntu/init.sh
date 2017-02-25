echo "Create user? [Y/n]"
read create_user
echo "Install nginx? [y/N]"
read nginx
echo "Install postgresql client lib? [y/N]"
read pg
echo "Install mysql client lib? [y/N]"
read mysql
echo "Pick timezone? [y/N]"
read pick_timezone

apt-get update
apt-get upgrade -y
apt-get install build-essential curl git-core -y

echo "Daily ntpdate in /etc/cron.daily/ntpdate ..."
ntpdate ntp.ubuntu.com
echo "ntpdate ntp.ubuntu.com" >> /etc/cron.daily/ntpdate

echo "Language pack..."
locale-gen zh_TW.UTF-8
apt-get install language-pack-zh-hant -y

echo "Openssl..."
apt-get install openssl libssl-dev -y
apt-get upgrade openssl libssl-dev -y
dhparam_file="/etc/nginx/cert/dhparam.pem"
if [ -f "$dhparam_file" ]; then
  echo ""
else
  mkdir -p /etc/nginx/cert/
  openssl dhparam 2048 -out $dhparam_file
fi;

echo "Colorful command line..."
sed -i "s@#force_color_prompt@force_color_prompt@" ~/.bashrc
source ~/.bashrc
sed -i "s@#force_color_prompt@force_color_prompt@" /home/ubuntu/.bashrc
chown ubuntu:ubuntu /home/ubuntu/.bashrc

if [[ $create_user != 'n' ]]; then
  bash <(curl -s http://saturn.5fpro.com/ubuntu/adduser.sh)
fi;

if [[ $nginx == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/nginx/hi.sh)
  bash <(curl -s http://saturn.5fpro.com/monit/install.sh)
  bash <(curl -s http://saturn.5fpro.com/monit/nginx.sh)
fi;

if [[ $pg == 'y' ]]; then apt-get install -y libpq-dev; fi;

if [[ $mysql == 'y' ]]; then apt-get install -y libmysqlclient-dev; fi;

if [[ $pick_timezone == 'y' ]]; then dpkg-reconfigure tzdata; fi;

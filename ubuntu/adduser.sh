echo "user? [apps]"
read user
if [[ $user == "" ]]; then user="apps"; fi;
echo "Public key for ssh? (ENTER to skip)"
read public_key

if [ -f "/home/${user}/.bashrc" ]; then
  echo "User ${user} exists"
else
  adduser --disabled-password --gecos "" $user
fi;

if [[ $public_key != "" ]]; then
  target_file="/home/${user}/.ssh/authorized_keys"
  mkdir /home/$user/.ssh
  chown 0700 /home/$user/.ssh
  echo $public_key >> $target_file
  chmod 0600 $target_file
  chown -R $user:$user /home/$user/.ssh
fi;

bashrc="/home/${user}/.bashrc"
sed -i "s@#force_color_prompt@force_color_prompt@" $bashrc
chown $user:$user /home/$user/.bashrc

echo "Install rbenv?[y/N]"
read rbenv
if [[ $rbenv == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/rbenv/install.sh)
fi;

echo "Install nodejs?[y/N]"
read nodejs
if [[ $nodejs == 'y' ]]; then
  bash <(curl -s http://saturn.5fpro.com/nodejs/install.sh)
fi;

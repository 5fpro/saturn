echo "Enter your server identify(name), without space"
read hname

apt-get install -y figlet toilet

if [[ $hname != "" ]]; then
  line="127.0.0.1 $hname"
  if grep -q "${line}" "/etc/hosts"; then echo "exists"; else echo "$line" >> "/etc/hosts"; fi;
  hostname $hname
  toilet --gay -f standard $hname > /etc/motd
  echo $hname > /etc/hostname
  echo 'done!'
fi;

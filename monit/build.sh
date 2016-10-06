read -p "setup nginx? (y/N)" ans
if [[ (ans == "y") || (ans == "Y") ]]; then
  curl -o /tmp/nginx.sh http://saturn.5fpro.com/monit/build_nginx.sh
  chmod +x /tmp/nginx.sh
  /tmp/nginx.sh
  rm /tmp/nginx.sh
fi;

read -p "setup unicorn? (y/N)" ans
if [[ (ans == "y") || (ans == "Y") ]]; then
  curl -o /tmp/unicorn.sh http://saturn.5fpro.com/monit/build_unicorn.sh
  chmod +x /tmp/unicorn.sh
  /tmp/unicorn.sh
  rm /tmp/unicorn.sh
fi;


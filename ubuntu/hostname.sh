echo "Enter your server identify(name)"
read hname

if [[ $hname != "" ]]; then
  line="127.0.0.1 $hname"
  if grep -q "${line}" "/etc/hosts"; then echo "exists"; else echo "$line" >> "/etc/hosts"; fi;
  hostname $hname
fi;

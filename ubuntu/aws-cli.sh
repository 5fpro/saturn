echo "user? [apps]"
read user
if [[ $user == "" ]]; then user="apps"; fi;

apt-get install python3.4 python3-dev -y

user_home="/home/${user}"
shell="\
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
echo \"export PATH=\\\"\$HOME/.local/bin:\$PATH\\\"\" >> $user_home/.bashrc
source $user_home/.bashrc
pip install awscli --upgrade --user
aws configure
"
tmp_file="/tmp/aws-cli-install.sh"
echo "$shell" > $tmp_file
chmod +x $tmp_file
sudo -i -u $user bash -c $tmp_file
rm $tmp_file

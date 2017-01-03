cd /root
apt-get update
apt-get install unzip -y
apt-get install libwww-perl libdatetime-perl -y
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm CloudWatchMonitoringScripts-1.2.1.zip
cd aws-scripts-mon

echo "Please make sure your IAM role has following permissions:cloudwatch:PutMetricData
- cloudwatch:GetMetricStatistics
- cloudwatch:ListMetrics
- ec2:DescribeTags

ref IAM policy:
{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
        {
            \"Sid\": \"Stmt1483448372000\",
            \"Effect\": \"Allow\",
            \"Action\": [
                \"cloudwatch:GetMetricStatistics\",
                \"cloudwatch:ListMetrics\"
            ],
            \"Resource\": [
                \"*\"
            ]
        },
        {
            \"Sid\": \"Stmt1483448479000\",
            \"Effect\": \"Allow\",
            \"Action\": [
                \"ec2:DescribeTags\"
            ],
            \"Resource\": [
                \"*\"
            ]
        }
    ]
}
"
echo "press ENTER to contiune"
read temp

echo "AWS access key:"
read AWS_ACCESS_KEY
echo "AWS secret key:"
read AWS_SECRET_KEY

CONFIG_FILE="/root/aws-scripts-mon/awscreds.template"
sed -i "s@AWSAccessKeyId=@AWSAccessKeyId=${AWS_ACCESS_KEY}@" $CONFIG_FILE
sed -i "s@AWSSecretKey=@AWSSecretKey=${AWS_SECRET_KEY}@" $CONFIG_FILE

touch /var/spool/cron/crontabs/root
if [[ `cat /var/spool/cron/crontabs/root | grep aws-scripts` ]]; then
  echo "crontab already exists";
else
  echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" >> /var/spool/cron/crontabs/root
fi;

echo "done!"

#!/bin/sh
#
# See: http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html
# Must remove trailing \n if any, for consumption by printf
#
#cloudenv.sh allows to override some default settings
test -f /etc/cloudenv.sh && . /etc/cloudenv.sh
#check for a pre-canned value from /etc/cloudenv.sh
test ! -z $AWSInstanceID && echo -n $AWSInstanceID && exit 0
#check for a previously cached value
InstanceIDFile=/tmp/.AWSInstanceID
test -f $InstanceIDFile && echo -n `cat $InstanceIDFile` && exit 0
#otherwise let's fetch it from metadata server
wget http://169.254.169.254/latest/meta-data/instance-id -O $InstanceIDFile
nw=`wc -w < $InstanceIDFile`
#echo "nw=$nw"
test $nw -ne 1 && rm $InstanceIDFile &&  echo -n 'UnknowID' && exit 0
chmod 0666 $InstanceIDFile
echo -n `cat $InstanceIDFile`
exit 0


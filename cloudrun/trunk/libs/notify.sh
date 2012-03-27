#!/bin/sh
#
# Send a message over AWS SNS
# Gather parameters
# and call AWS SNS Publish API
# See: http://aws.amazon.com/documentation/sns/
#
# Assert args: subject value
test $# -lt 2  && echo "$0 Missing argument(s)" && exit 1
#
#cloudenv.sh allows to override some default settings
test -f /etc/cloudenv.sh && . /etc/cloudenv.sh
#Check if SNS service is disabled
test ! -z $StopAWSSNS && echo "$0 StopAWSSNS is set in /etc/cloudenv.sh: SNS Publish is disabled" && exit 0
InstanceID=`InstanceID.sh`
subject="$InstanceID $1"
echo "$0 args:[$subject] [$2]"
AWSSNSPublish.py "$subject" "$2"
exit 0





 

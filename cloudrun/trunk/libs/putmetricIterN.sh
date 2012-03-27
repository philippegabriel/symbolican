#!/bin/sh -e
#
# Publish iterN to cloudwatch
#
#source the task env variable
. /etc/taskenv.sh
#cloudenv.sh allows to override some default settings
test -f /etc/cloudenv.sh && . /etc/cloudenv.sh
#Check if cloudwatch service is disabled
test ! -z $StopAWSCloudwatch && echo "$0 StopAWScloudwatch is set in /etc/cloudenv.sh: Abort" && exit 0
InstanceID=`InstanceID.sh`
delta=`cnt2TS.sh /tmp/iterN`
#echo $InstanceID $delta
AWSCloudWatchPutMetricData.py $InstanceID "$NAMESPACE" "$TASK" 'iterN' $delta





 

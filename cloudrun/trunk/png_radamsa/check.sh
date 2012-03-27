#!/bin/sh -e
#Utility script to check a few functions
#
echo "$0 Starting..." 
#
#If no params display Usage
#
if [ $# -eq 0 ] ; then echo "Usage: $0 (sns|cloudwatch|crash|samples|<SEED>)"; exit 0 ; fi
#source environment variables
. /etc/taskenv.sh
export DISPLAY
case $1 in
"sns")
	echo 'Calling SNS Publish...'
	notify.sh "SNS Publish Test from $0" "This message was sent from: $0"
	;;
"cloudwatch")
	echo 'Calling cloudwatchPublish...'
	InstanceID=`InstanceID.sh`
	AWSCloudWatchPutMetricData.py $InstanceID "$NAMESPACE" Test Test 99
	;;
"crash")
	$EXE $CRASH
	;;
"samples")
	PIXELLOG=/tmp/pixlog.samples.png
	$EXE --test-shell --pixel-tests=$PIXELLOG  $SAMPLEHTML
	;;
*)
	SEED=$1
   $RADAMSA -n $FUZZCOUNT -s $SEED -o $FUZZDIR/$FUZZOUT $SAMPLEDIR/$FUZZIN
	PIXELLOG=/tmp/pixlog.fuzzed.png
	$EXE  --test-shell --pixel-tests=$PIXELLOG  $FUZZHTML
esac	
exit 0


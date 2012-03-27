#!/bin/sh -e 
#
# convert running counter to Time Series
# Reads content of file given as arg
# delta it with previously saved value
# returns the delta and save it
#
#Bail out if no arg
test -z $1 && echo "$0 no parameter given" && exit 1
countFile=$1
prevFile=$1'prev'
#
#Return 0 if arg file doesn't exist
#
test ! -f $countFile && echo 0 && exit 1
#
#Fetch accumulating counter
#
count=`cat $countFile`
#
#Fetch previously stored value
#
prev=0
test -f $prevFile && prev=`cat $prevFile`
#
#Save counter value
#
echo -n $count > $prevFile
#
#Compute the delta
#
test $(($prev)) -gt $(($count)) && prev=0 
delta=$(($count - $prev))
#
#Print the result
#
#echo 'ok:' $prev $count $delta
echo -n $delta
exit 0



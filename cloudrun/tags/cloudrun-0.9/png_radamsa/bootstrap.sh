#!/bin/sh -e
#
# 1]Retrieve AWS metadata and cache it in /tmp
# 2]Fetch Execurable under test (DumpRenderTree)
# 3]Fetch Test executable (radamsa)
# 4]Fetch input samples for fuzzing
#
# This script is started by the bootstrap.conf upstart job
#
# Precondition:	Dependency packages already installed
#						with a cloud-init/cloud-config/package section
#						Xvfb is started on DISPLAY=:99
#
# Postcondition: 	Directory structure has been created
#						Executable under test and test environment is setup
# 
echo "$0 Starting..."
#source the environment variables
. /etc/taskenv.sh
#cloudenv.sh allows to override default settings
test -f /etc/cloudenv.sh && . /etc/cloudenv.sh
#
# Create dir structure
#
mkdir -p $SAMPLEDIR $FUZZDIR $EXEDIR $TESTDIR
#
# Install EXE Under test
#
#Default DRT architecture to 32 bits
DRTS3Key=$DRT32S3Key
#override to x64 if needed
test `uname -m | grep 'x86_64'` && DRTS3Key=$DRT64S3Key
echo "Fetching S3::$DRTS3Bucket/$DRTS3Key..." 
#If an alternate URL is set in /etc/cloudenv.sh, fetch it from there instead
test ! -z $ALTURL && URL=$ALTURL/$DRTS3Key 
#Generate AWS S3 signed URL and fetch
test -z $URL && URL=`AWSS3GenURL.py $DRTS3Bucket $DRTS3Key`
test -e $DRTS3Key && echo "Using cached copy" || wget --progress=bar:force --no-proxy $URL -O $DRTS3Key
tar -C $EXEDIR -zxf $DRTS3Key 
#
# Install radamsa
#
URL=$RADAMSAURL
test ! -z $ALTURL && URL=$ALTURL #override if needed
echo "Fetching $URL/$RADAMSAARCHIVE..." 
test -e $RADAMSAARCHIVE && echo "Using cached copy" || wget --progress=bar:force $URL/$RADAMSAARCHIVE -O $RADAMSAARCHIVE
cp  $RADAMSAARCHIVE $RADAMSA
chmod +x $RADAMSA

#
# Install Test Input
#
URL=$SAMPLESURL
test ! -z $ALTURL && URL=$ALTURL #override if needed
echo "Fetching $SAMPLESURL..." 
test -e $SAMPLES && echo "Using cached copy" || wget --progress=bar:force $URL/$SAMPLES -O $SAMPLES
tar -C $SAMPLEDIR -zxf $SAMPLES
#
#Generate fuzz HTML input file
#
for i in $(seq 1 $FUZZCOUNT) ; do echo "<img src=$FUZZDIR/test-$i.png>"; done > $FUZZHTML
#
#Generate samples HTML input file
#
for file in $SAMPLEDIR/*.png; do echo "<img src=$file>"; done > $SAMPLEHTML

#
#Check all is up and running
#
echo "Checking $RADAMSA..."
SEED=`openssl rand -base64 15`
$RADAMSA -n $FUZZCOUNT -s $SEED -o $FUZZDIR/$FUZZOUT $SAMPLEDIR/$FUZZIN

echo "Checking $EXE..."
export DISPLAY
$EXE $SAMPLEHTML > /dev/null 2>&1
#Start the cloudwatch metrics crontab
crontab $HOME/.crontab

#Any fault should prevent us to reach here and start run.sh
echo '=============================='
echo '>>>bootstrap.sh is COMPLETE<<<'
echo '=============================='
exit 0


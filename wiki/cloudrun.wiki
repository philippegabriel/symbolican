#summary Description of cloudrun
#sidebar TableOfContents
= Introduction =
This project sets up an [http://aws.amazon.com/ec2/ Amazon (AWS) EC2 instance], with:
 * [http://dev.chromium.org/developers/testing/webkit-layout-tests DumpRenderTree]: a UI-less build of [https://www.google.com/chrome Google Chrome].
 * [http://code.google.com/p/ouspg/wiki/Radamsa radamsa]: A fuzzer from Oulu University Secure Programming Group (OUSPG). 
 * Sample files, either [http://en.wikipedia.org/wiki/Cascading_Style_Sheets Cascading Style Sheet (CSS)], or [http://en.wikipedia.org/wiki/Portable_Network_Graphics Portable Network Graphics (png)].

Once setup, the instance executes forever (or more likely until stopped) the following sequence:
 * Generate a batch of [http://en.wikipedia.org/wiki/Fuzzing fuzzed files] (with [http://code.google.com/p/ouspg/wiki/Radamsa radamsa]).
 * Render html page(s) embedding the fuzzed files with [http://dev.chromium.org/developers/testing/webkit-layout-tests DumpRenderTree].
 * If a crash is detected, sends an email to an [http://docs.amazonwebservices.com/sns/latest/gsg/Subscribe.html email address of your choice], with enough details to recreate the crash.

The performance of the instance (number of test runs) can be monitored on the [http://aws.amazon.com/console/ Amazon management console] via the [http://docs.amazonwebservices.com/AmazonCloudWatch/latest/GettingStartedGuide/ViewGraphs.html AWS CloudWatch service].


= AWS EC2 instance setup =
The cloudrun project consists of a collection of Python, shell scripts, [http://upstart.ubuntu.com/cookbook Linux upstart jobs] and configuration files.

These files are bundled together, with the [https://help.ubuntu.com/community/CloudInit cloudinit] utility. The result serves as initialisation data provided to an Amazon EC2 instance.

When an EC2 instance starts up, that has the cloudinit package pre-installed (as is the case with all the [https://help.ubuntu.com/community/UEC/Images Ubuntu EC2 images]), this initialisation data is parsed and as a result:
 * Extra packages are installed.
 * Scripts and config files are extracted and installed at the relevant places.
 * Upstart jobs are scheduled.

This allows for an entirely automated and consistent setup.

= Running the AWS EC2 instance =
That's the easiest part, since the setup is entirely automated, there is nothing to do apart from monitoring the mail address you provided.

There should never be any need to actually login to your instance, unless of course you are curious and you want to poke around :) 
= Environment supported =
AWS EC2 instances boot from an [https://aws.amazon.com/amis Amazon Machine Image], it is our goal to utilise pre-existing stock AMI, rather than build our own.

The project dependencies are:
 * [https://help.ubuntu.com/community/CloudInit cloudinit]
 * [http://boto.readthedocs.org/en/latest/index.html boto library] version >= 2.0
 * The amount of disk and memory required is fairly small and fits comfortably into the smallest AWS machines (i.e. [http://aws.amazon.com/ec2/instance-types/ micro-instances])
These requirements naturally call for an [https://help.ubuntu.com/community/UEC/Images ubuntu AMI]
Since we need a boto library >=2.0, this limits our choice to at least an 11.10 ubuntu [http://cloud.ubuntu.com/ami/ ubuntu AMI].

You can run in any region, 32 or 64 bits, ebs or instance store are both supported.
These are the 4 AMIs I used during testing.
||*Zone*||*Name*||*Arch*||*EBS*||*Release*||*AMI-ID*||
||eu-west-1||oneiric||amd64||ebs||20120222||[https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-895069fd ami-895069fd]||
||eu-west-1||oneiric||i386||ebs||20120222||[https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-8d5069f9 ami-8d5069f9]||
||eu-west-1||oneiric||amd64||instance-store||20120222||[https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-af5069db ami-af5069db]||
||eu-west-1||oneiric||i386||instance-store||20120222||[https://console.aws.amazon.com/ec2/home?region=eu-west-1#launchAmi=ami-b15069c5 ami-b15069c5]||

= Project setup =
==Prerequisites==
You need a valid [http://aws.amazon.com/ec2/ Amazon EC2 account], note that you can [http://aws.amazon.com/free/ do this for free]
Once you have an account you need to sign up for: 
 * [http://aws.amazon.com/sns/ Amazon Simple Notification Service (SNS)].
 * [http://aws.amazon.com/cloudwatch/ Amazon CloudWatch].
==Configuration==
cloudrun produces a gzip multi-MIME part [https://help.ubuntu.com/community/CloudInit cloudinit] initialisation file.

However, before this can be created succesfully, you need to customise a configuration file with your AWS EC2 account information.

The information needed is: 
 * [http://docs.amazonwebservices.com/AWSSecurityCredentials/1.0/AboutAWSCredentials.html#AccessKeys AWS credentials], to allow the instance to:
  * Download the !DumpRenderTree binary from [http://aws.amazon.com/s3/ AWS S3].
  * Upload metrics to [http://aws.amazon.com/cloudwatch/ AWS CloudWatch].
  * Send email via [http://aws.amazon.com/sns/ AWS Simple Notification Service].
 * [http://docs.amazonwebservices.com/sns/latest/gsg/CreateTopic.html SNS topic ARN], as a proxy for the email address.

Since all the AWS Services are accessed via the [http://boto.readthedocs.org/en/latest/index.html boto library], this information is kept in the [http://boto.readthedocs.org/en/latest/boto_config_tut.html boto configuration file:] ./config/.boto


*_Note for the cautious:_* We understand that supplying credentials to an untrusted party sounds fairly alarming :)
As explained [http://www.elastician.com/2010_09_01_archive.html in this posting], we recommend that you create a special "cloudrun" account, with the [http://docs.amazonwebservices.com/IAM/latest/GettingStartedGuide/Welcome.html?r=1527 AWS Identity and Access Management service].

Limit this account privilege to: *`s3:Get`*, *`sns:Publish`*, *`cloudwatch:PutMetricData`*, using the  [http://docs.amazonwebservices.com/IAM/latest/UserGuide/ManagingPolicies.html AWS IAM Policy generator].

Doing this will rule out any third party to cause mischief, such as launching extra instances.

=Generating the AWS EC2 initialisation file=
The Makefile at the root of the cloudrun project has 4 targets:
*`ec2png`*, *`ec2css`*, *`kvmpng`*, *`kvmcss`*.

To generate any target, e.g. the png fuzzing test initialisation file, type :
{{{
 make ec2png
}}}
This creates a: *userdata-cloud-init.ec2png.txt.gz* file, to provide as user data to an AWS EC2 instance.
=Starting the AWS EC2 instance=
Login to the [http://aws.amazon.com/console/ AWS Management Console], and start an instance.

In the *`Instance Details`* panel, chose *`User Data`*, *`as file`* and select the file produced in the previous step.

https://docs.google.com/drawings/pub?id=1CU9drmgCXIxKPr4E9G-6wdLD2mse8JXOXL2IodCkOig&w=480&h=360&type=image.png
=Checking if the AWS EC2 instance started OK=
In the [http://aws.amazon.com/console/ AWS Management Console], get the *`System Log`* for the instance.

Scroll down to the last entries, a succesful startup will show lines, like:
{{{
Checking /tmp/testbin/radamsa-0.2.3...
Checking /tmp/bin/DumpRenderTree...
==============================
>>>bootstrap.sh is COMPLETE<<<
==============================
post-stop bootstrap.conf
pre-start run.conf...
bootstrap stopped with status:ok
Starting: /home/ubuntu/run.sh with args:loop forever ...
Parsed arguments: n=forever logpixel=0 crash=0 modcrash=0
Start Testing /tmp/bin/DumpRenderTree with inputs generated by /tmp/testbin/radamsa-0.2.3
}}}
=Diagnosing failure=
The *`System Log`* should provide enough information to diagnose a problem.
{{{
Fetching http://www.foo.com/...
--2012-03-28 16:21:19--  http://www.foo.com/foo.tgz
Resolving www.foo.com... 107.21.219.15
Connecting to www.foo.com|107.21.219.15|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
2012-03-28 16:21:19 ERROR 404: Not Found.

post-stop bootstrap.conf
pre-start run.conf...
bootstrap stopped with status:failed
run.conf is Aborting
run stop/pre-start, process 3346
post-stop run.conf
}}}
In this case, the hypothetical: http://www.foo.com/foo.tgz could not be found

The lines after the 404 error come from the `bootstrap.conf` and `run.conf` Upstart jobs which abort in case of error

In most cases, there should be enough diagnostic info, but if you see something really odd happening, please get in touch.
=Note on running with micro instances=
When running on micro instance in the eu-west region, I hit in about 50% of cases the following [https://bugs.launchpad.net/ubuntu/+source/linux-ec2/+bug/634487 bug].
The bottom line is that there is an hypervisor defect in the EC2 environment.
The following bug manifests itself by the following trace on the System Log
{{{

[ 2029.678337] 1 multicall(s) failed: cpu 0
[ 2029.678458] 1 multicall(s) failed: cpu 0
[ 2029.678578] 1 multicall(s) failed: cpu 0
[ 2029.678702] 1 multicall(s) failed: cpu 0
[ 2029.678822] 1 multicall(s) failed: cpu 0
[ 2029.678943] 1 multicall(s) failed: cpu 0
[ 2029.679063] 1 multicall(s) failed: cpu 0
[ 2029.679182] 1 multicall(s) failed: [ 2031.184425]  [<c01070d6>] ? __raw_callee_save_xen_save_fl+0x6[ 2031.184447]  [<c01b89f6>] ? rcu_enter_nohz+0x36/0xc0
[ 2031kf536ba5a52d[ 2033.197[ 2036.204767] init: rsyslog main process ended, respawning
}}}
Once you see that the instance is dead.

The workaround, as explained in the defect report is either to run a 64 bit instance (tested) or run in the us-west-2 region (untested)
=Monitoring the AWS EC2 instance=
The instance communicates via 2 channels
 * [http://aws.amazon.com/cloudwatch/ AWS CloudWatch console] displaying the number of test runs.
 * Email via the [http://aws.amazon.com/sns/ AWS Simple Notification Service] proxy, when a crash is found.
==email format==
===subject===
{{{
 i-e6a985af DumpRenderTree crash with seed=waNZCuzh62cGNknIqUlY‏
}}}
First comes the instance Id, then the *`radamsa`* 
[http://code.google.com/p/ouspg/wiki/Radamsa seed], that allows reproducing the files that caused the crash.
===message===
The message contains a call stack for the crash, for instance:
{{{
	base::debug::StackTrace::StackTrace() [0x82aea40]
	base::(anonymous namespace)::StackDumpSignalHandler() [0x8295778]
	0xb7801400
	WebCore::AppendNodeCommand::doApply() [0x8c8ecd2]
	WebCore::CompositeEditCommand::applyCommandToComposite() [0x8bf801a]
	WebCore::CompositeEditCommand::appendNode() [0x8bfa2c2]
	WebCore::CompositeEditCommand::cloneParagraphUnderNewElement() [0x8bff0fb]
	WebCore::CompositeEditCommand::moveParagraphWithClones() [0x8bff662]
	WebCore::IndentOutdentCommand::indentIntoBlockquote() [0x89c4682]
	WebCore::ApplyBlockElementCommand::formatSelection() [0x8be999a]
	WebCore::IndentOutdentCommand::formatSelection() [0x89c73eb]
	WebCore::ApplyBlockElementCommand::doApply() [0x8be6687]
	WebCore::CompositeEditCommand::apply() [0x8bf69f7]
	WebCore::executeIndent() [0x89b03ef]
	WebCore::Editor::Command::execute() [0x89b34e3]
	WebCore::Document::execCommand() [0x81dd7d5]
	WebCore::DocumentInternal::execCommandCallback() [0x8f5bc48]
	v8::internal::Builtin_HandleApiCall() [0x83e987a]
}}}
_Note:_ This crash example comes from [http://code.google.com/p/chromium/issues/list Google Chromium defect database] and is bundled with the *`DumpRenderTree`* build.
==cloudrun metric==
During its execution, cloudrun logs the number of iteration performed.
This number is uploaded periodically to AWS !CloudWatch, as the *cloudrun* metric.

You can view the metric, via the [http://docs.amazonwebservices.com/AmazonCloudWatch/latest/GettingStartedGuide/ViewGraphs.html CloudWatch tab] on the AWS Management console.

For instance here is a log of 6 instances, running over 3 hours
https://docs.google.com/drawings/pub?id=1CJneWYdsZUpLCzvFB54JvBkyBRnzZb5hBGPuo1nKnkc&w=960&h=720&type=image.png
_Note:_ This is a mix of micro, small and High CPU medium instances, hence the wide variations in parformance
=Login to AWS EC2 instance=
If you login to an instance, you will see the following scripts in the ubuntu home directory:
{{{
bootstrap.sh
run.sh
check.sh
}}}
the bootstrap job should be stopped and the run job should be running, you can check that with a:
{{{
sudo initctl list
}}}
you can then check how many test runs have been executed since start
{{{
cat /tmp/iterN
}}}
you can take over manually, first stop the run job:
{{{
sudo stop run
}}}
then you can manually re-run `bootstrap.sh` and `run.sh`.

run.sh comes with a few parameters, a useful one is:
{{{
run.sh loop 10 log
}}}
this will run 10 tests and generate a png image (in the `/tmp` directory) of the rendered page, to satisfy you that *`DumpRenderTree`* works ok. 

You can also check various library functions, using `check.sh`.

Also, many options are configurable via `/etc/taskenv.sh`.

=Running in a kvm environment=
It is possible to [https://help.ubuntu.com/community/UEC/Images#Ubuntu_Cloud_Guest_images_on_Local_Hypervisor_Natty_onward run ubuntu EC2 AMI on kvm], this actually saved me a lot of time, during development.

You can generate an initialisation file for kvm, with:
{{{
make kvmpng
}}}
or
{{{
make kvmcss
}}}
However, before doing so, you must customise the scripts and makefile:
{{{
kvm/boothook.sh
kvm/cloudenv.sh
kvm.mk
}}}
_Note:_ The customisation is mainly about adding a 'kvmhost' to your instance `/etc/hosts`.
This allows the kvm instance to boot faster by fetching binaries from a local Apache web server and to cache required apt-get packages, through [http://www.unix-ag.uni-kl.de/~bloch/acng/ apt-cacher-ng].

You can start the kvm instance with:
{{{
make -f kvm.mk
}}}
=!DumpRenderTree builds=
These are stored in AWS S3, their location is defined in the `taskenv.sh` files, there is a 32 and 64 bits variant.
The bucket that contains them is only visible to identified account.
Furthermore, the bucket is set to: [http://docs.amazonwebservices.com/AmazonDevPay/latest/DevPayDeveloperGuide/S3RequesterPays.html "requester-pay"], which means that the download is billed to the downloader (you), not the S3 bucket owner (me).

_Note:_ It does not matter in that case, as Amazon offers up to 15G per month as part of their [http://aws.amazon.com/ec2/pricing/ Free Tier], but I want the code to cope with higher level of use in the future.

I will keep the *`DumpRenderTree`* build at this location reasonably current, i.e. regenerated every month, depending on the level of interest.
_Note:_ Builds were generated as per [http://dev.chromium.org/developers these procedures], I only build the Release *`DumpRenderTree`*: i.e.

Setup gyp params:
{{{ 
./build/gyp_chromium -Doptimise=speed 
}}}
Make command:
{{{
make -j16 BUILDTYPE=Release DumpRenderTree
}}}

The build archive file contains a manifest with full details.
=FAQs=
===So how many crashes you've found===
None yet :)
===Why did you do this?===
I have a long lasting interest in the matter, my previous job at Symbian and then Nokia, was deploying large scale dynamic and static analysis solutions.

That involved evaluating OSS and commercial products and deploying them automatically and consistently to many teams, in various countries.

Cloud computing is ideal for this use case and I wanted to make a not too trivial proof of concept.
I'm publishing the code, in the hope that it helps others who want to get started with EC2.
===I am interested in using AWS EC2, but my use case is unrelated to testing===
I believe that this code constitutes a lightweight, yet useful framework that can be repurposed with minimal effort and save you time.
See the [CloudrunWalkthrough code walkthrough].
===I know nothing about this cloud computing thing? how does it all work?===
I'd suggest to start reading through the links below. Also a nice series of architecture diagrams at: http://aws.amazon.com/architecture/.
===What is this fuzzing stuff?===
It is a fairly powerful testing technique, please start with the [http://en.wikipedia.org/wiki/Fuzzing wikipedia article].
===But there are lots of fuzzer, why chose radamsa?===
Because, while employed by Symbian and then Nokia, I worked a lot with [http://www.codenomicon.com/ codenomicon] and their product is related to work done at [http://www.codenomicon.com/company/ OUSPG] and I have a bit of nostalgia visiting my ex-Nokia colleagues in Oulu, especially in winter :)
===Why chose !DumpRenderTree as a target?===
Mainly because OUSPG already demonstrated [http://dev.chromium.org/Home/chromium-security/hall-of-fame outstanding results] fuzzing Google chrome with *`radamsa`*. 

Also, I wanted binaries for which the build procedure was well documented.
===Can I snapshot my instance and create an ebs AMI?===
That should work, I tested that early on. But I don't plan to support this requirement.
 # I prefer to keep track of my configurations as version controlled files, rather than ebs volumes.
 # The startup is in most case under 1 minute, so booting from an ebs volume doesn't save me anything.
 # I prefer to use instance store, because it is cheaper.
===Is this Ubuntu specific?===
There are a few assumption about a 'ubuntu' account existing on the instance, grep 'ubuntu' to find them.
Other than that, cloudinit needs to be installed on the instance.
It should run on a debian instance or !RedHat, CentOS, but this is untested yet.
=Useful Links=
 * Amazon Web Services http://aws.amazon.com/ 
 * Getting Started with Amazon EC2 http://docs.amazonwebservices.com/AWSEC2/latest/GettingStartedGuide/Welcome.html?r=7010
 * AWS Documentation http://aws.amazon.com/documentation/
 * Programming Amazon Web Services http://shop.oreilly.com/product/9780596515812.do
 * Python and AWS Cookbook http://shop.oreilly.com/product/0636920020202.do
 * cloud-init is the Ubuntu package that handles early initialization of a cloud instance. https://help.ubuntu.com/community/CloudInit
 * Ubuntu cloud portal http://cloud.ubuntu.com/ami/
 * Ubuntu Cloud Guest images on Local Hypervisor https://help.ubuntu.com/community/UEC/Images
 * boto library http://boto.readthedocs.org/en/latest/index.html
 * boto library author blog http://www.elastician.com/
 * Ubuntu on Amazon EC2 http://alestic.com/
 * debian AWS EC2 images http://wiki.debian.org/Cloud/AmazonEC2Image#preview
 * Linux upstart cookbook http://upstart.ubuntu.com/cookbook/
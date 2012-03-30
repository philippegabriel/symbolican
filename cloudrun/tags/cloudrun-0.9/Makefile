# Create EC2 or KVM User Data Instance, for cloud-init
# See: https://help.ubuntu.com/community/CloudInit
# depends on the package: cloud-init
#
.PHONY :  ec2png ec2css kvmpng kvmcss clean check.boto
#
#Generic to all tasks and environment
#
#cloud config
CONFIG 	= config/cloud-config.txt
#part-handler
PH			=	part-handler/part-handler.py
#upstart conf files
UPSTART 	= 	upstart/Xvfbd.conf upstart/bootstrap.conf upstart/run.conf
#utility libraries
LIBS		= 	libs/AWSSNSPublish.py libs/AWSCloudWatchPutMetricData.py libs/AWSS3GenURL.py \
				libs/InstanceID.sh libs/notify.sh libs/cnt2TS.sh libs/putmetricIterN.sh 
USERCFG	=	config/.boto config/.crontab
#README File
PLAIN		= README 
#
#Task specific Part
#
PNGSCRIPT= png_radamsa/bootstrap.sh png_radamsa/run.sh png_radamsa/check.sh
PNGSYSCFG= png_radamsa/taskenv.sh 
CSSSCRIPT= css_radamsa/bootstrap.sh css_radamsa/run.sh css_radamsa/check.sh
CSSSYSCFG= css_radamsa/taskenv.sh 
#
#Environment specific part
#
#KVM env specific setup
KVMBOOTHOOK	= kvm/boothook.sh
KVMSYSCFG 	= kvm/cloudenv.sh
#No EC2 env specific
#
#Add Mime suffixes for input to Cloudinit mime tool
#And processing by part-handler.py
CONFIGwM		= $(addsuffix :text/cloud-config, $(CONFIG))
PHwM			= $(addsuffix :text/part-handler, $(PH))
UPSTARTwM	= $(addsuffix :text/upstart-job, $(UPSTART))
LIBSwM		= $(addsuffix :text/libs, $(LIBS))
PLAINwM		= $(addsuffix :text/plain, $(PLAIN))
PNGSCRIPTwM = $(addsuffix :text/script, $(PNGSCRIPT))
PNGSYSCFGwM = $(addsuffix :text/systemcfg, $(PNGSYSCFG))
CSSSCRIPTwM = $(addsuffix :text/script, $(CSSSCRIPT))
CSSSYSCFGwM = $(addsuffix :text/systemcfg, $(CSSSYSCFG))
USERCFGwM	= $(addsuffix :text/usercfg, $(USERCFG))
KVMSYSCFGwM = $(addsuffix :text/systemcfg, $(KVMSYSCFG))
KVMBOOTHOOKwM = $(addsuffix :text/cloud-boothook, $(KVMBOOTHOOK))


#
#Check user-data script elements
%.py.ok: %.py
	python -m py_compile $<
%.conf.ok: %.conf
	init-checkconf $<
	touch $@
	sleep 1 #init-checkonf fails if called again too soon
%.sh.ok: %.sh
	bash -n $<
	dash -n $<
#check .boto is filled
check.boto:
	@test `grep -c 'INSERT' config/.boto` -eq 0  || { echo 'config/.boto file contains no credentials' ; false ; }
check: $(addsuffix .ok, $(shell ls ./*/*.py) $(shell ls ./*/*.sh) $(shell ls ./upstart/*.conf)) check.boto

#Generate EC2 User Data multimime file
#See https://help.ubuntu.com/community/CloudInit
ec2png: check
	write-mime-multipart --gzip --output=userdata-cloud-init.ec2png.txt.gz \
				$(CONFIGwM) $(PHwM) $(UPSTARTwM) $(LIBSwM) $(PLAINwM) $(PNGSCRIPTwM) $(USERCFGwM) $(PNGSYSCFGwM)

ec2css: check
	write-mime-multipart --gzip --output=userdata-cloud-init.ec2css.txt.gz \
				$(CONFIGwM) $(PHwM) $(UPSTARTwM) $(LIBSwM) $(PLAINwM) $(CSSSCRIPTwM) $(USERCFGwM) $(CSSSYSCFGwM)

#Genrate KVM User Data multimime file
#See: https://help.ubuntu.com/community/UEC/Images#Ubuntu_Cloud_Guest_images_on_kvm_Hypervisor_Natty_onward
#Note this is dependent on your kvm setup
#Generate KVM specific User Data multimime file
#See https://help.ubuntu.com/community/CloudInit
#Note mime type shouldn't be interspersed, i.e. $(PNGSYSCFGwM) $(KVMSYSCFGwM) must follow each others
kvmpng: check
	write-mime-multipart --output=userdata-cloud-init.kvm.txt \
				$(CONFIGwM) $(PHwM) $(UPSTARTwM) $(LIBSwM) $(PLAINwM) $(PNGSCRIPTwM) \
				$(USERCFGwM) \
				$(PNGSYSCFGwM) $(KVMSYSCFGwM) \
				$(KVMBOOTHOOKwM)

kvmcss: check
	write-mime-multipart --output=userdata-cloud-init.kvm.txt \
				$(CONFIGwM) $(PHwM) $(UPSTARTwM) $(LIBSwM) $(PLAINwM) $(CSSSCRIPTwM) \
				$(USERCFGwM)  \
				$(CSSSYSCFGwM) $(KVMSYSCFGwM) \
				$(KVMBOOTHOOKwM)

clean:
	rm -f libs/*.pyc
	rm -f ./upstart/*.ok
	rm -f userdata-cloud-init.*
	
	
	


	
	
	
	
	
	




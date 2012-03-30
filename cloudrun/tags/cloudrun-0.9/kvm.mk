# 
# package user-data into an ISO file
# and starts a KVM ubuntu cloud image
# depends on the package: cloud-init
#See: https://help.ubuntu.com/community/UEC/Images#Ubuntu_Cloud_Guest_images_on_kvm_Hypervisor_Natty_onward
#
.PHONY : iso blankiso img run clean

all: iso img run

#Change these paths according to your setup
# Location of cloud-init package
CLOUDINIT=../../cloud-init
#iso image for kvm
BASEIMG=../img/ubuntu-11.10-server-cloudimg-i386-disk1.img
#result image produced by qemu-img create
DELTAIMG=../img/delta.img
iso:
#Package user-data in an iso for testing ubuntu Cloud img with kvm
	rm -f ovftransport.iso
	$(CLOUDINIT)/doc/ovf/make-iso $(CLOUDINIT)/doc/ovf/ovf-env.xml.tmpl userdata-cloud-init.kvm.txt

blankiso:
#minimal user data
	rm -f ovftransport.iso
	$(CLOUDINIT)/doc/ovf/make-iso $(CLOUDINIT)/doc/ovf/ovf-env.xml.tmpl $(CLOUDINIT)/doc/ovf/user-data

img:
	rm -f $(DELTAIMG)
	qemu-img create -f qcow2 -b $(BASEIMG) $(DELTAIMG)

run:
#Start kvm 
	sudo /etc/init.d/apt-cacher-ng restart
#	sudo restart squid
	echo 'Log in with login:ubuntu and (if prompted) password:pass'
#Memory amount set same as EC2 micro-instance
#	kvm -cpu host -serial file:kvmlog -drive file=$(DELTAIMG),if=virtio -cdrom ovftransport.iso -m 613 -net nic -net user,hostfwd=tcp::2222-:22 &
	sudo kvm  -cpu host -serial file:kvmlog -drive file=$(DELTAIMG),if=virtio -cdrom ovftransport.iso -m 613 -net nic,model=virtio -net tap &
	sleep 1
	tail --pid="`ps -o pid= -C kvm`" -f kvmlog

clean:
	rm -f *.iso
	rm -f kvmlog
	
	
	


	
	
	
	
	
	




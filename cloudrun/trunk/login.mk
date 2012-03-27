loginaf:
	ssh -i ~/.ssh/awskey.pem ubuntu@ec2-176-34-197-9.eu-west-1.compute.amazonaws.com
loginx64:
	ssh -i ~/.ssh/awskey.pem ubuntu@ec2-46-137-0-182.eu-west-1.compute.amazonaws.com
login5b:
	ssh -i ~/.ssh/awskey.pem ubuntu@ec2-46-137-133-10.eu-west-1.compute.amazonaws.com
fetch:
	scp -i ~/.ssh/awskey.pem ubuntu@ec2-46-51-158-228.eu-west-1.compute.amazonaws.com:/mnt/chromium/src/out/Release/DRT.linux.64.rel@r127423.tar.gz  DRT.linux.64.rel@r127423.tar.gz
fetchpnglog:
	scp -i ~/.ssh/awskey.pem ubuntu@ec2-176-34-76-91.eu-west-1.compute.amazonaws.com:/home/ubuntu/pngs.tar.gz  ./pngs.tar.gz
put:
	scp -i ~/.ssh/awskey.pem ./png_radamsa.tar.gz ubuntu@ec2-46-137-151-174.eu-west-1.compute.amazonaws.com:/home/ubuntu/png_radamsa.tar.gz
putcrash:
	scp -i ~/.ssh/awskey.pem ./crash.html.tar.gz ubuntu@ec2-46-137-151-174.eu-west-1.compute.amazonaws.com:/home/ubuntu/crash.html.tar.gz
put2:
	scp -i ~/.ssh/awskey.pem /home/phil/projects/scan/chromium/DRT.linux.64.rel@127423.tar.gz ubuntu@ec2-46-137-151-174.eu-west-1.compute.amazonaws.com:/home/ubuntu/DRT.linux.64.rel@127423.tar.gz
	
	
	


	
	
	
	
	
	




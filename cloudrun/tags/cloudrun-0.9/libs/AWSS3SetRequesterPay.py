#!/usr/bin/python
#Once the Chromiu build is uploaded to AWS S3, its "Bucket" need to be set to: request payer, 
#i.e. download of S3 object is billed to downloader, not bucket owner
#See: http://docs.amazonwebservices.com/AmazonDevPay/latest/DevPayDeveloperGuide/S3RequesterPays.html
#It is not possible to do through the AWS Management Console, instead must be done with this script.
#Note that boto >= 2.0 need to be used
import sys
def main():
    try:
        import boto
        conn = boto.connect_s3()
        bucket = boto.s3.bucket.Bucket(connection=conn, name="chromiumbuilds")
        result=bucket.set_request_payment(payer='Requester')
        print result
    except:
    # All uncaught exceptions come here
        print sys.argv[0],'SNS Publish Failed, with exception:', sys.exc_info( )[0], sys.exc_info( )[1]

if __name__ == '__main__': 
    main() 


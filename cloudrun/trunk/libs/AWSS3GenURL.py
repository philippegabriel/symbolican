#!/usr/bin/python
import sys
def checkVersion():
    try:
        import boto
    except:
        sys.stderr.write(sys.argv[0]+' FAILED Cannot import boto library\n')
        sys.exit(1)
    if boto.Version < '2.0':
        sys.stderr.write(sys.argv[0]+' FAILED Need at least boto version 2.0\n')
        sys.exit(1)

def main():
    checkVersion()
#Parse params        
    try:
        (bucketID,keyID) = (sys.argv[1],sys.argv[2])
    except:
        sys.stderr.write(sys.argv[0]+' Insuficient number of arguments\n'+'Usage:\n'+sys.argv[0]+' S3bucket S3key\n')
        sys.exit(1)
    try:
        import boto
        conn = boto.connect_s3()
        bucket = boto.s3.bucket.Bucket(connection=conn, name=bucketID)
        key = boto.s3.key.Key(bucket, keyID)
#Assumes the Bucket acl is set to request payer, i.e. download of S3 object is billed to downloader, not bucket owner
#See: http://docs.amazonwebservices.com/AmazonDevPay/latest/DevPayDeveloperGuide/S3RequesterPays.html
        request=key.generate_url(300, method='GET', query_auth=True,force_http=True,headers={'x-amz-request-payer': 'requester'})
#output resulting URL to stdout        
        print request
    except:
    # All uncaught exceptions come here
        sys.stderr.write(sys.argv[0]+' FAILED, with Exception:'+sys.exc_info()[0]+sys.exc_info()[1]+'\n')
        sys.exit(1)
    sys.exit(0)

if __name__ == '__main__': 
    main() 


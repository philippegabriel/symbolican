#!/usr/bin/python
#Calls AWS SNS Publish api through the boto library
#AWS Docs: http://aws.amazon.com/documentation/sns/
#Boto library: http://boto.readthedocs.org/en/latest/index.html
#Boto config file: http://code.google.com/p/boto/wiki/BotoConfig
import sys
def main():
    try:
        import boto.sns
#fetch debug config        
        try:
            debug=boto.config.getint('Boto', 'debug')
        except:
            debug=0
#Parse params        
        try:
            (subject,message) = (sys.argv[1],sys.argv[2])
        except:
            print sys.argv[0],'Insuficient number of arguments\n','Usage:\n',sys.argv[0],' subject message'
            sys.exit(1)
        if debug:
            print sys.argv[0],' calling SNS Publish with subject=[',subject,'] Message=[',message,']'
#Fetch params from $HOME/.boto config file 
        try:
            region_name = boto.config.get('Boto','region_name')
            region_endpoint = boto.config.get('Boto','sns.region_endpoint')
            topic = boto.config.get('Boto','sns.topic')
        except:
            print sys.argv[0],'region_name,sns.region_endpoint,sns.topic missing from .boto file '
            sys.exit(1)
        if debug:
            print 'from .boto config file: region_name:[',region_name,'] region_endpoint:[',region_endpoint,'] topic:[',topic,']'
#        assert  False , 'Breakpoint...'
        if boto.Version == '2.0':
#See: https://github.com/boto/boto/issues/361
            from boto.sdb.regioninfo import SDBRegionInfo
            region = SDBRegionInfo(None, region_name, region_endpoint)
        else:
            region = boto.sns.get_region(region_name)
        conn = boto.connect_sns(region=region)
        result = conn.publish(topic,message,subject)
        if debug:
            print result
    except:
    # All uncaught exceptions come here
        print sys.argv[0],'SNS Publish Failed, with exception:', sys.exc_info( )[0], sys.exc_info( )[1]

if __name__ == '__main__': 
    main() 


#!/usr/bin/python
#
#Calls AWS cloudwatch PutMetricData api through the boto library
#AWS Docs: http://aws.amazon.com/documentation/cloudwatch/
#Boto library: http://boto.readthedocs.org/en/latest/index.html
#Boto config file: http://code.google.com/p/boto/wiki/BotoConfig
#
import sys
def main():
    try:
        import boto
        try:
            debug=boto.config.getint('Boto', 'debug')
        except:
            debug=0
#Fetch arguments
        try:
            (instanceID,namespace,task,metric,value) = (sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5])
        except:
            print sys.argv[0],'Insuficient number of arguments\n','Usage:\n',sys.argv[0],' InstanceID namespace task metric value'
            sys.exit(1)
        if debug:
            print sys.argv[0],'Cloudwatch Publish with instanceID=[',instanceID,'] namespace=[',namespace,'] task=[',task,'] metric=[',metric,'] value=[',value,']'
#Publish the metric on cloudwatch
        cw = boto.connect_cloudwatch()
        result=cw.put_metric_data(namespace,metric,value,dimensions={'InstanceID':instanceID,'Task':task})
        if debug:
            print result
    except:
    # All uncaught exceptions come here
        print sys.argv[0],'Failed, with exception:', sys.exc_info( )[0], sys.exc_info( )[1]
	
if __name__ == '__main__': 
    main() 


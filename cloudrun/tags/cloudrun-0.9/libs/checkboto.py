#!/usr/bin/python
#Check that boto library is installed and is at least version 2.0
import sys
def main():
    try:
        import boto
    except:
        print sys.argv[0],'FAILED Cannot import boto library'
        sys.exit(1)
    if boto.Version <= '2.0':
        print sys.argv[0],'FAILED Need at least boto version 2.0'
        sys.exit(1)
if __name__ == '__main__': 
    main() 


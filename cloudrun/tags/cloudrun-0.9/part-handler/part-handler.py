#part-handler
# vi: syntax=python ts=4
#See : http://bazaar.launchpad.net/~cloud-init-dev/cloud-init/trunk/annotate/head:/doc/examples/part-handler.txt

def list_types():
    # return a list of mime-types that are handled by this module
    return(["text/script","text/libs","text/usercfg","text/systemcfg","text/plain"])

def handle_part(data,ctype,filename,payload):
    # data: the cloudinit object
    # ctype: '__begin__', '__end__', or the specific mime-type of the part
    # filename: the filename for the part, or dynamically generated part if
    #           no filename is given attribute is present
    # payload: the content of the part (empty for begin or end)
    if ctype == "__begin__":
        return
    if ctype == "__end__":
    #   print "part-handler is ending"
       return
    print "==== received ctype=%s filename=%s ====" % (ctype,filename)
    import os
    #find homedir,uid,gid for user
    from pwd import getpwnam
    (name,null,uid,gid,null,homedir,null)=getpwnam('ubuntu')
    if ctype == "text/libs":
        target = '/usr/local/bin/'+filename
        perm=0555
    elif ctype == "text/systemcfg":
        target = '/etc/'+filename
        perm=0666    
    elif ctype == "text/script":
        target = homedir+'/'+filename
        perm=0777    
    else:
        target = homedir+'/'+filename
        perm=0666    
    f = open(target,'w')
    f.write(payload)
    f.close()
    os.chmod(target,perm)
    print "Created file:%s" % (target)
    if ctype == "text/script" or ctype == "text/usercfg":
        os.chown(target,uid,gid)
        print "chown to user:%s uid:%s gid:%s" % (name, uid, gid)





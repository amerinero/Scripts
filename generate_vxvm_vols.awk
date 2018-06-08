#!/usr/xpg4/bin/awk -f
BEGIN { }
{
    GRUPO=$1
    VOLNAME=$2
    SIZE=$3
    MOUNT=$4

    VOLPHYSPATH="/dev/vx/rdsk/"GRUPO"/"VOLNAME
    VOLLOGIPATH="/dev/vx/dsk/"GRUPO+"/"VOLNAME
    FSTAB="/etc/vfstab.newlines"

    print "vxassist -g",GRUPO,"make",VOLNAME,SIZE"m"
    print "mkfs -F vxfs",VOLPHYSPATH
    print "echo \""VOLLOGIPATH,VOLPHYSPATH,MOUNT,"vxfs","2","yes -\" >>",FSTAB
    print "mkdir -p",MOUNT
    print "mount",MOUNT
    print ""

}

END { }

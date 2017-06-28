#!/bin/sh
VERSION=7.60
UPDATES="
#########################################################################################################
#	HDS Global Contact Center (GSC) Universal GetConfig  Data Collection Script 			#
#													#
#	UNIX OS Platforms Supported:									#
#                       Solaris, HP-UX, AIX, Tru64, Linux (RedHat/Suse),Vmware				#
#													#
#	*note: All versions unless otherwise stated.							#
#													#
#	The output of this script is intended to be used by Hitachi Data Systems GSC personnel		#
#	to aid in troubleshooting customer issues.							#	
#													#
#	:LEGAL STUFF											#
#	This HDS Data Collection Tool ("GetConfig") is provided AS IS, with no warranty of any kind. 	#
#	Neither Hitachi Data Systems (HDS) nor Hitachi, Ltd. warrants or represents this tool.		#
#	HDS and Hitachi, Ltd. disclaim all express and implied warranties , including the implied	#
#	warranties of merchantability, fitness for a particular purpose and non-infringement. You are 	#
#	wholly responsible for your use of this tool and the results of such use. Neither HDS nor	#
#	Hitachi, Ltd. shall be liable for any damages, direct, indirect, incidental, special, 		#
#	consequential or otherwise for the information, your use of the information or the result of 	#
#	such use.											#
#########################################################################################################
#   	:CREATED 8/1/2005   by Ben.Patridge@hds.com for Hitachi Data Systems 				#
#       Update comments go back 4 months from the latest update.					#	
#													#
#   	:RECENT UPDATES											#
#       10/16/2008  Ben.Patridge@hds.com - Added multipath, dmsetup and udevinfo, and fixed HPUX     	#
#     					   HDS DiskInfo output v7.53)					#
#       11/26/2008  Ben.Patridge@hds.com - Added arch -k to determine solaris HW architecture   (V7.54) #
#       03/31/2010  Ben.Patridge@hds.com - Removed /etc/passwd  /etc/group,fixed emulex hbanyware	#
#       				   data collection. Added multipath commands (linux) and 	#
#       				   dmsetup commands. copy all /proc/scsi/scsi files (linux)	#
#       				   gather errno.h(aix), and added several vio commands.		#
#       				   added ioscan -m dsf (hpux) and what /usr/lbin/cmcld. (v7.55) #
#       04/20/2010  Ben.Patridge@hds.com - Added additional AIX Commands (lsdev -virtual)		# 
#       				   (ioscli ioslevel) (ioscli lsmap -all)(v7.56)			#
#       05/11/2010  Ben.Patridge@hds.com - Added luxadm inquiry on all disks in /dev/rdsk 		#
#       				   and /devices (v7.5.7)							#
#########################################################################################################
";
#################################################################################
#CHECK TO ENSURE ROOT IS RUNNING THE GETCONFIG
#################################################################################
login_id=`id |  cut -f2 -d "(" | cut -f1 -d")"`
if [ "$login_id" != "root" ]
then
	echo "Only the root user can execute this script"
	exit 1
fi
#################################################################################
# INITIALIZE SOME GLOBAL VARIABLES
#################################################################################
max_case_length=14
min_case_length=8
PATTERN='^(HDS|hds|SD|EUC|sd|euc)[0-9]'
if [ -f /tmp/.setx ]; then
 rm -f /tmp/.setx >/dev/null 2>&1
fi
PATH=/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/bin:$PATH
#################################################################################
#README FUNCTION
#################################################################################
README()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

echo "

VERSION=$VERSION
${UPDATES}

GetConfig is specifically designed to be non-intrusive.
It will not impact system performance as even on slow systems it only take between 1 & 10 minutes to run.
It will only take longer if you have large HSSM, HTnM or HDvM logs.

##################################################################
GETCONFIG INSTRUCTIONS
##################################################################
# SILENT (NO OPTION) MODE
##################################################################

# ./getcfg <casenumber> -s  <output destination>

*note: 
<casenumber> is the HDS case number including prefix
-s is for silent mode 
<output destination> is optional. If not specified /tmp is used.

In silent Mode, ALL defaults are accepted

##################################################################
# SILENT (NO OPTION) VERBOSE MODE
##################################################################

# ./getcfg <casenumber> -s -v <output destination>  >/tmp/output.txt 2>&1 &

*note: 
<casenumber> is the HDS case number including prefix
-s is for silent mode 
-v is for verbose mode 
<output destination> 	is the destination directory


You may use any combination (-sv) or (-vs) 
It is strongly advised to add the >/tmp/output.txt 2>&1 & to capture
the output and run the script in the background when running it with the 
verbose option.

You may also leave out the mode flags to specify only an output 
destination

For example:

# ./getcfg <casenumber>  <output destination>  


This way you may run

# tail -f /tmp/output.txt 

to view the results real-time while the getconfig completes.


##################################################################
# DEFAULT OPTION MODE
# *note: [] means accept the default option. Press <enter> 
##################################################################
/tmp> #./getcfg

##################################################################
GSC GetConfig Data Collection Script version 7.15
##################################################################
Display README? [n]:
Enter your case number including HDS SD or EUC prefix : HDS00003640
Specify path to save getconfig data [/tmp]:
Display additional options? [n]:
##################################################################
Gathering standard system files .........
Gathering process information .....
Gathering additional system information ......
Gathering Platform Information and Control Library info ....
Gathering list of /usr/lib & /usr/local/lib files ...
Gathering error logs .......
Gathering dmesg log ...
...

##################################################################
# ADDITIONAL OPTIONS
# *note: [] means accept the default option. Press <enter> 
##################################################################
/tmp> #./getcfg

##################################################################
 GetConfig Data Collection Script version 7.15
##################################################################
Display README? [n]:
Enter your case number including  HDS SD or EUC prefix : HDS00003640
Specify path to save getconfig data [/tmp]:
Display additional options? [n]: y
>Verbose mode? (*note: output is sent to screen) [n]: y
>Display Excludes? [n]: y
>>Exclude hdvm from getconfig? [n]:
>>Exclude htnm from getconfig? [n]:
>>Exclude hssm from getconfig? [n]:
>>Exclude hdlm from getconfig? [n]:
>>Exclude veritas from getconfig? [n]:
>>Exclude hitrack from getconfig? [n]:
>>Exclude horcm from getconfig? [n]:
>>Exclude rapidx from getconfig? [n]:
##################################################################
Gathering standard system files .........
Gathering process information .....
Gathering additional system information ......
Gathering Platform Information and Control Library info ....
Gathering list of /usr/lib & /usr/local/lib files ...
Gathering error logs .......
Gathering dmesg log ...
...


##################################################################

: LEGAL STUFF
This HDS Data Collection Tool ("GetConfig") is provided AS IS, with no warranty of any kind. Neither Hitachi Data Systems (HD
S) nor Hitachi, Ltd. warrants or represents the content of this tool. HDS and Hitachi, Ltd. disclaim all express and implied
warranties , including the implied warranties of merchantability, fitness for a particular purpose and non-infringement. You
are wholly responsible for your use of this tool and the results of such use. Neither HDS nor Hitachi, Ltd. shall be liable f
or any damages, direct, indirect, incidental, special, consequential or otherwise for the information, your use of the inform
ation or the result of such use.
##################################################################

"|more;
echo ""
}
#################################################################################
# GET USER INPUT
#################################################################################
# Check arguments
#################################################################################

clear

case_number=$1
option=$2
OUTDIR=$3
if [ -n "$case_number" ]; then 
 if [ "$case_number" = "-sv" ] || [ "$case_number" = "-vs" ] || [ "$case_number" = "-v" ] || [ "$case_number" = "-s" ]; then
  echo "Silent Mode usage: ./getcfg <casenumber> -s <output destination>"
  exit
 fi
fi

if [ -n "$option" ]; then
  if [ "$option" != "-sv" ] || [ "$option" != "-vs" ] || [ "$option" != "-v" ] || [ "$option" != "-s" ]; then
   if [ ! -d "$OUTDIR" ]; then
    echo "Creating output destination directory [$OUTDIR] ..."
    mkdir "$OUTDIR" >/dev/null 2>&1
     if [ $? != 0 ]; then
      echo "ERROR: Unable to create destination directory [$OUTDIR] ..."
      exit
     fi
   else 
      echo "Using output destination directory [$OUTDIR] ..."
   fi # end if [! -d $OUTDIR]
  fi # end if [$option ....]
  if [ "$option" = "-sv" ] || [ "$option" = "-vs" ] || [ "$verb" = "-v" ]; then
   touch /tmp/.setx
  fi # end if [$option ..]
fi # end if [ -n $option]



g=0 
if [ -n "$case_number" ]; then
while [ $g = 0 ]
 do
  case_nummber=`echo $case_number |sed -e 's/ * *//g'`
  echo $case_number |egrep -i $PATTERN > /dev/null 2>&1
  if [ $? = 0 ]; then
   g=1
  else
   g=0
  fi
  length=`echo $case_number |wc -m`
  if [ $length -lt $min_case_length ] || [ $length -gt $max_case_length ]; then
    g=0
  fi
 
if [ $g = 0 ]; then
  printf "\r"
  echo "##################################################################"
  echo "INVALID CASE NUMBER: [$case_number]"
  echo "Please include the case PREFIX with the case number."
  echo "ex.HDS00003640 SD1234567 [USA/Asia Pacific] or  EUC1234567 [European]"
  echo "##################################################################"
  g=1
  exit
 fi
done

else
  option="-y"
fi

#################################################################################
# BEGIN CHECK TO SEE IF SILENT OPTION IS ENABLED
#################################################################################
if [ "$option" = "-sv" ] || [ "$option" = "-vs" ] || [ "$option" = "-s" ]; then
 echo "##################################################################"
 echo "GSC GetConfig Data Collection Script version $VERSION"
 echo "##################################################################"

else

#-----------------------------------------------------------------------------
#------ ELSE 
#-----------------------------------------------------------------------------
echo "##################################################################"
echo "GSC GetConfig Data Collection Script version $VERSION"
echo "##################################################################"
g=0
while [ $g = 0 ]
do
printf "Display README? [n]: "
read readme
if [ -n "$readme" ]; then
  case "$readme" in
   y|Y)
     README
     g=1
      ;;
   n|N)
     g=1
     ;;
    *)
      g=0
      ;;
  esac
else
 g=1
fi
printf "\r"
done
######################################
g=0 
while [ $g = 0 ]
 do
  printf "Enter your case number including HDS SD or EUC prefix : "
  read case_number
  if [ -n "$case_number" ]; then
         case_nummber=`echo $case_number |sed -e 's/ * *//g'`
         echo $case_number |egrep -i $PATTERN > /dev/null 2>&1
         if [ $? = 0 ]; then
           g=1 
         else
           g=0
         fi
         length=`echo $case_number |wc -m`
         if [ $length -lt $min_case_length ] || [ $length -gt $max_case_length ]; then
           g=0
         fi
      ###########################################################################
  else
   g=0
  fi      		# end if case_number

 if [ $g = 0 ]; then 
  printf "\r"
  echo "##################################################################"
  echo "INVALID CASE NUMBER: [$case_number]"
  echo "Please include the case PREFIX with the case number."
  echo "ex. HDS00003640 SD1234567 [USA/Asia Pacific] or  EUC1234567 [European]"
  echo "##################################################################"
 fi
printf "\r"
done
######################################

g=0
while [ $g = 0 ]
 do
  printf "Specify path to save getconfig data [/tmp]: "
  read OUTDIR
  if [ ! -n "$OUTDIR" ]; then
    OUTDIR=/tmp
    g=1
  else
    if [ -d "$OUTDIR" ]; then
       OUTDIR=`echo $OUTDIR | sed 's/[\/]*$//g' `
      g=1 
    else
      printf "\r"
      printf "[$OUTDIR] Does not exist! Create Directory? [y]: "
      read maked
      if [  -n "$maked" ]; then
       mkdir -p $OUTDIR >/dev/null 2>&1
       if [ -d $OUTDIR ]; then
         g=1
       else 
         g=0
       fi
      else
       g=0
      fi
    fi
  fi
  printf "\r"
 done  

######################################

g=0
options=0
while [ $g = 0 ]
 do
  printf "Display additional options? [n]: "
  read mode
if [ -n "$mode" ]; then
  case $mode in
   y|Y)
     options=1
     g=1
      ;;
   n|N)
     g=1
     ;;
    *)
      g=0
      ;;
  esac
else
 options=0
 g=1
fi
printf "\r"
done
######################################
######################################
if [ $options = 1 ]; then
g=0
while [ $g = 0 ]
 do
  printf ">Verbose mode? (*note:output is sent to screen) [n]: "
  read mode
  if [ -n "$mode" ]; then
   case $mode in
    y|Y)
     touch /tmp/.setx >/dev/null 2>&1
     g=1
      ;;
    n|N)
     g=1
     ;;
    *)
      g=0
      ;;
   esac
  else
   g=1
 fi
printf "\r"
done
fi
######################################
# EXCLUDES
######################################
if [ $options = 1 ]; then
g=0
excludes=0
while [ $g = 0 ]
 do
  printf ">Display Excludes? [n]: "
  read excludes
  if [ -n "$excludes" ]; then
  case $excludes in
   y|Y)
     excludes=1
     g=1
      ;;
   n|N)
     excludes=0
     g=1
     ;;
    *)
      g=0
      ;;
  esac
  else
   excludes=0
   g=1
  fi
printf "\r"
done
fi
######################################

if [ $options = 1 ]; then
if [ $excludes = 1 ]; then
for i in hdvm htnm hssm hdlm veritas hitrack horcm rapidx
do
if [ -f /tmp/.no${i} ]; then
 rm -f /tmp/.no${i} >/dev/null 2>&1
fi
g=0
while [ $g = 0 ]
 do
  printf ">>Exclude $i from getconfig? [n]: "
  read mode
  if [ -n "$mode" ]; then
   case $mode in
    y|Y)
     touch /tmp/./.no${i} >> /dev/null 2>&1
     g=1
      ;;
    n|N)
     g=1
     ;;
    *)
      g=0
      ;;
   esac
  else
   g=1
  fi
  printf "\r"
done			# end while
done   			# end for i in 
fi 			# END IF EXCLUDES 
fi 			# END IF OPTIONS
######################################

g=0
VMONLY=0
uname -a |grep -i vmware |grep -v grep > /dev/null 2>&1
if [ $? = 0 ]; then
while [ $g = 0 ]
 do
  printf "Use VMWARE VMSupport Tool and not GetConfig? [n]: "
  read vmcheck
 if [ -n "$vmcheck" ]; then
  case $vmcheck in
   y|Y)
     VMONLY=1
     g=1
      ;;
   n|N)
     g=1
     ;;
    *)
      g=0
      VMONLY=0
      ;;
  esac
 else
 VMONLY=0
 g=1
 fi
printf "\r"
done

vmcore=0
while [ $g = 0 ]
 do
  printf "Gather VMWare /proc/kcore file? [n]: "
  read vmcore
 if [ -n "$vmcore" ]; then
  case $vmcore in
   y|Y)
     g=1
      ;;
   n|N)
     vmcore=1
     g=1
     ;;
    *)
      g=0
      VMONLY=0
      ;;
  esac
 else
 vmcore=1
 g=1
 fi
printf "\r"
done
fi

#################################################################################
# END IF OPTION
#################################################################################
fi  


#################################################################################
# THIS IS A GOOD STOPPING POINT FOR TESTING
#################################################################################
#exit
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#REMOVING ANY OLD DATA
rm -rf $OUTDIR/getconfig > /dev/null 2>&1
#################################################################################
#################################################################################
#################################################################################
trap '
  echo "* * * CTRL + C Trap Occured * * *"
  echo "Quit? [n] "
  read answer
  if [ -n "$answer" ]; then
   case $answer in
     y|Y)
         if [ -d $OUTDIR/getconfig ]; then
          echo "Cleaning up files in $OUTDIR/getconfig ..."
          rm -rf $OUTDIR/getconfig >  /dev/null 2>&1
          for i in hdvm htnm hssm hdlm veritas hitrack horcm rapidx
           do
            if [ -f /tmp/.no${i} ]; then
             rm -f /tmp/.no${i} >/dev/null 2>&1
            fi
           done
          rm -f /tmp/.setx >/dev/null 2>&1
          echo "Done ..."
          exit 0;
         fi
         ;;
      *)
         echo "Returning ..."
        ;;
    esac
  else
     g=1
  fi
' 1 2

#################################################################################
#################################################################################
# SETTING MAIN VARIABLES AND REATING DIRECTORIES
#################################################################################

#echo "Building directory structure to $OUTDIR ..."
mkdir $OUTDIR/getconfig
mkdir $OUTDIR/getconfig/txt
tmpdir=$OUTDIR/getconfig/txt
mkdir $tmpdir/etc
mkdir $tmpdir/kernel
mkdir $tmpdir/hba
mkdir $tmpdir/disk
mkdir $tmpdir/os_files
mkdir $tmpdir/software
mkdir $tmpdir/performance
mkdir $tmpdir/networking
mkdir $tmpdir/messages
mkdir $tmpdir/not_found
TMPVAR=$OUTDIR/.gcfg
TMPDATE=`date +'%h %d'`
DATE=`date +'%m.%d'`
HOSTNAME=`hostname|tr "[:lower:]" "[:upper:]"`
echo "HOSTNAME=$HOSTNAME"  > $tmpdir/getconfig_v${VERSION}_${HOSTNAME}.txt 2>&1
echo $UPDATES >> $tmpdir/getconfig_v${VERSION}_${HOSTNAME}.txt 2>&1
LINE="----------------------------------------------------------------"; 

#################################################################################
# GETFILES FUNCTION TO RECURSIVELY GET FILES FROM DIRECTORIES
#################################################################################
getfiles()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

if [ ! -d $tmpdir/${2} ]; then
  mkdir  $tmpdir/${2} > /dev/null 2>&1
fi
n=0

ls -Al $1 |grep -v drw |grep -v total |awk '{print $9}' |while read x
do
 cp ${1}/$x $tmpdir/${2}/${x}.txt 2>&1
 n=`expr $n + 1`
 if [ $n = 5 ]; then
  printf "."
  n=0
 fi
done
}
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
# HEADER MESSAGE
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################

#clear
#echo ""
echo "##################################################################"
echo "Gathering data, this process may take between 1 & 10 minutes...."
echo "##################################################################"


#################################################################################
# BUILD WEB PAGE VIEWER
#################################################################################
#echo "Building Web Viewer ..."
mkdir $OUTDIR/getconfig/_web
WEBDIR=$OUTDIR/getconfig/_web
#---------------------------
# BUILD INDEX.HTML
#---------------------------
echo "
<html>
<head>
<title>[$HOSTNAME] - GetConfig $VERSION </title>
</head>
<frameset rows='35,*' border='0'>
  <frame name='banner' scrolling='no'  noresize target='contents' src='_web/top_frame.htm'>
  <frameset cols='230,*' border='0'>
    <frame name='contents' target='main' noresize  src='_web/left_frame.htm'>
    <frame name='main' src='_web/main_frame.htm'>
  </frameset>
  <noframes>
  <body>
  <p>This page uses frames, but your browser doesn't support them.</p>
  <p>Get a real one!</p>
  </body>
  </noframes>
</frameset>
</html>
" > $OUTDIR/getconfig/index.html 2>&1

#---------------------------
# BUILD TOP FRAME
#---------------------------
echo "
<html>
<head>
<title>[$HOSTNAME] - GetConfig $VERSION </title>
<base target='contents'>
</head>
<body>
<body bgcolor='#288EFF' alink='#666666' vlink='#666666' link='#666666'>
 <table border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#000000' width='100%' bgcolor='#288EFF' bordercolordark='#C0C0C0' bordercolorlight='#000000' valign='top'>
<tr><td width='100%' bgcolor='#C0C0C0'>
<font size='4' color='#FF0000'><B>Hitachi Data Systems</b></font><B>&nbsp;-&nbsp;GetConfig Data Collection Script $VERSION for host [<font color='#FFFF00'>$HOSTNAME</font>]</b>
</td></tr>
" > $WEBDIR/top_frame.htm 2>&1
WEBTOP=$WEBDIR/top_frame.htm
#---------------------------
# BUILD MAIN FRAME
#---------------------------
echo "
<html>
<head>
<title>[$HOSTNAME] - GetConfig $VERSION </title>
<base target='_self'>
</head>
<body>
" > $WEBDIR/main_frame.htm 2>&1
WEBMAIN=$WEBDIR/main_frame.htm

#---------------------------
# BUILD LEFT FRAME
#---------------------------
echo "
<html>
<head>
<title>[$HOSTNAME] - GetConfig $VERSION </title>
<base target='main'>
<STYLE type='text/css'>
<!--
A:link    {text-decoration: none; font-weight: normal; color: #666666}
A:visited {text-decoration: none; font-weight: normal; color: #666666}
A:active  {text-decoration: none; font-weight: normal; color: #8833FF}
A:hover   {text-decoration: none; font-weight: normal; color: gold;background-color:#777777;}
-->
</STYLE>
</head>
<body STYLE='scrollbar-base-color: white;scrollbar-face-color: white;scrollbar-arrow-color: dodgerblue;scrollbar-3dlight-color: black;scrollbar-highlight-color: white;scrollbar-shadow-color: black;scrollbar-darkshadow-color: white' bgcolor='#288EFF'>

" > $WEBDIR/left_frame.htm 2>&1
WEBLEFT=$WEBDIR/left_frame.htm
#---------------------------
echo "
<div align='center'>
  <center>
 <table border='2' cellpadding='2' cellspacing='3' style='border-collapse: collapse' bordercolor='#000000' width='100%' bgcolor='#288EFF' bordercolordark='#C0C0C0' bordercolorlight='#000000' valign='top'>
<tr><td width='100%' bgcolor='#C0C0C0'>
" >> $WEBLEFT 2>&1

############################################################################################
############################################################################################
############################################################################################
############################################################################################
############################################################################################
############################################################################################
# CHECK TO DETERMINE WHAT OPERATING SYSTEM (OS)
############################################################################################
############################################################################################
############################################################################################
############################################################################################
############################################################################################
#
OS=`uname -a`
CHECKSUN=`echo $OS | grep -i sunos |wc -l |awk '{print $1}'`
CHECKHP=`echo $OS | grep -i hp-ux |wc -l |awk '{print $1}'`
CHECKAIX=`echo $OS | grep -i aix |wc -l |awk '{print $1}'`
CHECKLIN=`echo $OS | grep -i linux|wc -l |awk '{print $1}'`
CHECKTRU=`echo $OS | egrep -i '(OSF|alpha)' |wc -l |awk '{print $1}'`
CHECKVM=`echo $OS | egrep -i '(vmware|vmnix)' |wc -l |awk '{print $1}'`

if [ $CHECKSUN = 1 ]; then
 SYSOS='sun'
fi

if [ $CHECKHP = 1 ]; then
 SYSOS='hpux'
fi

if [ $CHECKAIX = 1 ]; then
 SYSOS='aix'
fi

if [ $CHECKLIN = 1 ]; then
 SYSOS='linux'
fi

if [ $CHECKTRU = 1 ]; then
 SYSOS='tru64'
fi

if [ $CHECKVM = 1 ]; then
 SYSOS='vmware'
fi

if [ $CHECKSUN = 0 ] && [ $CHECKHP = 0 ] && [ $CHECKAIX = 0 ] && [ $CHECKLIN = 0 ] && [ $CHECKTRU = 0 ] && [ $CHECKVM = 0 ]; then
 echo "Problems retreiving system OS thru uname?"
 exit
fi

##############################################################################################
##################### FUNCTION TO CREATE A WAIT FOR ANY COMMAND ##############################
##############################################################################################
waitfor()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

if [ ! -z $1 ]; then
delay=2 
pid=$1 
printf "(waiting for pid=$1 to complete)"
#Redirect stdout and stderr of the ps command to /dev/null 
ps -ef|awk '{print $2,$3}' |grep -v PP| grep -w $pid 2>&1 > /dev/null 

#Grab the status of the ps command 
status=$? 
#A value of 0 means that it was found running 
if [ "$status" = "0" ] 
then 
        while [ "$status" = "0" ] 
        do 
                sleep $delay 
                ps -ef|awk '{print $2,$3}' |grep -v PP| grep -w $pid 2>&1 > /dev/null 
                status=$? 
                printf "."
        done 

#A value of non-0 means that it was NOT found running 
fi



fi # end if [! -z $1 ]

}
##############################################################################################
##############################################################################################
##############################################################################################
QDepth()
{
if [ -z $1 ]; then
  file="queue_depth.txt"
fi

echo -e"\n
\r======================================================================= \r
Where do you set the Queue Depth?\r
======================================================================= \r
Remember: \r
Solaris:\tThe Queue Depth must be set in /etc/system to: \r\r
\t\ti.e.: set sd:sd_max_throttle= queue_depth \r\r
AIX:\tThe Queue Depth must be set at the hdisk level: \r\r
\t\t using the chdev -l hdisk[num] -a queue_depth=[value] \r
\t\t *note: Requires a reboot for AIX \r\r
HP-UX:\tTo query the queue depth, use the command:\r
\t\t#scsictl -a /dev/rdsk/cxdytz\r\r
\t\tTo set the queue depth, use the command:\r
\t\t#scsictl -m queue depth=2 /dev/rdsk/cxdytz\r\r
Linux:\t(Queue Depth setting varies depending on the HBA)\r
\t\tExample using Qlogic HBA SCLI\r
\t\tQlogic calls Queue Depth -  Execution Throttle\r
\t\t#scli -C ALL \r
\t\tthen, to change the Execution Throttle, use the parameter alias ET:\r
\t\t#scli -N <HBA WWPN>  ET  <desired value>\r
#\r
------------------------------------------------------------------------- \r
DF (MIDRANGE) QUEUE DEPTH CALCULATIONS \r
------------------------------------------------------------------------- \r
[9200]\t\tQueue Depth = 256 / Total number of LUNs defined on the port <= 32\r
[9500V]\t\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
[AMS 200]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
[WMS 100]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
[AMS 500]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
[AMS 1000]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
[WMS 1000]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32\r
\r
-------------------------------------------------------------------------\r
RAID (ENTERPRISE) QUEUE DEPTH CALCULATIONS \r
------------------------------------------------------------------------- \r
[7700E]\tQueue Depth = 256 / Total number of LUNs defined on the port <= 32   \r
[9900]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32   \r
[9900V]\tQueue Depth = 512 / Total number of LUNs defined on the port <= 32   \r
[USP]\tQueue Depth = 1024 / Total number of LUNs defined on the port <= 32   \r
[NSC55]\tQueue Depth = 1024 / Total number of LUNs defined on the port <= 32   \r
[USPV]\tQueue Depth = 2048 / Total number of LUNs defined on the port <= 32  \r
[USPVM]\tQueue Depth = 2048 / Total number of LUNs defined on the port <= 32  \r
 \r
------------------------------------------------------------------------- \r
*note: On HP-UX Systems, Total number of queues per LU must be <= 8 \r
------------------------------------------------------------------------- \r
Total number of queues per LU must not exceed a Queue Depth value of 32 \r
------------------------------------------------------------------------- \r
IMPORTANT CONSIDERATIONS:\r
*When considering the queue depth calculation is is IMPORTANT to consider\r
the total number of LUNS(LUs) connected to the port on the storage. \r
NOT just the total number of LUNs the host can see. \r\r
If you have 100 luns defined on a USP that are presented to 1 solaris host the\r
queue depth would be 10. i.e. 1024 / 100=10.\r
However, if you have 10 Solaris hosts connected to the same port on the USP\r
and each host has a queue depth of 10, then you are OVERQUEUING your port!\r
This is because the queue depth of 10 x 10 hosts = 100. So your queue depth \r
to the port on the storage is 100!\r\r

*On solaris the default queue depth is 256!\r\r
*On solaris for the AMS/WMS the sd_io_time must be set as well\r
set in the /etc/system: \r
#\r
set sd:sd_io_time=0x3c \r
#\r
The required I/O time-out value (TOV) for AMS/WMS is 60 seconds (0x3C) \r
which is also the default TOV value. If the I/O TOV has been changed from \r
been changed from the default, you must change it back to 60 seconds \r
------------------------------------------------------------------------- \r
EXAMPLES:\r
* Example (1)  \rIf the user has configured a total of 2 LUNs to\r
port -0B- on a 9570, the equation would be:\r
Queue Depth= 512 /2 = 256 \r
However, because 256 is NOT <= 32 you would set the Queue Depth to 32! \r\r
\r\r
* Example(2) \rIf the user has configured a total of 2 LUNs to\r
port -0A- on a 9570, the equation would be:\r
Queue Depth= 512 /67 = 7.6 (always round down to the next EVEN integer).\r\r

" >>$tmpdir/kernel/$1>&1
}

##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################

QDepthReadme()
{
echo -e "\n
======================================================================= \r
What is Command TAG Queuing?\r
======================================================================= \r
SCSI Command Tag Queuing refers to queuing multiple commands to a SCSI device.  \r
Queuing to the SCSI device can improve performance because the device itself \r
determines the most efficient way to order and process commands.\r
\r
======================================================================= \r
How many commands can be queued? \r
======================================================================= \r
RAID:\r
- Each 7700E port can queue up to 256 commands \r
(1024 when in HP-UX Connection mode) \r\r
-Each 9900 port can queue up to 256 commands \r
(1024 when in HP-UX Connection mode)\r\r
-Each 9900V port can queue up to 512 commands \r
(1024 when in HP-UX Connection mode)\r\r
(maximum 256 commands when the port is in loop mode).\r
(The 512 queued commands are shared between the Host Domains, 512 total per\r 
 physical port.)\r\r
-Each TagmaStore port can queue up to 1024 commands. \r
(The 1024 queued commands are shared between the Host Domains, 1024 total per\r
 physical port.)\r\r
\r
MIDRANGE:\r
_Each 9200 port can queue up to 256 commands.\r\r
-Each 9500V port can queue up to 512 commands.\r
(The 512 queued commands are shared between the Host Domains, 512 total per \r
 physical port.)\r\r
-Each AMS/WMS port can queue up to 512 commands.\r
\r
======================================================================= \r
How are queue slots distributed among the LUNs?\r
======================================================================= \r
The number of slots per LUN is dynamic.  The slots are assigned on a first come\r
first serve basis until all the slots within the physical port are used.  On \r
the platforms that support Host Storage Domains ( HSD ), the number of slots \r
per HSD is also dynamic, and each HSD is individually not limited except that\r
the total number of queued commands among all the HSDs defined on a physical \r
port is limited to what the physical port supports.   \r
\r
======================================================================= \r
What happens when all the slots for a port are used?\r
======================================================================= \r
When the queue is full for a port, subsequent commands are rejected with Q_FULL\r
indication. The host needs to retry the command.  In case of HP-UX connection,
BUSY is returned, and the host needs to retry the command.  Performance \r
degradation will occur as the number of host retry operations increase. \r\r

SERIOUS PROBLEMS MAY OCCUR WHEN THE HOST MAXIMUM RETRY COUNT HAS BEEN REACHED\R
AND THE DEVICE ISS TILL RESPONDING Q_FULL!\r\r
\r
======================================================================= \r
Is it possible to have data corruption for having exceeded the queue depth limit?\r
======================================================================= \r
Data corruption has never been experienced by having queue depth exceed limits.\r
\r
======================================================================= \r
Good Practice, Things to watch for:\r
======================================================================= \r
1)  Setup the host driver parameters so that Q_Full does not occur excessively \r
(preferably never). Use the 'Queue Depth' and 'MaxTags'  or equivalent driver\r
parameters to do so.\r
2)  Setup the host driver parameters so that all LUN attached to a port or host \r
domain have the same queue depth.\r
3)  Setup the host driver parameters so that all LUN in a volume group have the\r
same queue depth. \r
4)  When setting driver parameters, consider all host sharing a port or a host \r
domain.\r
\r
======================================================================= \r
Note:  Additional Information for AIX\r
======================================================================= \r
When AIX accesses LUNs with different queue depths attached to the same port, \r
AIX issues a SCSI Mode Select command each time a LUN with a different queue \r
depth is accessed.  \r\r
Although this command does not interfere with the command tag queue, it \r
increments the number of I/Os that need to be executed for the same amount of \r
acutal work, therefore decreasing the performance of the port.  Also read the \r
paragraph 'What happens when all slots for a port are used'. \r

\n" > $tmpdir/kernel/README_queue_depth.txt 2>&1


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/README_queue_depth.txt'><font color='#FF0000'>Queue Depth README</a></td></tr>
 " >> $WEBLEFT 2>&1
}




getEmulex()
{
if [ -d /opt/lpfc/bin ]; then
	echo "Found Emulex HBAs. Gathering info ..."
   $LPUTIL=/opt/lpfc/bin/lputil
   echo "#$LPUTIL version" >> $tmpdir/hba/emulex_lputil.txt 2>&1
   $LPUTIL version >> $tmpdir/hba/emulex_lputil.txt 2>&1
   echo $LINE >> $tmpdir/hba/emulex_lputil.txt 2>&1
   echo "#$LPUTIL listhbas " >> $tmpdir/hba/emulex_lputil.txt 2>&1
   $LPUTIL listhbas  >> $tmpdir/hba/emulex_lputil.txt 2>&1
   printf "."
   echo $LINE >> $tmpdir/hba/emulex_lputil.txt 2>&1
   num=`$LPUTIL count`
   echo "Found $num HBAs" >> $tmpdir/hba/emulex_lputil.txt 2>&1
   echo $LINE >> $tmpdir/hba/emulex_lputil.txt 2>&1
   x=0
   while [ $x -le $num ]
     do
             echo "#$LPUTIL model $num"  >> $tmpdir/hba/emulex_lputil.txt 2>&1
             $LPUTIL model $num  >> $tmpdir/hba/emulex_lputil.txt 2>&1
             echo $LINE >> $tmpdir/hba/emulex_lputil.txt 2>&1
             echo "#$LPUTIL shownodes $num" >> $tmpdir/hba/emulex_lputil.txt 2>&1
             $LPUTIL shownodes $num >> $tmpdir/hba/emulex_lputil.txt 2>&1
             echo $LINE >> $tmpdir/hba/emulex_lputil.txt 2>&1
             echo "#$LPUTIL fwlist $num" >> $tmpdir/hba/emulex_lputil.txt 2>&1
             $LPUTIL fwlist $num >> $tmpdir/hba/emulex_lputil.txt 2>&1
	     x=`expr $x + 1`
	     printf "."
     done
printf "\n"
fi
}



##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
################### ASCII FUNCTION ###########################################################
ascii() {
       case $num in
	30) num=0; ;;
	31) num=1; ;;
	32) num=2; ;;
	33) num=3; ;;
	34) num=4; ;;
	35) num=5; ;;
	36) num=6; ;;
	37) num=7; ;;
	38) num=8; ;;
	39) num=9; ;;
	41) num=A; ;;
	42) num=B; ;;
	43) num=C; ;;
	44) num=D; ;;
	45) num=E; ;;
	46) num=F; ;;
	47) num=G; ;;
	48) num=H; ;;
	49) num=I; ;;
	4A) num=J; ;;
	4B) num=K; ;;
	4C) num=L; ;;
	4D) num=M; ;;
	4E) num=N; ;;
	4F) num=O; ;;
	50) num=P; ;;
	51) num=Q; ;;
	52) num=R; ;;
	53) num=S; ;;
	54) num=T; ;;
	55) num=U; ;;
	56) num=V; ;;
	57) num=W; ;;
	58) num=X; ;;
	59) num=Y; ;;
	5A) num=Z; ;;
	esac
}



##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################




##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
# SUN SOLARIS  FUNCTION
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################

sun()
{

if [ -f /tmp/.setx ]; then
 set -x 
fi
if [ ! -d /opt/FJSVhwr/sbin ]; then

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'><b>GetConfig Term Definitions</b></a></td></tr> " >> $WEBLEFT 2>&1


#--------------------------------------------------------------------
# GATHERING SYSTEM INFO
#--------------------------------------------------------------------
printf "Gathering standard system files ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM INFO</B></td></tr> " >> $WEBLEFT 2>&1
echo "#date" >$tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
printf "."

ver=`uname -r`
os=`uname`
echo "#/bin/uname -a" >> $tmpdir/os_files/uname.txt 2>&1
/bin/uname -a >> $tmpdir/os_files/uname.txt 2>&1
echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
echo "#arch -k" >> $tmpdir/os_files/uname.txt 2>&1
arch=`arch -k`
echo $arch >> $tmpdir/os_files/uname.txt 2>&1
if [ ! -d /usr/platform/$arch ]; then
 arch='sun4u'
fi
echo $arch >> $tmpdir/os_files/arch.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>[OS][Ver.]=[$os][$ver]</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1

echo "#/bin/uptime" >> $tmpdir/os_files/uptime.txt 2>&1
/bin/uptime >> $tmpdir/os_files/uptime.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uptime.txt'>uptime</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /etc/release ]; then
 cp /etc/release $tmpdir/etc/ 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/release.txt'>/etc/release</a></td></tr> " >> $WEBLEFT 2>&1
fi
cp /etc/path_to_inst $tmpdir/etc/path_to_inst.txt 2>&1
cp /etc/mnttab $tmpdir/etc/mnttab.txt 2>&1
cp /etc/vfstab $tmpdir/etc/vfstab.txt 2>&1
cp /kernel/drv/ssd.conf $tmpdir/os_files/ssd.conf.txt 2>&1
cp /kernel/drv/sd.conf $tmpdir/os_files/sd.conf.txt 2>&1

cp /etc/hosts $tmpdir/etc/hosts.txt 2>&1
patch=`uname -v|cut -d_ -f2`
echo $patch > $tmpdir/os_files/uname-v.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname-v.txt'>Patch Level [$patch]</a></td></tr> " >> $WEBLEFT 2>&1


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/path_to_inst.txt'>/etc/path_to_inst</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/mnttab.txt'>/etc/mnttab</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/vfstab.txt'>/etc/vfstab</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/sd.conf.txt'>/kernel/drv/sd.conf</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ssd.conf.txt'>/kernel/drv/ssd.conf</a></td></tr> " >> $WEBLEFT 2>&1

printf "."
cp /etc/inittab $tmpdir/etc/inittab.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/inittab.txt'>/etc/inittab</a></td></tr> " >> $WEBLEFT 2>&1

echo "#env" > $tmpdir/os_files/env.txt 2>&1
env >> $tmpdir/os_files/env.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>shell environment</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


echo "#/usr/bin/crontab -l" >> $tmpdir/os_files/crontabs.txt 2>&1
/usr/bin/crontab -l >> $tmpdir/os_files/crontabs.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/crontabs.txt'>cron tabs</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#/usr/sbin/prtconf -vP" >> $tmpdir/os_files/prtconf.txt 2>&1
/usr/sbin/prtconf -vP >> $tmpdir/os_files/prtconf.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/prtconf.txt'>prtconf</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"


printf "Gathering process information ..."


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ps-ef.txt'>ps -ef</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps -ef"  > $tmpdir/os_files/ps-ef.txt 2>&1
ps -ef  >> $tmpdir/os_files/ps-ef.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ps.txt'>ps -auwwx</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/ucb/ps -auwwx"  > $tmpdir/os_files/ps.txt 2>&1
/usr/ucb/ps -auwwwx  >> $tmpdir/os_files/ps.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ps-aewwx.txt'>ps -aewwx</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/ucb/ps -aewwx"  > $tmpdir/os_files/ps-aewwx.txt 2>&1
/usr/ucb/ps -aewwx  >> $tmpdir/os_files/ps-aewwx.txt 2>&1
printf "\n"

printf "Gathering additional system information ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/prtdiag.txt'>prtdiag -v</a></td></tr> " >> $WEBLEFT 2>&1

echo "#/usr/platform/$arch/sbin/prtdiag -v " >> $tmpdir/os_files/prtdiag.txt 2>&1
/usr/platform/$arch/sbin/prtdiag -v >> $tmpdir/os_files/prtdiag.txt 2>&1
printf "."

echo "#/usr/sbin/prtconf | grep Memory " >>$tmpdir/os_files/memory.txt 2>&1
/usr/sbin/prtconf | grep Memory >> $tmpdir/os_files/memory.txt 2>&1
if [ $? = 0 ]; then
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/memory.txt'>Memory</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ptree-a.txt'>ptree -a</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/bin/ptree -a" >> $tmpdir/os_files/ptree-a.txt 2>&1
/usr/bin/ptree -a >> $tmpdir/os_files/ptree-a.txt 2>&1
printf "."

echo "#/usr/sbin/swap -l" >> $tmpdir/os_files/swap.txt 2>&1
/usr/sbin/swap -l >> $tmpdir/os_files/swap.txt 2>&1
echo $LINE >> $tmpdir/os_files/swap.txt 2>&1
echo "#/usr/sbin/swap -s" >> $tmpdir/os_files/swap.txt 2>&1
/usr/sbin/swap -s >> $tmpdir/os_files/swap.txt 2>&1
echo $LINE >> $tmpdir/os_files/swap.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/swap.txt'>swap info</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"
if [ -f /usr/sbin/prtpicl ]; then
   printf "Gathering Platform Information and Control Library info ..."
   prtpicl -v >> $tmpdir/os_files/prtpicl.txt 2>&1
   printf "."
   echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/prtpicl.txt'>prtpicl</a></td></tr> " >> $WEBLEFT 2>&1
   printf "\n"
fi
printf "Gathering system internal data ..."
echo "#eeprom -v" >> $tmpdir/os_files/eeprom-v.txt 2>&1
/usr/platform/$arch/sbin/eeprom -v  >> $tmpdir/os_files/eeprom-v.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/eeprom-v.txt'>eeprom -v</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#prtfru" >> $tmpdir/os_files/eeprom-v.txt 2>&1
prtfru >> $tmpdir/os_files/prtfru.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/prtfru.txt'>prtfru</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#kstat -m ssderr" >> $tmpdir/os_files/kstat.txt 2>&1
kstat -m ssderr >> $tmpdir/os_files/kstat.txt 2>&1
printf "."
echo "#kstat -m sderr" >> $tmpdir/os_files/kstat.txt 2>&1
kstat -m sderr >> $tmpdir/os_files/kstat.txt 2>&1
printf "."
echo "#kstat -m sterr" >> $tmpdir/os_files/kstat.txt 2>&1
kstat -m sterr >> $tmpdir/os_files/kstat.txt 2>&1
printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/kstat.txt'>kstat</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

(zoneadm) > /dev/null 2>&1
if [ $? = 0 ]; then 
zoneadm list -vc > $tmpdir/os_files/zoneadm.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/zoneadm.txt'>zoneadm</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "Gathering list of /usr/lib & /usr/local/lib files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lib_files.txt'>lib files</a></td></tr> " >> $WEBLEFT 2>&1
echo "# find /usr/lib -type f " >> $tmpdir/os_files/lib_files.txt 2>&1
find /usr/lib -type f  >> $tmpdir/os_files/lib_files.txt 2>&1
echo $LINE   >> $tmpdir/os_files/lib_files.txt 2>&1
echo "# find /usr/local/lib -type f " >> $tmpdir/os_files/lib_files.txt 2>&1
find /usr/local/lib -type f  >> $tmpdir/os_files/lib_files.txt 2>&1
printf "\n"

#-------------------------------------------------------------
printf "Gathering system configuration files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc'>/etc conf files</a></td></tr> " >> $WEBLEFT 2>&1
DIR=/etc
OUTPUT=$tmpdir/etc
TAR=/tmp/_gsctub.tar
LOG=$tmpdir/etc/tar_output.log.txt

if [ ! -d $OUTPUT ]; then
  mkdir $OUTPUT >/dev/null 2>&1
fi
if [ ! -f $LOG ]; then
  rm $LOG >/dev/null 2>&1
fi
if [ ! -f $TAR ]; then
  rm $TAR >/dev/null 2>&1
fi

echo "#cd $DIR ; find . -type f -name '*.conf' |xargs tar -cvf $TAR " >> $LOG 2>&1
cd $DIR ; find . -type f -name "*.conf" |xargs tar -cvf $TAR  >> $LOG 2>&1

echo "#cd $OUTPUT; tar -xvf $TAR  >/dev/null 2>&1" >> $LOG 2>&1
cd $OUTPUT; tar -xvf $TAR  >>$LOG 2>&1
rm -f $TAR >/dev/null 2>&1

for File in "$OUTPUT/*"
  do
   find $File -type f |while read change
    do
      printf "."
      mv ${change} ${change}.txt > /dev/null 2>&1
    done
 done
printf "\n"
#-------------------------------------------------------------




#--------------------------------------------------------------------
# GATHERING ERROR LOGS
#--------------------------------------------------------------------

printf "Gathering error logs ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr> " >> $WEBLEFT 2>&1
cp /var/adm/messages $tmpdir/messages/messages.txt > /dev/null 2>&1
printf "."
cp /var/adm/messages.1 $tmpdir/messages/messages.1.txt > /dev/null 2>&1
printf "."
cp /var/adm/messages.0 $tmpdir/messages/messages.0.txt > /dev/null 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.txt'>/var/adm/messages</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.0.txt'>/var/adm/messages.0</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.1.txt'>/var/adm/messages.1</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.$DATE.txt'>/var/adm/messages for $DATE</a></td></tr> " >> $WEBLEFT 2>&1

touch $tmpdir/messages/messages.$DATE.txt 2>&1
printf "."
echo "#grep "$TMPDATE" $tmpdir/messages/messages.txt" >> $tmpdir/messages/messages.$DATE.txt 2>&1
grep "$TMPDATE" $tmpdir/messages/messages.txt >> $tmpdir/messages/messages.$DATE.txt 2>&1
printf "\n"


printf "Gathering dmesg log ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/dmesg.txt'>dmesg</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/sbin/dmesg" >> $tmpdir/messages/dmesg.txt 2>&1
dmesg >> $tmpdir/messages/dmesg.txt 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------

printf "Gathering disk info thru luxadm ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1

luxadm probe >> $tmpdir/disk/luxadm_probe.txt 2>&1
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/luxadm_probe.txt'>luxadm probe</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
if [ -d /dev/fc ]; then
 ls -al /dev/fc |grep devices |awk '{print $11}' |while read line
  do 
   device=`echo $line |sed -e 's/^..\/..//'`
   echo $LINE >> $tmpdir/disk/luxadm_dump.txt 2>&1
   echo "DEVICE /dev/fc/$device" >> $tmpdir/disk/luxadm_dump.txt 2>&1
   luxadm -e dump_map $device >> $tmpdir/disk/luxadm_dump.txt 2>&1
   printf "."
  done
   echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/luxadm_dump.txt'>luxadm dump_map /dev/fc</a></td></tr> " >> $WEBLEFT 2>&1
fi


if [ -d /devices ]; then
 echo "#find /devices -name \*:c,raw -exec luxadm inquiry {} \;" >>$tmpdir/disk/luxadm_devices.txt 2>&1
 find /devices -name \*:c,raw -exec luxadm inquiry {} \ >>$tmpdir/disk/luxadm_devices.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/luxadm_devices.txt'>luxadm inquiry /devices</a></td></tr> " >> $WEBLEFT 2>&1
fi

 echo "#luxadm inquiry /dev/rdsk/*2" >> $tmpdir/disk/luxadm_rdsk.txt 2>&1
 luxadm inquiry /dev/rdsk/*2 >> $tmpdir/disk/luxadm_rdsk.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/luxadm_rdsk.txt'>luxadm inquiry /dev/rdsk</a></td></tr> " >> $WEBLEFT 2>&1

#ls /dev/rdsk |grep s2 |while read rdsk
#do
# echo $LINE >> $tmpdir/disk/uxadm_disk.txt 2>&1
# echo "DISK $rdsk:" >> $tmpdir/disk/luxadm_disk.txt 2>&1
# echo $LINE >> $tmpdir/disk/luxadm_disk.txt 2>&1
# luxadm inq /dev/rdsk/$rdsk >> $tmpdir/disk/luxadm_disk.txt 2>&1
# printf "."
#done
#  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/luxadm_disk.txt'>luxadm disk</a></td></tr> " >> $WEBLEFT 2>&1


echo "#cfgadm -nal" >> $tmpdir/disk/cfgadm.txt 2>&1
cfgadm -nal >> $tmpdir/disk/cfgadm.txt 2>&1
echo $LINE >> $tmpdir/disk/cfgadm.txt 2>&1
echo "#cfgadm -nalv" >> $tmpdir/disk/cfgadm.txt 2>&1
cfgadm -nalv >> $tmpdir/disk/cfgadm.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/cfgadm.txt'>cfgadm -nalv</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"



printf "Gathering format output ... (this may take a while)"


mount -v >>$tmpdir/disk/mount.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1

###  This routine captures output from the format command
rm -f format_partition.txt > /dev/null 2>&1
rm -f $tmpdir/fcf > /dev/null 2>&1
rm -f $tmpdir/fcf2 > /dev/null 2>&1


#----
printf "disk\n0\nquit\n" > $tmpdir/fcf 2>&1
format -f $tmpdir/fcf > $tmpdir/disk/format.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "format -f" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  printf "\n"
  i=1;
 fi
sleep 1
done
echo "# cat $tmpdir/disk/format.txt |grep "\ cyl\ " |wc -l |awk '{print $1}'" > $tmpdir/disk/numdisks.txt 2>&1
cat $tmpdir/disk/format.txt |grep "\ cyl\ " |wc -l |awk '{print $1}' >> $tmpdir/disk/numdisks.txt 2>&1
rm -f $tmpdir/fcf > /dev/null 2>&1
rm -f $tmpdir/fcf2 > /dev/null 2>&1
#----
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/format.txt'>format command</a></td></tr> " >> $WEBLEFT 2>&1

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/numdisks.txt'>Number of Disks</a></td></tr> " >> $WEBLEFT 2>&1


printf "Gathering additional disk info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/df-k.txt'>df -k</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/sbin/df -k" >> $tmpdir/disk/df-k.txt 2>&1
/usr/sbin/df -k >> $tmpdir/disk/df-k.txt 2>&1
echo $LINE >> $tmpdir/disk/df-k.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/dev_dsk.txt'>List of /dev/dsk</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -AlR /dev/dsk" >>$tmpdir/disk/dev_dsk.txt 2>&1
ls -AlR /dev/dsk >>$tmpdir/disk/dev_dsk.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/dev_rdsk.txt'>List of /dev/rdsk</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -AlR /dev/rdsk" >$tmpdir/disk/dev_rdsk.txt 2>&1
ls -AlR /dev/rdsk >>$tmpdir/disk/dev_rdsk.txt 2>&1
printf "."

if [ -d /dev/fc ] ; then
printf "."
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/dev_fc.txt'>List of /dev/fc</a></td></tr> " >> $WEBLEFT 2>&1
 echo "#ls -AlR /dev/fc" >$tmpdir/disk/dev_fc.txt 2>&1
 ls -AlR /dev/fc >>$tmpdir/disk/dev_fc.txt 2>&1
fi
printf "\n"


#--------------------------------------------------------------------
# GATHERING SOFTWARE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>INSTALLED SOFTWARE & PATCHES</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering software [pkginfo] information ..."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/pkginfo.txt'>pkginfo</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/bin/pkginfo" >> $tmpdir/software/pkginfo.txt 2>&1
/bin/pkginfo >> $tmpdir/software/pkginfo.txt 2>&1 &
waitfor $!
printf "\n"

printf "Gathering detailed software [pkginfo -l] information ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/pkginfo-l.txt'>pkginfo -l</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/bin/pkginfo -l" >> $tmpdir/software/pkginfo-l.txt 2>&1
/bin/pkginfo -l >> $tmpdir/software/pkginfo-l.txt 2>&1 &
waitfor $!
printf "\n"

printf "Gathering system patch information ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/showrev.txt'>showrev -p</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/bin/showrev -p" >> $tmpdir/software/showrev.txt 2>&1
/bin/showrev -p >> $tmpdir/software/showrev.txt 2>&1
printf "\n"

printf "Gathering a list of files in /opt ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>ls /opt</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Alt /opt"  >> $tmpdir/software/ls.opt.txt 2>&1
ls -Alt /opt  >> $tmpdir/software/ls.opt.txt 2>&1
printf "\n"

printf "Gathering java software info ..."
echo "#java -version" >> $tmpdir/software/java.txt 2>&1
java -version >> $tmpdir/software/java.txt 2>&1
echo $LINE >> $tmpdir/software/java.txt 2>&1
echo "#ls -al /usr/ |grep java" >> $tmpdir/software/java.txt 2>&1
ls -al /usr/ |grep java >> $tmpdir/software/java.txt 2>&1
echo $LINE >> $tmpdir/software/java.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/java.txt'>java -version</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#gcc -v " > $tmpdir/software/gcc.txt 2>&1
(gcc -v)  >> $tmpdir/software/gcc.txt 2>&1
if [ $? = 0 ]; then
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/gcc.txt'>gcc -v</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "."


echo "#perl -v" >> $tmpdir/software/perl.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/perl.txt'>perl -v</a></td></tr> " >> $WEBLEFT 2>&1
perl -v >> $tmpdir/software/perl.txt 2>&1
echo $LINE >> $tmpdir/software/perl.txt 2>&1
echo "#ls -al /usr/bin/perl" >> $tmpdir/software/perl.txt 2>&1
ls -al /usr/bin/perl >> $tmpdir/software/perl.txt 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING LUNSTAT INFO
#--------------------------------------------------------------------

(lunstat) > /dev/null 2>&1
if [ $? = 0 ] ; then
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>LUNSTAT</B></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lunstat/lunstat.txt'>Lunstat results</a></td></tr> " >> $WEBLEFT 2>&1
 echo "Found Lunstat ..."
 mkdir $tmpdir/lunstat
 echo "#lunstat -ts" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ts 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -ta" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ta 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tp" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tp 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tr" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tr 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -th" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -th 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "\n"
fi



#--------------------------------------------------------------------
# GATHERING MPXIO
#--------------------------------------------------------------------
m=0
echo "Checking for MPXIO ..."
if [ -f /kernel/drv/fp.conf ]; then
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>MPXIO INFO</B></td></tr> " >> $WEBLEFT 2>&1
 printf "Gathering MPXIO data ..."
 mkdir  $tmpdir/kernel/mpxio > /dev/null 2>&1
 wait
 cp /kernel/drv/fp.conf $tmpdir/kernel/mpxio/fp.conf.txt > /dev/null 2>&1
 printf "."

grep mpxio-disable $tmpdir/kernel/mpxio/fp.conf.txt |grep -v "\#" |grep yes  > /dev/null 2>&1
if [ $? = 0 ]; then
  mpx=1
else 
  mpx=0
fi

grep mpxio-disable $tmpdir/kernel/mpxio/fp.conf.txt |grep -v "\#" |grep no  > /dev/null 2>&1
if [ $? = 0 ]; then
  mpx=0
fi

 if [ $mpx = 0 ]; then
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/fp.conf.txt'><font color='#008000'>MPXIO <i>enabled in fp.conf</font></i></a></td></tr> " >> $WEBLEFT 2>&1
 else
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/fp.conf.txt'><font color='#FF0000'>MPXIO <i>disabled in fp.conf</i></font></a></td></tr> " >> $WEBLEFT 2>&1
 fi
m=1
printf "\n"
fi # end if /kernel/drv/fp.conf


if [ -f /kernel/drv/scsi_vhci.conf ]; then
  if [ ! -f /kernel/drv/fp.conf ]; then
   echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>MPXIO INFO</B></td></tr> " >> $WEBLEFT 2>&1
  fi
 cp /kernel/drv/scsi_vhci.conf $tmpdir/kernel/mpxio/scsi_vhci.conf.txt > /dev/null 2>&1
 grep mpxio-disable $tmpdir/kernel/mpxio/scsi_vhci.conf.txt |grep -v "\#" |grep yes  > /dev/null 2>&1
 if [ $? = 1 ]; then
   grep "load-balance=\"round-robin\"" $tmpdir/kernel/mpxio/scsi_vhci.conf.txt |grep -v "\#" >/dev/null 2>&1
   if [ $? = 0 ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/scsi_vhci.conf.txt'><font color='#008000'>MPXIO <i>enabled </font><font color='FF0000'> & round robin set in scsi_vhci.conf</font></i></a></td></tr> " >> $WEBLEFT 2>&1
    else
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/scsi_vhci.conf.txt'><font color='#008000'>MPXIO <i>enabled & round robin NOT set in scsi_vhci.conf</font></i></a></td></tr> " >> $WEBLEFT 2>&1
   fi
 else
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/scsi_vhci.conf.txt'><font color='#FF0000'>MPXIO <i>disabled in scsi_vhci.conf</i></font></a></td></tr> " >> $WEBLEFT 2>&1
 fi
m=1
fi # end if MPXIO

if [ $m = 1 ];  then
echo "To fully disable MPXIO it must be disabled in both the scsi_vhci.conf and the fp.conf.\r
\r
/kernel/drv/fp.conf sets the global status of mpxio to enable or disable with the mpxio-disable='' parameter.\r
/kernel/drv/scsi_vhci.conf sets the status of mpxio to enable or disable for versions of solaris < 10\r " >> $tmpdir/kernel/mpxio/mpxio_readme.txt 2>&1
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/mpxio_readme.txt'>MPXIO README</a></td></tr> " >> $WEBLEFT 2>&1
fi

#--------------------------------------------------------------------------------
if  [ $mpx = 0 ] && [ -f /usr/sbin/stmsboot ]; then
 if [ ! -d $tmpdir/kernel/mpxio ]; then
  mkdir $tmpdir/kernel/mpxio > /dev/null 2>&1
 fi
 echo "Found stmsboot ... listing boot devices ..."
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/stmsboot.txt'>MPXIO stmsboot</a></td></tr> " >> $WEBLEFT 2>&1
 echo "#/usr/sbin/stmsboot -L" >$tmpdir/kernel/mpxio/stmsboot.txt 2>&1
 /usr/sbin/stmsboot -L >>$tmpdir/kernel/mpxio/stmsboot.txt 2>&1
fi
#--------------------------------------------------------------------------------

if [ -f /kernel/drv/fp.conf ]; then
 if [ ! -d $tmpdir/kernel/mpxio ]; then
  mkdir $tmpdir/kernel/mpxio > /dev/null 2>&1
 fi
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mpxio/fp.conf.txt'>MPXIO fp.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /kernel/drv/fp.conf $tmpdir/kernel/mpxio/fp.conf.txt
fi

#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
wwpn=0
wwnn=0
echo "Looking for JNI configuration information ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA INFO</B></td></tr> " >> $WEBLEFT 2>&1

(fcinfo -V) >/dev/null 2>&1
if [ $? = 0 ]; then
fcinfo hba-port >> $tmpdir/hba/fcinfo_hba.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/fcainfo_hba.txt'>fcainfo hba-port</a></td></tr> " >> $WEBLEFT 2>&1
fi

###  This section tests for JNI cards and copies the required file if it exists

if [ -f /kernel/drv/fcaw.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/fcaw.conf.txt'>fcaw.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/fcaw.conf $tmpdir/fcaw.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/fcaw.conf.txt | grep -iv xxxxxxx |grep -v \# ">> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/fcaw.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwpn=1
        fi
        
	echo "#grep def_wwnn $tmpdir/hba/fcaw.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
	grep def_wwnn $tmpdir/hba/fcaw.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwnn=1
        fi
else
	echo "JNI FCA config file not found" > $tmpdir/not_found/no_jni_fca_hba
fi

echo "Looking for JNI Emerald configuration information ..."


###  This section tests for JNI Emerald cards and.txtputs the required file if it exists

if [ -f /kernel/drv/jnic.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/jnic.conf.txt'>jnic.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/jnic.conf $tmpdir/hba/jnic.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/jnic.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/jnic.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwpn=1
        fi
        echo "#grep def_wwnn $tmpdir/hba/jnic.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwnn $tmpdir/hba/jnic.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         np=1
	fi
else
	echo "JNI Emerald config file not found" > $tmpdir/not_found/no_jni_emerald
fi

echo "Looking for Emluex LP8000/LP9000 configuration information ..."

###  This section tests for Emulex cards and outputs the required file if it exists
if [ -f /kernel/drv/lpfc.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpfc.conf.txt'>lpfc.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/lpfc.conf $tmpdir/hba/lpfc.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/lpfc.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/lpfc.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
          wwpn=1
        fi
        echo "#grep def_wwnn $tmpdir/hba/lpfc.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwnn $tmpdir/hba/lpfc.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwnn=1
        fi
else
	echo "Emulex LP8000/LP9000 config file not found" > $tmpdir/not_found/no_emulex_LP8000-LP9000
fi

echo "Looking for Emulex LP8000S/LP9000S configuration information ..."

###  This section tests for Emulex LP8000S cards and.txtputs the required file if it exists
if [ -f /kernel/drv/lpfs.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpsf.conf.txt'>lpfs.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/lpfs.conf $tmpdir/hba/lpfs.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/lpfs.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/lpfs.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwpn=1
        fi
        echo "#grep def_wwnn $tmpdir/hba/lpfs.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwnn $tmpdir/hba/lpfs.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwnn=1
        fi
else
	echo "Emulex LP8000S/LP9000S config file not found" > $tmpdir/not_found/no_emulex_LP8000S-LP9000S
fi

pkginfo -l |grep -i emulex >> $tmpdir/hba/emulex.driver.info.txt 2>&1
if [ $? = 0 ]; then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.driver.info.txt'>Emulex Driver Info</a></td></tr> " >> $WEBLEFT 2>&1
else 
 rm $tmpdir/hba/emulex.driver.info.txt >/dev/null 2>&1
fi

echo "Looking for QLogic configuration information ..."
noq=0

###  This section tests for qlogic cards and.txtputs the required file if it exists
if [ -f /kernel/drv/qla.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qla.conf.txt'>qla.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/qla.conf $tmpdir/hba/qla.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/qla.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/qla.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwpn=1
        fi
        echo "#grep def_wwnn $tmpdir/hba/qla.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwnn $tmpdir/hba/qla.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwnn=1
        fi
else
noq=1
fi

if [ -f /kernel/drv/qlc.conf ] 
then
	echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlc.conf.txt'>qlc.conf</a></td></tr> " >> $WEBLEFT 2>&1
	cp /kernel/drv/qlc.conf $tmpdir/hba/qlc.conf.txt
        echo "#grep def_wwpn $tmpdir/hba/qlc.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwpn $tmpdir/hba/qlc.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwpn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwpn=1
        fi
        echo "#grep def_wwnn $tmpdir/hba/qlc.conf.txt | grep -iv xxxxxxx |grep -v \#" >> $tmpdir/hba/persistent_binding.txt 2>&1
        grep def_wwnn $tmpdir/hba/qlc.conf.txt | grep -iv xxxxxxx |grep -v \# >> $tmpdir/hba/persistent_binding.txt 2>&1
        if [  $? != 0 ]; then
         echo "no def_wwnn binding found" >>$tmpdir/hba/persistent_binding.txt 2>&1
         wwnn=1
        fi
else
     noq=1
fi

if [ $noq = 1 ]; then
	echo "Qlogic config file not found" > $tmpdir/not_found/no_qlogic_hbas
fi

if [ $wwnn = 0 ]; then
 WWPN="<font color='#008000'><B>Y</b></font>";
else
 WWPN="<font color='#FF0000'><B>N</b></font>";
fi

if [ $wwpn = 0 ]; then
 WWPN="<font color='#008000'><B>Y</b></font>";
else
 WWPN="<font color='#FF0000'><B>N</b></font>";
fi


if [ $wwpn = 0 ] || [ $wwnn = 0 ]; then
 if [ -f $tmpdir/hba/persistent_binding.txt ]; then
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/persistent_binding.txt'>Binding: WWNN[$WWNN],WWPN [$WPNN]</a></td></tr> " >> $WEBLEFT 2>&1
 fi
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/README_persistent_binding.txt'>Persistent Binding README</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo "Using Luxadm to look for HBAs ..."
echo "#luxadm fcode_download -p" >> $tmpdir/hba/luxadm_hba.txt 2>&1
luxadm fcode_download -p >> $tmpdir/hba/luxadm_hba.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/luxadm_hba.txt'>HBAs found with luxadm</a></td></tr> " >> $WEBLEFT 2>&1

echo "#luxadm -e port" >> $tmpdir/hba/luxadm_port.txt 2>&1
luxadm -e port >> $tmpdir/hba/luxadm_port.txt 2>&1

if [ -f $tmpdir/hba/luxadm_port.txt ]; then
	cat $tmpdir/hba/luxadm_port.txt | grep devices |awk '{print $1}'|while read device
		do
			echo "#luxadm -e dump_map $device" >> $tmpdir/hba/luxadm_hba_wwn.txt 2>&1
			luxadm -e dump_map $device >> $tmpdir/hba/luxadm_hba_wwn.txt 2>&1
			echo $LINE >> $tmpdir/hba/luxadm_hba_wwn.txt 2>&1
		done
       echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/luxadm_hba_wwn.txt'>HBA WWN found with luxadm</a></td></tr> " >> $WEBLEFT 2>&1

fi


  
###########################################################################################
### PERSISTENT BINDING README
###########################################################################################
printf "
PERSISTENT BINDING README\n\n
When a target is declared with multiple LUNs, the first target LUN entry provided to an HBA will determine the \n
binding for that target (based on the rules above) and all of its LUNs, regardless of what is\n
declared in the following target LUN entries for the same target to the same HBA. \n\n

In this example, target 1 declares a WWN binding on LUN 0. Therefore, it will be bound to the FC SCSI port \n
advertising the specified WWN, if one exists. \n\n

name='sd' class='scsi' target=1 lun=0 wwXn='2000004568018769'; \n
name='sd' class='scsi' target=1 lun=1; \n 
name='sd' class='scsi' target=1 lun=2; \n\n

* This is the preferred method for binding a WWN to a target ID. \n\n

Targets with WWN bindings should be placed ahead of targets with no WWN bindings in the /kernel/drv/sd.conf file. \n 
This will ensure that the specified ports will be first bound to the desired targets instead of an arbitrary target\n
which did not specify a WWN. This is because the target LUN entries in the sd.conf file are probed by the Solaris \n
SCSI driver in the order that they are listed from the top down. \n

A target may be declared with both WWN and HBA bindings. The combined \n
rules for both will apply. \n
\n
This example shows how the WWN and HBA bindings can be used together. \n

name='sd' class='scsi' target=0 lun=0 hba='fas'; \n
\n
name='sd' class='scsi' target=1 lun=0 hba='fcaw0' w wXn='2000004568018769';\n 
name='sd' class='scsi' target=1 lun=1 hba='fcaw0'; \n
name='sd' class='scsi' target=1 lun=2 hba='fcaw0'; \n
 \n
name='sd' class='scsi' target=5 lun=0 hba='fcaw0' wwXn='2000004568065432'; \n
name='sd' class='scsi' target=5 lun=1 hba='fcaw0';\n
name='sd' class='scsi' target=5 lun=2 hba='fcaw0';\n\n
" >> $tmpdir/hba/README_persistent_binding.txt 2>&1
###########################################################################################

echo "Looking for QLogic HBA's ..."
grep -i qlscli $tmpdir/software/pkginfo-l.txt > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "Found Qlogic hba's ... extracting hba info ..."
  echo "scli -c all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -c all>>$tmpdir/hba/qlogic.scli.txt 2>&1
  echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  printf "."

  echo "scli -i all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -i all>>$tmpdir/hba/qlogic.scli.txt 2>&1
  echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  printf "."

  echo "scli -t all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -t all >>$tmpdir/hba/qlogic.scli.txt 2>&1
  echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  printf "."

  echo "scli -p all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -p all >>$tmpdir/hba/qlogic.scli.txt 2>&1  
  echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  printf "."

  echo "scli -z all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -z all >>$tmpdir/hba/qlogic.scli.txt 2>&1
  echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  printf "."
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic.scli.txt'>Qlogic HBA Info</a></td></tr> " >> $WEBLEFT 2>&1
 printf "\n"
fi

QLOG=$tmpdir/hba/qlogic_iscli.txt

#####################################################################
# Gather iscli info (if it is installed)
#####################################################################
echo  "Searching for Qlogic iscli info ... "
if test -x /usr/local/bin/iscli -o -x /usr/bin/iscli
then
   echo  "Installed ... "
   echo  "Gathering HBA configuration information ... "
   QLOG=$LOGDIR/iscli.out

   #####################################################################
   # Display program version
   #####################################################################
   echo "=================================================" > $QLOG
   echo "Program Version" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -ver >> $QLOG; echo >> $QLOG

   #####################################################################
   # Display general information
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "General Information" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -g >> $QLOG

   #####################################################################
   # Display number of hba_nos 
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "HBA Instance Information" >> $QLOG
   echo "=================================================" >> $QLOG
   HBA_COUNT=`iscli -i | tee -a $QLOG | grep Instance | wc -l`

   #####################################################################
   # if HBA_COUNT > 0, loop through all instances for additional information
   #####################################################################
   HBA_INSTANCE=0
   while test $HBA_COUNT -gt 0
   do
      echo >> $QLOG
      echo "===========================================================" >> $QLOG
      echo "Detailed Information for HBA Instance $HBA_INSTANCE" >> $QLOG
      echo "===========================================================" >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Configuration Settings" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -c $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Port Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -pinfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Statistics" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -stat $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Bootcode Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -binfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE VPD Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -vpd $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Information" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -dspchap $HBA_INSTANCE >> $QLOG
      iscli -dspchap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Map to Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -chapmap $HBA_INSTANCE >> $QLOG
      iscli -chapmap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Persistently Bound Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -ps $HBA_INSTANCE >> $QLOG


      ##################################################################
      # Get list of targets to loop through specific information
      ##################################################################
      TARGET_LIST=`iscli -t $HBA_INSTANCE | grep "Target ID" | cut -c11-15`
      for TARGET_NO in $TARGET_LIST
      do
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO Information" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -t $HBA_INSTANCE $TARGET_NO >> $QLOG
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO LUN List" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -l $HBA_INSTANCE $TARGET_NO >> $QLOG
      done

      echo >> $QLOG
      echo "=================================================" >> $QLOG
      echo "Retrieving HBA $HBA_INSTANCE Crash Dump (if exists)" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -gcr $HBA_INSTANCE $LOGDIR/iscsi_crash_$HBA_INSTANCE.out

      HBA_COUNT=`expr $HBA_COUNT - 1`
      HBA_INSTANCE=`expr $HBA_INSTANCE + 1`
   done

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic_iscli.txt'>Qlogic HBA iscli output</a></td></tr> " >> $WEBLEFT 2>&1

fi


#--------------------------------------------------------------------
# GATHERING KERNEL DATA
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL INFO</B></td></tr> " >> $WEBLEFT 2>&1
mkdir $tmpdir/kernel/conf > /dev/null 2>&1


printf "Gathering kernel configuration files..."
cp /kernel/drv/*.conf $tmpdir/kernel/conf > /dev/null 2>&1
for File in "$tmpdir/kernel/conf/*"
do
  ls $File |while read change
   do
     printf "."
     mv ${change} ${change}.txt > /dev/null 2>&1
   done
done
printf "\n"
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/sd.conf.txt'>sd.conf</a></td></tr> " >> $WEBLEFT 2>&1
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/ssd.conf.txt'>ssd.conf</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f $tmpdir/kernel/conf/qla.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/qla.conf.txt'>qla.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi
if [ -f $tmpdir/kernel/conf/qlc.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/qlc.conf.txt'>qlc.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/kernel/conf/emlxs.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/emlxs.conf.txt'>emlxs.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/kernel/conf/lpfc.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/lpfc.conf.txt'>lpfc.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/kernel/conf/lpfs.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/lpfs.conf.txt'>lpfs.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/kernel/conf/qla2300.conf.txt ]; then
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf/qla2300.conf.txt'>qla2300.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/conf'>/kernel/drv/conf files</a></td></tr> " >> $WEBLEFT 2>&1
ls -AlR /kernel/drv >>$tmpdir/kernel/conf/drv.list.txt 2>&1

printf "Gathering kernel data ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/modinfo.txt'>kernel modinfo</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/sbin/modinfo" >> $tmpdir/kernel/modinfo.txt 2>&1
/usr/sbin/modinfo >> $tmpdir/kernel/modinfo.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/sysdef-D.txt'>sysdef -D</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/sbin/sysdef -D" >> $tmpdir/kernel/sysdef-D.txt 2>&1
printf "."

( /usr/sbin/sysdef -D  ) 1>> $tmpdir/kernel/sysdef-D.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/kernel_info.txt'>kernel semaphores</a></td></tr> " >> $WEBLEFT 2>&1

echo "#grep semaphor $tmpdir/kernel/sysdef-D.txt " > $OUTDIR/.s 2>&1
grep semaphor $tmpdir/kernel/sysdef-D.txt >> $OUTDIR/.s 2>&1
if [ $? = 0 ]; then
echo "#grep semaphor $tmpdir/kernel/sysdef-D.txt " >> $tmpdir/kernel/kernel_info.txt 2>&1
 mv $OUTDIR/.s  $tmpdir/kernel/kernel_info.txt 2>&1
 echo $LINE >> $tmpdir/kernel/kernel_info.txt 2>&1
else
 rm -f $OUTDIR/.s > /dev/null 2>&1
fi
printf "\n"

printf "Still gathering kernel data ..."
grep shared $tmpdir/kernel/sysdef-D.txt >$tmpdir/kernel/kernel_info.txt 2>&1
echo $LINE >> $tmpdir/kernel/kernel_info.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/system.txt'>/etc/system</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/system $tmpdir/kernel/system.txt 2>&1
cp /etc/system $tmpdir/etc/system.txt 2>&1


QDepth README_queue_depth.txt
QDepthReadme

echo "#grep -i sd_max_throttle /etc/system" >> $OUTDIR/.qd 2>&1
grep "sd_max_throttle" /etc/system >> $OUTDIR/.qd 2>&1
if [ $? != 0 ]; then
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/queue_depth.txt'><font color='#FF0000'>Queue depth is NOT SET</a></td></tr> " >> $WEBLEFT 2>&1
  mv $OUTDIR/.qd $tmpdir/kernel/queue_depth.txt 2>&1
  printf "\n\n
-------------------------------------------------------------------------\r
NO QUEUE DEPTH PRESENT IN /etc/system file!  \r
THIS NEEDS TO BE SET!!\r
-------------------------------------------------------------------------\r
  " >> $tmpdir/kernel/queue_depth.txt 2>&1

else
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/queue_depth.txt'><font color='#008000'>Queue depth is set</a></td></tr> " >> $WEBLEFT 2>&1
  mv $OUTDIR/.qd $tmpdir/kernel/queue_depth.txt 2>&1
fi

QDepth queue_depth.txt

printf "\n"
#--------------------------------------------------------------------
# GATHERING NETWORKING INFO
#--------------------------------------------------------------------

printf "Gathering System Networking Information ...(may take 30 sec)"
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING</B></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/dns.txt'>DNS Lookup Info</a></td></tr> " >> $WEBLEFT 2>&1

echo "hostname=$HOSTNAME" > $tmpdir/networking/dns.txt 2>&1
echo "------------Hostname-------------------------------" >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME |nslookup >> $tmpdir/networking/dns.txt 2>&1
echo "------------Forward lookup-------------------------" >> $tmpdir/networking/dns.txt 2>&1
grep -i `hostname` /etc/hosts | uniq|awk '{print $1}' |nslookup >> $tmpdir/networking/dns.txt 2>&1
echo "------------Reverse lookup-------------------------" >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME >> $tmpdir/networking/dns.txt 2>&1
echo "------------Resolv.conf-------------------------" >> $tmpdir/networking/dns.txt 2>&1
/usr/bin/cat /etc/resolv.conf >> $tmpdir/networking/dns.txt 2>&1
printf "."

echo "--------------------ARP-------------------------" >> $tmpdir/networking/dns.txt 2>&1
echo "#/usr/sbin/arp -a" >> $tmpdir/networking/dns.txt 2>&1
/usr/sbin/arp -a >> $tmpdir/networking/dns.txt 2>&1
printf "."

echo "-----------------DEFAULTROUTER-------------------------" >> $tmpdir/networking/dns.txt 2>&1
/usr/bin/cat /etc/defaultrouter >> $tmpdir/networking/dns.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cat /etc/hosts" > $tmpdir/networking/hosts.txt 2>&1
/usr/bin/cat /etc/hosts >> $tmpdir/networking/hosts.txt 2>&1
cp $tmpdir/networking/hosts.txt $tmpdir/etc/ >/dev/null 2>&1
echo "#nfsstat" >$tmpdir/networking/nfsstat.txt 2>&1	
nfsstat >>$tmpdir/networking/nfsstat.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/nfsstat.txt'>nfsstat</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

printf "Gathering WWN for host [$HOSTNAME] ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/wwn.txt'>WWN Info from prtpicl</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /usr/sbin/prtpicl ]; then 
   prtpicl -v >> $tmpdir/os_files/prtpicl.txt 2>&1
   waitfor $!
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/prtpicl.txt'>prtpicl</a></td></tr> " >> $WEBLEFT 2>&1
   echo "#egrep -i 'port-wwn|node-wwn' ../os_files/prtpicl.txt" >> $tmpdir/networking/wwn.txt 2>&1
  egrep -i "port-wwn|node-wwn" $tmpdir/os_files/prtpicl.txt  |sort |uniq  >> $tmpdir/networking/wwn.txt 2>&1
  echo $LINE  >> $tmpdir/networking/wwn.txt 2>&1
  echo "Initiator & Target Ports" >> $tmpdir/networking/wwn.txt 2>&1

  egrep -i "initiator-port|target-port" $tmpdir/os_files/prtpicl.txt    >> $tmpdir/networking/wwn.txt 2>&1
  printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/boot_device.txt'>boot device</a></td></tr> " >> $WEBLEFT 2>&1
  echo "#grep -i boot-device $tmpdir/os_files/prtpicl.txt  ">> $tmpdir/os_files/boot_device.txt 2>&1
  grep -i boot-device $tmpdir/os_files/prtpicl.txt   >> $tmpdir/os_files/boot_device.txt 2>&1
  echo $LINE >> $tmpdir/networking/wwn.txt 2>&1
  printf "."
else 
  echo "#prtconf -vp |grep -i wwn" >> $tmpdir/networking/wwn.txt 2>&1
  /usr/sbin/prtconf -vp |grep -i wwn >> $tmpdir/networking/wwn.txt 2>&1
  echo $LINE >> $tmpdir/networking/wwn.txt 2>&1
  printf "."
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/boot_device.txt'>boot device</a></td></tr> " >> $WEBLEFT 2>&1
  echo "#prtconf -vp | grep  boot-device ">> $tmpdir/os_files/boot_device.txt 2>&1
  /usr/sbin/prtconf -vp |grep  boot-device  >> $tmpdir/os_files/boot_device.txt 2>&1
  printf "."
fi 

#------------------
if [ -f /usr/sbin/luxadm ]; then

if [ /usr/bin/prtdiag ]; then
 pdpath=/usr/bin;
fi

if [ /usr/sbin/prtdiag ]; then
 pdpath=/usr/sbin;
fi


if [ /usr/platform/$arch/sbin/prtdiag ]; then
 pdpath=/usr/platform/$arch/sbin;
fi
    for n in `luxadm qlgc | grep "Opening Device" | awk '{print $3}'`
     do
 (     echo; echo "FC HBA device: $n"
       IW_short_dev=`echo $n | awk -F/ '{print $4}'`
      $pdpath/prtdiag \
       | awk '/'$IW_short_dev'/ {print line} {line=$0}' \
       | awk ' { print "Slot: " $3 } { print "PCI speed: " $2 " MHz"}'
       luxadm -e dump_map $n
 ) >> $tmpdir/networking/wwn.txt 2>&1
     printf "."
     done
fi
#------------------

printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat.txt'>netstat info</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/bin/netstat -a" >> $tmpdir/networking/netstat.txt 2>&1
/bin/netstat -a >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
printf "."

echo "#/bin/netstat -an" >> $tmpdir/networking/netstat.txt 2>&1
/bin/netstat -an >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
printf "."

echo "#/bin/netstat -rn" >> $tmpdir/networking/netstat.txt 2>&1
/bin/netstat -rn >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/ifconfig-a.txt'>ifconfig -a</a></td></tr> " >> $WEBLEFT 2>&1

echo "#/usr/sbin/ifconfig -a" >> $tmpdir/networking/ifconfig-a.txt 2>&1
/usr/sbin/ifconfig -a >> $tmpdir/networking/ifconfig-a.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/services.txt'>/etc/services</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/services  $tmpdir/networking/services.txt 2>&1
cp /etc/services  $tmpdir/etc/services.txt 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering System Performance Information ... (may take 30 sec)"
echo "#/usr/bin/isainfo -v" >> $tmpdir/performance/isainfo-v.txt 2>&1
/usr/bin/isainfo -v >> $tmpdir/performance/isainfo-v.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/isainfo-v.txt'>isainfo-v</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#/usr/bin/pagesize"  >> $tmpdir/performance/pagesize.txt 2>&1
/usr/bin/pagesize  >> $tmpdir/performance/pagesize.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/pagesize.txt'>pagesize</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/bin/vmstat 1 10" >> $tmpdir/performance/vmstat.txt 2>&1
/usr/bin/vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmstat 1 10" | grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
printf "."
fi

ps -ef |grep mpstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/mpstat.txt'>mpstat</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/bin/mpstat 1 5 " >> $tmpdir/performance/mpstat.txt 2>&1
/usr/bin/mpstat 1 5 >> $tmpdir/performance/mpstat.txt 2>&1 &
waitfor $!
printf "."
fi

ps -ef |grep iostat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "#/usr/bin/iostat -p ALL 2 6" >> $tmpdir/performance/iostat.txt 2>&1
/usr/bin/iostat -p ALL 2 6 >> $tmpdir/performance/iostat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "iostat" | grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
printf "."
fi

ps -ef |grep prstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
 if [ -f /usr/bin/prstat ]; then
  printf "."
  echo "#/usr/bin/prstat -u root -n 50 -P 1,2 1 1"  >> $tmpdir/performance/prstat.txt 2>&1
  /usr/bin/prstat -u root -n 50 -P 1,2 1 1  >> $tmpdir/performance/prstat.txt 2>&1
 fi
fi

printf "."

(top -v)  >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
 top -b -n2 >> $tmpdir/performance/top.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "\n"

####################################################################################
###  This section tests for DiskSuite installation then obtains available data
### SOLSTICE DISK SUITE
###############################################################################
echo "Checking to see if Solstice Disk Suite is installed ..."

if [ -f /etc/opt/SUNWmd/md.tab ] || [ -f /etc/md.tab ]
then
echo " <tr><td width='100%' bgcolor='#FFFFFF'>SOLSTICE DISK SUITE</td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disksuite/sdsinfo.txt'>Solstice Disk Suite Info</a></td></tr> " >> $WEBLEFT 2>&1
        echo "Found Solstice Disk Suite"
	mkdir $tmpdir/disksuite > /dev/null 2>&1
	cp /etc/opt/SUNWmd/md.tab $tmpdir/disksuite
	echo "" > $tmpdir/disksuite/sdsinfo.txt
	echo "This files contains Solstice Disk Suite specific info" >> $tmpdir/disksuite/sdsinfo.txt
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "The following shows SDS package info" >> $tmpdir/disksuite/sdsinfo.txt
	echo $LINE >> $tmpdir/disksuite/sdsinfo.txt
	/bin/pkginfo -l SUNWmd >> $tmpdir/disksuite/sdsinfo.txt 2>&1
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "The following shows DiskSuite database info" >> $tmpdir/disksuite/sdsinfo.txt
	echo $LINE >> $tmpdir/disksuite/sdsinfo.txt
	/usr/opt/SUNWmd/sbin/metadb >> $tmpdir/disksuite/sdsinfo.txt 2>&1
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "The following lists all DiskSuite volumes found" >> $tmpdir/disksuite/sdsinfo.txt
	echo $LINE >> $tmpdir/disksuite/sdsinfo.txt
	/usr/opt/SUNWmd/sbin/metastat >> $tmpdir/disksuite/sdsinfo.txt 2>&1
	echo "" >> $tmpdir/disksuite/sdsinfo.txt
	echo "" >> $tmpdir/disksuite/sdsinfo.txt


else
	echo "Solstice Disk Suite was not found" > $tmpdir/not_found/no_disksuite
fi

#---------------------------------------------------------
# IF SERVER IS A FUJITSU SERVER
#---------------------------------------------------------
else

# IF A Fujitsu Server
if [  -d /opt/FJSVhwr/sbin ]; then
 echo "Found Fujitsu SUN server ..."
 mkdir $tmpdir/fujitsu >/dev/null 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'>FUJITSU SUN SERVER</td></tr> " >> $WEBLEFT 2>&1

if [ -f /opt/FJSVhwr/sbin/fjprtdiag ]; then
  echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/fujitsu/fjprtdiag-v.txt'>fjprtdiag -v</a></td></tr> " >> $WEBLEFT 2>&1
  /opt/FJSVhwr/sbin/fjprtdiag -v >> $tmpdir/fujitsu/fjprtdiag-v.txt 2>&1
fi

 if [ -d /opt/FJSVsnap/bin ]; then
  echo "Running Fujitsu /opt/FJSVsnap/bin/fjsnap -a  -T $OUTDIR $tmpdir/fujitsu/$HOSTNAME.fjsnap.gz ..."
  /opt/FJSVsnap/bin/fjsnap -a -T $OUTDIR $tmpdir/fujitsu/$HOSTNAME.fjsnap.gz
 fi
fi

fi # End test for fujitsu server

#End sun Function
}
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
# HP-UX FUNCTIONS
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
hpux()
{

if [ -f /tmp/.setx ]; then
 set -x
fi
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'>GetConfig Help</a></td></tr> " >> $WEBLEFT 2>&1

###  This will create and define the directory to place files in
echo "Created temporary directories ..."
(
mkdir $tmpdir/lvm 
mkdir $tmpdir/software 
) > /dev/null 2>&1

#--------------------------------------------------------------------
# GATHERING SYSTEM INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM INFO</B></td></tr> " >> $WEBLEFT 2>&1
v=`uname -r`
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>OS Version[$v]</a></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering system information ..."
echo "#date" > $tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#/bin/uptime" >> $tmpdir/os_files/uptime.txt 2>&1
/bin/uptime >> $tmpdir/os_files/uptime.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uptime.txt'>uptime</a></td></tr> " >> $WEBLEFT 2>&1

echo "#model" >> $tmpdir/os_files/model.txt 2>&1
model >> $tmpdir/os_files/model.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/model.txt'>HW Model</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/system.txt'>/stand/system</a></td></tr> " >> $WEBLEFT 2>&1
cp /stand/system $tmpdir/os_files/system.txt > /dev/null 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/fstab.txt'>/etc/fstab</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/fstab  $tmpdir/etc/fstab.txt > /dev/null 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/inittab.txt'>/etc/inittab</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/inittab  $tmpdir/etc/inittab.txt > /dev/null 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/mnttab.txt'>/etc/mnttab</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/mnttab $tmpdir/etc/mnttab.txt > /dev/null 2>&1
if [ -f /etc/mdtab ]; then
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/mdtab.txt'>/etc/mdtab</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/mdtab $tmpdir/etc/mdtab.txt > /dev/null 2>&1
 printf "."
fi



echo "#/usr/bin/uname -a" >> $tmpdir/os_files/uname.txt 2>&1
/usr/bin/uname -a >> $tmpdir/os_files/uname.txt
printf "."
echo "#/usr/bin/uname -r" >> $tmpdir/os_files/uname.txt
x=`/usr/bin/uname -r`
echo $x >> $tmpdir/os_files/uname.txt
printf "."

echo $x |grep "B.11.11" > /dev/null 2>&1
if [ $? = 0 ]; then
   echo "Processor Architecture = PA-RISC" >> $tmpdir/os_files/architecture.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/architecture.txt'>processor architecture</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo $x |grep B.11.20 > /dev/null 2>&1
if [ $? = 0 ]; then
   echo "Processor Architecture = Intel Itanium" >> $tmpdir/os_files/architecture.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/architecture.txt'>processor architecture</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo $x |grep B.11.22 > /dev/null 2>&1
if [ $? = 0 ]; then
   echo "Processor Architecture = Intel Itanium" >> $tmpdir/os_files/architecture.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/architecture.txt'>processor architecture</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo $x |grep B.11.23 > /dev/null 2>&1
if [ $? = 0 ]; then
   echo "Processor Architecture = PA-RISC or Intel Itanium" >> $tmpdir/os_files/architecture.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/architecture.txt'>processor architecture</a></td></tr> " >> $WEBLEFT 2>&1
fi


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>Shell Environment</a></td></tr> " >> $WEBLEFT 2>&1
echo "#env" > $tmpdir/os_files/env.txt 2>&1
env >> $tmpdir/os_files/env.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/services.txt'>/etc/services</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/services $tmpdir/os_files/services.txt  2>&1
printf "."


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ioscan-fk.txt'>IOSCAN -fk </a></td></tr> " >> $WEBLEFT 2>&1
echo "ioscan -fk" >> $tmpdir/os_files/ioscan-fk.txt
ioscan -fk >> $tmpdir/os_files/ioscan-fk.txt
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ioscan-mdsf.txt'>IOSCAN -m dsf </a></td></tr> " >> $WEBLEFT 2>&1
echo "#ioscan -m dsf" >> $tmpdir/os_files/ioscan-mdsf.txt
ioscan -m dsf >> $tmpdir/os_files/ioscan-mdsf.txt
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/cmcld.txt'>what /usr/lbin/cmcld </a></td></tr> " >> $WEBLEFT 2>&1
echo "#what /usr/lbin/cmcld" >> $tmpdir/os_files/cmcld.txt 2>&1
what /usr/lbin/cmcld >> $tmpdir/os_files/cmcld.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/hosts $tmpdir/os_files/hosts.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/kmtune.txt'>kmtune</a></td></tr> " >> $WEBLEFT 2>&1
echo "/usr/sbin/kmtune" >>$tmpdir/os_files/kmtune.txt  2>&1
/usr/sbin/kmtune >>$tmpdir/os_files/kmtune.txt  2>&1
printf "."

echo "#grep scsi_max_depth $tmpdir/os_files/kmtune.txt " >> $tmpdir/os_files/scsi_max_depth.txt  2>&1
grep scsi_max_depth $tmpdir/os_files/kmtune.txt >$OUTDIR/.k 2>&1
if [ $? = 0 ]; then
 mv $OUTDIR/.k  $tmpdir/os_files/scsi_max_depth.txt  2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/scsi_max_depth.txt'>Queue Depth</a></td></tr> " >> $WEBLEFT 2>&1
else
 rm $OUTDIR/.k > /dev/null 2>&1
fi
printf "\n"

#-------------------------------------------------------------
printf "Gathering system configuration files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc'>/etc conf files</a></td></tr> " >> $WEBLEFT 2>&1
DIR=/etc
OUTPUT=$tmpdir/etc
TAR=/tmp/_gsctub.tar
LOG=$tmpdir/etc/tar_output.log.txt

if [ ! -d $OUTPUT ]; then
  mkdir $OUTPUT >/dev/null 2>&1
fi
if [ ! -f $LOG ]; then
  rm $LOG >/dev/null 2>&1
fi
if [ ! -f $TAR ]; then
  rm $TAR >/dev/null 2>&1
fi

echo "#cd $DIR ; find . -type f -name '*.conf' |xargs tar -cvf $TAR " >> $LOG 2>&1
cd $DIR ; find . -type f -name "*.conf" |xargs tar -cvf $TAR  >> $LOG 2>&1

echo "#cd $OUTPUT; tar -xvf $TAR  >/dev/null 2>&1" >> $LOG 2>&1
cd $OUTPUT; tar -xvf $TAR  >>$LOG 2>&1
rm -f $TAR >/dev/null 2>&1

for File in "$OUTPUT/*"
  do
   find $File -type f |while read change
    do
      printf "."
      mv ${change} ${change}.txt > /dev/null 2>&1
    done
 done
#-------------------------------------------------------------

printf "\n"

#--------------------------------------------------------------------
# GATHERING ERROR LOGS 
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering syslogs ..."
if [ -d /var/adm/syslog ]; then
  ls -al /var/adm/syslog >> $tmpdir/messages/ls.syslog.txt 2>&1
  printf "."
  cp /var/adm/syslog/*sys*.log  $tmpdir/messages/ > /dev/null 2>&1
fi

if [ -f /var/log/syslog ]; then
  ls -al /var/log/syslog >> $tmpdir/messages/ls.syslog.txt 2>&1
  printf "."
  cp /var/log/*sys*.log  $tmpdir/messages/ > /dev/null 2>&1
fi

ls $tmpdir/messages |grep -v txt |egrep -i "messages|syslog" |while read File
do
     printf "."
     mv $tmpdir/messages/${File} $tmpdir/messages/$File.txt > /dev/null 2>&1
     echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/$File.txt'>$File</a></td></tr> " >> $WEBLEFT 2>&1
  done

printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/dmesg.txt'>dmesg</a></td></tr> " >> $WEBLEFT 2>&1
/usr/sbin/dmesg > $tmpdir/messages/dmesg.txt
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.$DATE.txt'>syslog errors on $DATE</a></td></tr> " >> $WEBLEFT 2>&1
echo "grep "$TMPDATE" $tmpdir/messages/syslog*" >> $tmpdir/messages/syslog.$DATE.txt 2>&1
grep "$TMPDATE" $tmpdir/messages/syslog* >> $tmpdir/messages/syslog.$DATE.txt 2>&1

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/ls.syslog.txt'>ls /var/adm/syslog</a></td></tr> " >> $WEBLEFT 2>&1

cp /etc/syslog.conf $tmpdir/os_files/syslog.conf.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/syslog.conf.txt'>syslog.conf</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING SOFTWARE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SOFTWARE</B></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering Java info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/java.txt'>java -version</a></td></tr> " >> $WEBLEFT 2>&1
echo "#java -version" >> $tmpdir/software/java.txt 2>&1
java -version >> $tmpdir/software/java.txt 2>&1
echo "#ls -al /usr/ |grep java" >> $tmpdir/software/java.txt 2>&1
ls -al /usr/ |grep java >> $tmpdir/software/java.txt 2>&1
printf "\n"

printf "Gathering misc software info ..."

echo "#gcc -v " >>$tmpdir/software/gcc.txt 2>&1
gcc -v  >> $tmpdir/software/gcc.txt 2>&1
if [ $? = 0 ]; then
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/gcc.txt'>gcc -v</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "."

echo "#perl -v" >> $tmpdir/software/perl.txt 2>&1
perl -v >> $tmpdir/software/perl.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/perl.txt'>perl -v</a></td></tr> " >> $WEBLEFT 2>&1
echo $LINE >> $tmpdir/software/perl.txt 2>&1
echo "#ls -al /usr/bin/perl" >> $tmpdir/software/perl.txt 2>&1
ls -al /usr/bin/perl >> $tmpdir/software/perl.txt 2>&1
printf "."

echo "#ls -Alt /opt"  >> $tmpdir/software/ls.opt.txt 2>&1
ls -Alt /opt  >> $tmpdir/software/ls.opt.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>ls /opt</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#ls -Alt /opt" >> $tmpdir/software/ls.opt.txt 2>&1
ls -Al /opt  >> $tmpdir/software/ls.opt.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>/opt Software</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#swlist -l product" >> $tmpdir/software/swlist-l_product.txt
swlist -l product >> $tmpdir/software/swlist-l_product.txt
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/swlist-l_product.txt'>swlist -l product</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

echo "Gathering Software information for patches ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/swlist-l_patch.txt'>swlist -l patch</a></td></tr> " >> $WEBLEFT 2>&1
echo "#swlist -l patch" >> $tmpdir/software/swlist-l_patch.txt
swlist -l patch >> $tmpdir/software/swlist-l_patch.txt

echo "Gathering Software information for software bundles ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/swlist-l_bundle.txt'>swlist -l bundle</a></td></tr> " >> $WEBLEFT 2>&1
echo "#swlist -l bundle" >> $tmpdir/software/swlist-l_bundle.txt
swlist -l bundle >> $tmpdir/software/swlist-l_bundle.txt

#--------------------------------------------------------------------
# GATHERING LUNSTAT
#--------------------------------------------------------------------

lunstat > /dev/null 2>&1
if [ $? = 0 ] ; then
 printf "/n"
 echo "Found Lunstat ..."
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>LUNSTAT</B></td></tr> " >> $WEBLEFT 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lunstat/lunstat.txt'>Lunstat output</a></td></tr> " >> $WEBLEFT 2>&1
 mkdir $tmpdir/lunstat
  echo "#lunstat -ts" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ts 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -ta" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ta 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tp" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tp 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tr" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tr 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -th" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -th 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "\n"
fi

echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL</B></td></tr> " >> $WEBLEFT 2>&1
QDepth README_queue_depth.txt
QDepthReadme

echo "#what /stand/vmunix" >> $tmpdir/kernel/vmunix.txt 2>&1
what /stand/vmunix >> $tmpdir/kernel/vmunix.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmunix.txt'>what vmunix</a></td></tr> " >> $WEBLEFT 2>&1

#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA</B></td></tr> " >> $WEBLEFT 2>&1
echo "Gathering HBA information ..."
if [ -f $tmpdir/software/swlist-l_bundle.txt ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/swlist-l_hba.txt'>swlist HBA info</a></td></tr> " >> $WEBLEFT 2>&1
echo "#swlist -l bundle |grep -i fibre " >> $tmpdir/hba/swlist-l_hba.txt
cat $tmpdir/software/swlist-l_bundle.txt |grep -i fibre >> $tmpdir/hba/swlist-l_hba.txt
fi
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/ioscan_hba.txt'>IOSCAN HBA Info </a></td></tr> " >> $WEBLEFT 2>&1
echo "#ioscan -fkCext_bus" >> $tmpdir/hba/ioscan_hba.txt
ioscan -fkCext_bus >> $tmpdir/hba/ioscan_hba.txt 2>&1
echo $LINE >> $tmpdir/hba/ioscan_hba.txt 2>&1
# Fibre adapters are in the 'lan' class
echo "#ioscan -fkClan" >> $tmpdir/hba/ioscan_hba.txt
ioscan -fkClan >> $tmpdir/hba/ioscan_hba.txt
echo $LINE >> $tmpdir/hba/ioscan_hba.txt 2>&1
# Fibre adapters are in the 'fc' class
echo "#ioscan -fnkCfc" >> $tmpdir/hba/ioscan_hba.txt 2>&1
ioscan -fnkCfc >> $tmpdir/hba/ioscan_hba.txt 2>&1

cp /etc/hba.conf $tmpdir/hba/hba.conf.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba.conf.txt'>/etc/hba.conf</a></td></tr> " >> $WEBLEFT 2>&1


echo "Preparing to collect detailed HBA information with fcmsutil ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/fcmsutil.txt'>fcmsutil detailed</a></td></tr> " >> $WEBLEFT 2>&1

# Fibre HBA information
ls /dev/td* >/dev/null 2>&1
if [ $? = 0 ] && [ -x /opt/fcms/bin/fcmsutil ]; then
        printf "Checking /dev/td instances with fcmsutil ..."
	for n in 0 1 2 3 4 5 6 7
	do
        echo  >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo $LINE >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "CHECKING /dev/td${n} instances with fcmsutil" >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo $LINE >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/td${n}" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/td${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/td${n} get remote all" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/td${n} get remote all >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/td${n} get fabric" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/td${n} get fabric >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/td${n} stat" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/td${n} stat >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/tdutil /dev/td${n}" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/tdutil /dev/td${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "########################################################" >> $tmpdir/hba/fcmsutil.txt 2>&1
        printf "."
	done
        printf "\n"
fi	
ls /dev/fcms* >/dev/null 2>&1
if [ $? = 0 ] && [ -x /opt/fcms/bin/fcmsutil ]; then
        printf "Checking fcms instances with fcmsutil ..."
	for n in 0 1 2 3 4 5 6 7
	do
        echo "CHECKING fcms${n} instances with fcmsutil----------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcms${n} " >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcms${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcms${n} get remote all" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcms${n} get remote all >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcms${n} get fabric" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcms${n} get fabric >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcms${n} stat" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcms${n} stat >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/tdutil /dev/fcms${n}" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/tdutil /dev/fcms${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "########################################################" >> $tmpdir/hba/fcmsutil.txt 2>&1
        printf "."
	done
        printf "\n"
fi	
ls /dev/fcd* >/dev/null 2>&1
if [ $? = 0 ] && [ -x /opt/fcms/bin/fcmsutil ]; then
        printf "Checking fcdX with fcmsutil ..."
	for n in 0 1 2 3 4 5 6 7
	do
        echo "CHECKING fcd${n} instances with fcmsutil----------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcd${n}" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcd${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcd${n} get remote all" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcd${n} get remote all >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcd${n} get fabric" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcd${n} get fabric >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/fcmsutil /dev/fcd${n} stat"  >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/fcd${n} stat >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "------------------------------------------------------" >> $tmpdir/hba/fcmsutil.txt 2>&1
	echo "#/opt/fcms/bin/tdutil /dev/fcd${n}" >> $tmpdir/hba/fcmsutil.txt 2>&1
	/opt/fcms/bin/tdutil /dev/fcd${n} >> $tmpdir/hba/fcmsutil.txt 2>&1
        echo "########################################################" >> $tmpdir/hba/fcmsutil.txt 2>&1
        printf "."
	done
        printf "\n"
fi	
ls /dev/td* >/dev/null 2>&1
if [ $? = 0 ] && [ -x /opt/fcms/bin/fcmsutil ]; then
        echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/fcmsutil_vpd.txt'>fcmsutil VPD Info</a></td></tr> " >> $WEBLEFT 2>&1
        printf "Checking Vital Product HBA Data with fcmsutil /dev/td(x) vpd ..."
	for n in 0 1 2 3 4 5 6 7 
	do
        echo "CHECKING Vital Product Data with fcmsutil for td${n} ----------------------------" >> $tmpdir/hba/fcmsutil_vpd.txt 2>&1
	/opt/fcms/bin/fcmsutil /dev/td${n} >> $tmpdir/hba/fcmsutil_vpd.txt 2>&1
        echo "########################################################" >> $tmpdir/hba/fcmsutil_vpd.txt 2>&1
        printf "."
	done
        printf "\n"
fi	
getEmulex
#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering Disk Information ..."

RAWDEVICES=`ioscan -fknCdisk |awk '/\/rdsk\//{ print $2 }'`
BLOCKDEVICES=`ioscan -fknCdisk |awk '/\/rdsk\//{ print $1 }'`

echo "$BLOCKDEVICES" >> $tmpdir/disk/pvdisplays.txt 2>&1
for Disk in $BLOCKDEVICES
do
( echo "pvdisplay for $Disk"
 pvdisplay -v $Disk | awk '{ if ($0 ~ "--- Physical extents ---" ) exit; 
  else print $0;
  }'; ) >>$tmpdir/disk/pvdisplays.txt 2>&1
  printf "."
done 
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/pvdisplays.txt'>pvdisplay</a></td></tr> " >> $WEBLEFT 2>&1

# Disk-specific
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/ioscan-fknCdisk.txt'>ioscan -fknCdisk</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ioscan -fknCdisk" >> $tmpdir/disk/ioscan-fknCdisk.txt  2>&1
ioscan -fknCdisk >> $tmpdir/disk/ioscan-fknCdisk.txt  2>&1
printf "\n"
ls -al /dev/rdsk > $tmpdir/disk/ls_dev_rdsk.txt
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/ls_dev_rdsk.txt'>ls -Al /dev/rdsk </a></td></tr> " >> $WEBLEFT 2>&1

printf "Extracting disk info ..." 
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/diskinfo-v.txt'>diskinfo -v /rdsk</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/hds_disk_port_info.txt'>HDS Disk Info</a></td></tr> " >> $WEBLEFT 2>&1
for Disk in $RAWDEVICES
do
   ( echo "==================================================================" >> $tmpdir/disk/diskinfo-v.txt 2>&1 ) >$NULL
   ( echo "#diskinfo for $Disk \n" >> $tmpdir/disk/diskinfo-v.txt 2>&1 ) > /dev/null 2>&1
    diskinfo -v $Disk  > /tmp/.di 2>&1
cat /tmp/.di |grep -i hitachi   >/dev/null 2>&1
if [ $? = 0 ]; then
echo "DISK=$Disk" >> $tmpdir/disk/hds_disk_port_info.txt 2>&1
egrep "vendor|product id" /tmp/.di | sed -e 's/^[ \t]*//' >> $tmpdir/disk/hds_disk_port_info.txt 2>&1
diskinfo -v $Disk  >> $tmpdir/disk/diskinfo-v.txt 2>&1  

input=`grep inquiry /tmp/.di `
string=`echo $input|cut -d\: -f2`
for i in $string
do
 if [ "$i" != ")" ]; then
  num=`echo $i |cut -d\) -f2`
  byte=`echo $i|cut -d\) -f1 |cut -d\( -f2` 

  if [ $byte = "46" ]; then
  break
  fi

  if [ $byte -ge "39" ] && [ $byte -le "42" ]; then
   t=$num
   ascii $num
   printf $num >> /tmp/tdisk 2>&1
  fi

  if [ $byte = "42" ]; then
    v=`cat /tmp/tdisk`
    echo "LN=$v " >> $tmpdir/disk/hds_disk_port_info.txt 2>&1
    rm -f /tmp/tdisk >/dev/null 2>&1
  fi

  if [ $byte -ge "44" ] && [ $byte -le "45" ]; then
   ascii $num
   printf $num >> /tmp/tport 2>&1
  fi
  if [ $byte = "45" ]; then
   p=`cat /tmp/tport`
   echo "PT=$p" >> $tmpdir/disk/hds_disk_port_info.txt 2>&1
   rm -f /tmp/tport >/dev/null 2>&1
  fi
 fi # end if $i != )
  printf "."
done
   echo $LINE >> $tmpdir/disk/hds_disk_port_info.txt 2>&1
fi # end if grep -i hitachi /tmp/.di

    cat /tmp/.di  >> $tmpdir/disk/diskinfo-v.txt 2>&1
    rm -f /tmp/.di >/dev/null 2>&1
   printf "."
done
printf "\n"


printf "Checking for obsolete disks ..." 
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/obsolete_disks.txt'>obsolete disks</a></td></tr> " >> $WEBLEFT 2>&1
echo "#grep SIOC $tmpdir/disk/diskinfo-v.txt" >> $tmpdir/disk/obsolete_disks.txt 2>&1
grep SIOC $tmpdir/disk/diskinfo-v.txt |awk '{print $4}' >> $tmpdir/disk/obsolete_disks.txt 2>&1
printf "\n"

printf "Extracting disk scsictl info ..."
n=0
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_queue_depth.txt'>Queue Depth</a></td></tr> " >> $WEBLEFT 2>&1
cat $tmpdir/disk/ioscan-fknCdisk.txt |while read line
do
if [ $n != 1 ];then
  echo "$line" | egrep "DROM|DVD" > /dev/null 2>&1
  if [ $? = 0 ];then
   n=1
  fi
  DISK=`echo $line |awk '/\/rdsk\//{ print $2 }'`
  if [ -n "$DISK" ]; then
    ( echo "#scsictl -a $DISK: " `scsictl -a $DISK` "\n">> $tmpdir/disk/disk_queue_depth.txt 2>&1 ) > /dev/null 2>&1
  fi
else
  echo $line |grep rdsk  > /dev/null 2>&1
  if [ $? = 0 ]; then
    echo $line >> $tmpdir/disk/dvd-cdrom_drive.txt 2>&1
    n=0
  fi
fi
printf "."
done 

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/bdf.txt'>bdf</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/bin/bdf" >> $tmpdir/os_files/bdf.txt
/usr/bin/bdf >> $tmpdir/os_files/bdf.txt
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/df.txt'>df -k </a></td></tr> " >> $WEBLEFT 2>&1
echo "# df -k" >> $tmpdir/os_files/df.txt
df -k >> $tmpdir/os_files/df.txt
printf "."


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1
echo "#mount" >$tmpdir/disk/mount.txt 2>&1
mount -v >>$tmpdir/disk/mount.txt 2>&1
echo "#ls -Al  / " >> $tmpdir/disk/mount.txt 2>&1
ls -Al  / >> $tmpdir/disk/mount.txt 2>&1

printf "\n"

#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1
if [ ! -d $tmpdir/performance ]; then
 mkdir $tmpdir/performance
fi
#
printf "Gathering System Performance Information ... (may take 30 seconds)"

echo "#ps -elf" >> $tmpdir/performance/ps-elf.txt 2>&1
ps -elf >> $tmpdir/performance/ps-elf.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-elf.txt'>ps -elf</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-eax.txt'>ps -eax</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps -aex" >> $tmpdir/performance/ps-eax.txt 2>&1
ps -eax >> $tmpdir/performance/ps-eax.txt 2>&1
printf "."

echo "#swapinfo" >> $tmpdir/performance/swapinfo.txt 2>&1
swapinfo >> $tmpdir/performance/swapinfo.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/swapinfo.txt'>swapinfo</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
echo "#vmstat 1 10" >> $tmpdir/performance/vmstat.txt 2>&1
vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmstat 1 10" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

ps -ef |grep iostat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "#iostat  -t 2 6" >> $tmpdir/performance/iostat.txt 2>&1
iostat  -t 2 6 >> $tmpdir/performance/iostat.txt 2>&1 &
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/iostat.txt'>iostat -t 2 6</a></td></tr> " >> $WEBLEFT 2>&1
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "iostat" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

printf "."
top -b -n2 >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "\n"
#--------------------------------------------------------------------
# GATHERING LOGICAL VOLUME(LVM) INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>LVM INFO</B></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering disk LVM information ..."
if [ ! -d $tmpdir/lvm ]; then
 mkdir $tmpdir/lvm
fi
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/vgdisplay-v.txt'>vgdisplay -v</a></td></tr> " >> $WEBLEFT 2>&1
echo "#vgdisplay -v" >> $tmpdir/lvm/vgdisplay-v.txt  2>&1
(vgdisplay -v ) >>$tmpdir/lvm/vgdisplay-v.txt  2>&1
printf "."


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/lvmtab.txt'>lvmtab</a></td></tr> " >> $WEBLEFT 2>&1
echo "#strings /etc/lvmtab" >> $tmpdir/lvm/lvmtab.txt  2>&1
strings /etc/lvmtab >> $tmpdir/lvm/lvmtab.txt  2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/lvdisplay_vg.txt'>lvdisplay on Log Volumes </a></td></tr> " >> $WEBLEFT 2>&1
echo "#lvdisplay `vgdisplay -v | awk '/LV Name/{ print $3 }'` " >> $tmpdir/lvm/lvdisplay_vg.txt  2>&1
(lvdisplay `vgdisplay -v | awk '/LV Name/{ print $3 }'` ) >> $tmpdir/lvm/lvdisplay_vg.txt  2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/ls-l_vgdirs.txt'>ls -l /dev/vg</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -l /dev/vg*" >> $tmpdir/lvm/ls-l_vgdirs.txt  2>&1
ls -l /dev/vg* >> $tmpdir/lvm/ls-l_vgdirs.txt  2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/ls-lR_dev.txt'>ls -lR /dev</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -lR /dev" >> $tmpdir/lvm/ls-lR_dev.txt  2>&1
ls -lR /dev >> $tmpdir/lvm/ls-lR_dev.txt  2>&1
printf "\n"
#--------------------------------------------------------------------
# GATHERING NETWORKING INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering Network information ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat-a.txt'>netstat -a</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat-rn.txt'>netstat -rn</a></td></tr> " >> $WEBLEFT 2>&1
echo "#netstat -a" >> $tmpdir/networking/netstat-a.txt  2>&1
netstat -a >> $tmpdir/networking/netstat-a.txt 2>&1
echo "#netstat -rn" >> $tmpdir/networking/netstat-rn.txt  2>&1
netstat -rn >> $tmpdir/networking/netstat-rn.txt  2>&1

if [ -f /etc/inetd.conf ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/inetd.conf.txt'>inetd.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inetd.conf  $tmpdir/networking/inetd.conf.txt 2>&1
fi

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/dns.txt'>DNS Info</a></td></tr> " >> $WEBLEFT 2>&1
echo "hostname=$HOSTNAME" >> $tmpdir/networking/dns.txt 2>&1
echo "-----------Hostname------------------------------------" >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME >> $tmpdir/networking/dns.txt 2>&1
echo "-----------Forward lookup------------------------------" >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME |nslookup >> $tmpdir/networking/dns.txt 2>&1
echo "-----------Reverse lookup------------------------------" >> $tmpdir/networking/dns.txt 2>&1
grep -i $HOSTNAME /etc/hosts | awk '{print $1}' |nslookup > $tmpdir/networking/dns.txt 2>&1
echo "-----------Resolv.conf---------------------------------" >> $tmpdir/networking/dns.txt 2>&1
cat /etc/resolv.conf >> $tmpdir/networking/dns.txt 2>&1

echo "-----------ARP-----------------------------------------" >> $tmpdir/networking/dns.txt 2>&1

/usr/sbin/arp -a >> $tmpdir/networking/dns.txt 2>&1

# End HP-UX Function
}


###################################################################################
###################################################################################
###################################################################################
###################################################################################
###################################################################################
###################################################################################
# AIX FUNCTIONS
###################################################################################
###################################################################################
###################################################################################
###################################################################################
###################################################################################
###################################################################################

aix()
{

if [ -f /tmp/.setx ]; then
 set -x
fi
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'>GetConfig Help</a></td></tr> " >> $WEBLEFT 2>&1

mkdir $tmpdir/software > /dev/null 2>&1
mkdir $tmpdir/volumes > /dev/null 2>&1

#--------------------------------------------------------------------
# GATHERING SYSTEM OS INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM OS INFO</B></td></tr> " >> $WEBLEFT 2>&1

#get general aix os info to os.hostname
printf "Gathering OS settings ..."

echo "#date" >> $tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#uname -snlrvmaxup" >> $tmpdir/os_files/uname.txt 2>&1
uname -snlrvmaxup >> $tmpdir/os_files/uname.txt 2>&1
echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
echo "#uname -a" >> $tmpdir/os_files/uname.txt 2>&1
uname -a >> $tmpdir/os_files/uname.txt 2>&1
v=`uname -v`
r=`uname -r`
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>OS Version[AIX v$v.$r]</a></td></tr> " >> $WEBLEFT 2>&1
echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
printf "."
echo "#uptime" > $tmpdir/os_files/uptime.txt 2>&1
uptime >> $tmpdir/os_files/uptime.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uptime.txt'>uptime</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


echo "#oslevel" >> $tmpdir/os_files/oslevel.txt 2>&1 
oslevel >> $tmpdir/os_files/oslevel.txt 2>&1 
echo $LINE >> $tmpdir/os_files/oslevel.txt 2>&1 
echo "#oslevel -r" >> $tmpdir/os_files/oslevel.txt 2>&1 
echo $LINE >> $tmpdir/os_files/oslevel.txt 2>&1 

echo "#oslevel -q" >> $tmpdir/os_files/oslevel.txt 2>&1 
oslevel -q >> $tmpdir/os_files/oslevel.txt 2>&1 
echo "#oslevel -s" >> $tmpdir/os_files/oslevel.txt 2>&1 
oslevel -s >> $tmpdir/os_files/oslevel.txt 2>&1 
echo "#oslevel -qs" >> $tmpdir/os_files/oslevel.txt 2>&1 
oslevel -qs >> $tmpdir/os_files/oslevel.txt 2>&1 
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/oslevel.txt'>OS Level</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


if [ -f /etc/inittab ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/inittab.txt'>inittab</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inittab  $tmpdir/os_files/inittab.txt 2>&1
fi
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/errno.h.txt'>/usr/include/sys/errno.h</a></td></tr> " >> $WEBLEFT 2>&1
cp /usr/include/sys/errno.h $tmpdir/os_files/errno.h.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/os_maintenance_level.txt'>Maintenance Levels</a></td></tr> " >> $WEBLEFT 2>&1


echo "#instfix -i " >> $tmpdir/os_files/os_instfix-i.txt 2>&1
instfix -i  >> $OUTDIR/iflog  2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/os_instfix-i.txt'>instfix -i</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
echo "#Maintenance Levels found from 'instfix -i'" >> $tmpdir/os_files/os_maintenance_level.txt 2>&1
printf "."
grep "All filesets" $OUTDIR/iflog >> $tmpdir/os_files/os_instfix-i.txt 2>&1
printf "."
grep "Not all" $OUTDIR/iflog |grep -v ML >> $tmpdir/os_files/os_instfix-i.txt 2>&1
printf "."
grep "ML" $OUTDIR/iflog >> $tmpdir/os_files/os_instfix-i.txt 2>&1
printf "."
grep "ML" $OUTDIR/iflog |sort -r >> $tmpdir/os_files/os_maintenance_level.txt 2>&1
printf "."
rm -f $OUTDIR/iflog > /dev/null 2>&1 
printf "\n"

printf "Gathering hardware settings ..."
echo "#lscfg" >> $tmpdir/os_files/hardware_lscfg.txt 2>&1
lscfg >> $tmpdir/os_files/hardware_lscfg.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hardware_lscfg.txt'>lscfg</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#lsdev -C" >> $tmpdir/os_files/hardware_lsdev.txt 2>&1
lsdev -C >> $tmpdir/os_files/hardware_lsdev.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hardware_lsdev.txt'>lsdev -C</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

if [ -f /usr/ios/cli/ioscli ]; then
	printf "Gathering data using /usr/ios/cli/ioscli ..."
	echo "#/usr/ios/cli/ioscli lsmap -all" >>$tmpdir/os_files/ioscli_lsmap_all.txt 2>&1
	/usr/ios/cli/ioscli lsmap -all >>$tmpdir/os_files/ioscli_lsmap_all.txt 2>&1
	printf "."

	echo "#/usr/ios/cli/ioscli lsdev -virtual " >>$tmpdir/os_files/ioscli_lsdev_virtual.txt 2>&1
	/usr/ios/cli/ioscli lsdev -virtual >>$tmpdir/os_files/ioscli_lsdev_virtual.txt 2>&1
	printf "."

	echo "# /usr/ios/cli/ioscli ioslevel " >>$tmpdir/os_files/ioscli_ioslevel.txt 2>&1
	/usr/ios/cli/ioscli ioslevel>>$tmpdir/os_files/ioscli_ioslevel.txt 2>&1
	printf "."
	printf "\n"
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ioscli_lsmap_all.txt'>ioscli lsmap -all</a></td></tr> " >> $WEBLEFT 2>&1
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ioscli_lsdev_virtual.txt'>ioscli lsdev -virtual</a></td></tr> " >> $WEBLEFT 2>&1
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ioscli_ioslevel.txt'>ioscli ioslevel</a></td></tr> " >> $WEBLEFT 2>&1
fi

ls /tmp/hacmp* >/dev/null 2>&1
if [ $? = 0 ]; then
	mkdir $tmpdir/os_files/hacmp >/dev/null 2>&1
	cp /tmp/hacmp* $tmpdir/os_files/hacmp >/dev/null 2>&1	
       echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hacmp'>HACMP logs</a></td></tr> " >> $WEBLEFT 2>&1
        cd $tmpdir/os_files/hacmp ; ls |while read file
  	do
  	  mv $tmpdir/os_files/hacmp/$file $tmpdir/os_files/hacmp/$file.txt >/dev/null 2>&1	
	done
fi

echo "Gathering paging info ..."
echo "#lsps -a" >> $tmpdir/os_files/lsps.txt 2>&1
lsps -a >> $tmpdir/os_files/lsps.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lsps.txt'>lsps -a</a></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering filesystem ... "
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1
echo "#mount" >> $tmpdir/disk/mount.txt 2>&1
mount  >> $tmpdir/disk/mount.txt 2>&1
printf "."

echo "#df -Ik" >> $tmpdir/os_files/df-Ik.txt 2>&1
df -Ik >> $tmpdir/os_files/df-Ik.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/df-Ik.txt'>df -Ik</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#ulimit -a" >> $tmpdir/os_files/ulimit-a.txt 2>&1
ulimit -a >> $tmpdir/os_files/ulimit-a.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ulimit-a.txt'>ulimit -a</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"


printf "Gathering additional system files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ps.txt'>ps -eaf</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps -eaf" >> $tmpdir/os_files/ps.txt 2>&1
ps -eaf >> $tmpdir/os_files/ps.txt 2>&1
printf "."

if [ -f /usr/lpp/mmfs/bin/gpfs.snap ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/gpfs.txt'>gpfs.snap </a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/lpp/mmfs/bin/gpfs.snap -a" >> $tmpdir/os_files/gpfs.txt 2>&1
/usr/lpp/mmfs/bin/gpfs.snap -a  >> $tmpdir/os_files/gpfs.txt 2>&1
printf "."
fi

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ps-aewwx.txt'>ps -aewwx</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps aewwx" >> $tmpdir/os_files/ps-aewwx.txt 2>&1
ps aewwx >> $tmpdir/os_files/ps-aewwx.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/svmon-p.txt'>svmon -p</a></td></tr> " >> $WEBLEFT 2>&1
echo "#svmon -P -v -t 10"  >>$tmpdir/os_files/svmon-p.txt 2>&1
svmon -P -v -t 10  >>$tmpdir/os_files/svmon-p.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>Shell Envirnment</a></td></tr> " >> $WEBLEFT 2>&1
echo "#env" >> $tmpdir/os_files/env.txt 2>&1
env >> $tmpdir/os_files/env.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/svmon-uvt.txt'>svmon -uvt</a></td></tr> " >> $WEBLEFT 2>&1
echo "#svmon -U -v -t 10"  >> $tmpdir/os_files/svmon-uvt.txt 2>&1
svmon -U -v -t 10  >> $tmpdir/os_files/svmon-uvt.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/pstat-a.txt'>pstat -a</a></td></tr> " >> $WEBLEFT 2>&1
echo "#pstat -a" >>$tmpdir/os_files/pstat-a.txt 2>&1
pstat -a >>$tmpdir/os_files/pstat-a.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/rc.d.txt'>ls /etc/rc.d</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -AlR /etc/rc.d" >> $tmpdir/os_files/rc.d.txt 2>&1
ls -AlR /etc/rc.d >> $tmpdir/os_files/rc.d.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lssrc-a.txt'>lssrc -a</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lssrc -a" >> $tmpdir/os_files/lssrc-a.txt 2>&1
lssrc -a >> $tmpdir/os_files/lssrc-a.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/last_boot_device.txt'>bootinfo -b</a></td></tr> " >> $WEBLEFT 2>&1
echo "#bootinfo -b" >> $tmpdir/os_files/last_boot_device.txt 2>&1
bootinfo -b >> $tmpdir/os_files/last_boot_device.txt 2>&1
printf "\n"

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/usr.txt'>ls - Al /usr</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /usr" >> $tmpdir/os_files/usr.txt 2>&1
ls -Al /usr >> $tmpdir/os_files/usr.txt 2>&1
printf "\n"


# Misc AIX commands
ioslevel >> $tmpdir/os_files/ioslevel.txt 2>&1
lslparinfo >>$tmpdir/os_files/lslparinfo.txt 2>&1
lsmap -all >>$tmpdir/os_files/lsmap-all.txt 2>&1
lparstat >>$tmpdir/os_files/lparstat.txt 2>&1
lsnports >>$tmpdir/os_files/lsnports.txt 2>&1
lsmap -all -npiv >>$tmpdir/os_files/lspa-all_npiv.txt 2>&1
lsdev -dev vfchost* >>$tmpdir/hba/lsdev-vfchost.txt 2>&1
lsdev -dev fcs* >>$tmpdir/hba/lsdev-fcs.txt 2>&1
lsdev -dev fcs* -vpd >>$tmpdir/hba/lsdev-fcs-vpd.txt 2>&1
#for hba in `lsdev -Cc adapter | grep fcs  | awk '{print $1}'`^Jdo^Jfcstat $hba^Jdone >> $tmpdir/hba/hba_fcstat.txt 2>&1
for hba in `lsdev -Cc adapter | grep fcs  | awk '{print $1}'`
do
fcstat $hba
done >> $tmpdir/hba/hba_fcstat.txt 2>&1

#-------------------------------------------------------------
printf "Gathering system configuration files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc'>/etc conf files</a></td></tr> " >> $WEBLEFT 2>&1
DIR=/etc
OUTPUT=$tmpdir/etc
TAR=/tmp/_gsctub.tar
LOG=$tmpdir/etc/tar_output.log.txt

if [ ! -d $OUTPUT ]; then
  mkdir $OUTPUT >/dev/null 2>&1
fi
if [ ! -f $LOG ]; then
  rm $LOG >/dev/null 2>&1
fi
if [ ! -f $TAR ]; then
  rm $TAR >/dev/null 2>&1
fi

echo "#cd $DIR ; find . -type f -name '*.conf' |xargs tar -cvf $TAR " >> $LOG 2>&1
cd $DIR ; find . -type f -name "*.conf" |xargs tar -cvf $TAR  >> $LOG 2>&1

echo "#cd $OUTPUT; tar -xvf $TAR  >/dev/null 2>&1" >> $LOG 2>&1
cd $OUTPUT; tar -xvf $TAR  >>$LOG 2>&1
rm -f $TAR >/dev/null 2>&1

for File in "$OUTPUT/*"
  do
   find $File -type f |while read change
    do
      printf "."
      mv ${change} ${change}.txt > /dev/null 2>&1
    done
 done
 printf "\n"
#-------------------------------------------------------------

#--------------------------------------------------------------------
# GATHERING SOFTWARE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SOFTWARE</B></td></tr> " >> $WEBLEFT 2>&1
printf  "Gathering java information ..."
echo "#java -version" >> $tmpdir/software/java.txt 2>&1
java -version >> $tmpdir/software/java.txt 2>&1
echo $LINE >> $tmpdir/software/java.txt 2>&1
echo "ls -al /usr/ |grep java" >> $tmpdir/software/java.txt 2>&1
ls -al /usr/ |grep java >> $tmpdir/software/java.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/java.txt'>Java Info</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

printf "Gathering detailed software settings ..."

echo "#perl -v" >> $tmpdir/software/perl.txt 2>&1
perl -v >> $tmpdir/software/perl.txt 2>&1
echo $LINE  >> $tmpdir/software/perl.txt 2>&1
echo "#ls -al /usr/bin/perl" >> $tmpdir/software/perl.txt 2>&1
ls -al /usr/bin/perl >> $tmpdir/software/perl.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/perl.txt'>Perl Info</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#gcc -v " >$tmpdir/software/gcc.txt 2>&1
(gcc -v)  >$tmpdir/software/gcc.txt 2>&1
if [ $? = 0 ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/gcc.txt'>GCC Info</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/software_lslpp-L.txt'>lslpp -L</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lslpp -L" >> $tmpdir/software/software_lslpp-L.txt 2>&1
lslpp -L >> $tmpdir/software/software_lslpp-L.txt 2>&1
printf "."

grep  "bos.rte.odm" $tmpdir/software/software_lslpp-L.txt >> $TMPVAR 2>&1
if [ $? = 0 ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/odm_level.txt'>ODM level</a></td></tr> " >> $WEBLEFT 2>&1
cat $TMPVAR >> $tmpdir/os_files/odm_level.txt 2>&1
fi

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/hitachi.software.txt'>HDS Software</a></td></tr> " >> $WEBLEFT 2>&1
echo "#egrep -i 'htn|hdv|hitach|htm' $tmpdir/software/software_lslpp-L.txt" >> $tmpdir/software/hitachi.software.txt 2>&1
echo $LINE >> $tmpdir/software/hitachi.software.txt 2>&1
grep -i hitachi  $tmpdir/software/software_lslpp-L.txt >> $tmpdir/software/hitachi.software.txt 2>&1
echo $LINE >> $tmpdir/software/hitachi.software.txt 2>&1
printf "."

grep -i "dynamic link manager" $tmpdir/software/software_lslpp-L.txt >>$tmpdir/software/hitachi.software.txt 2>&1
printf "."

grep -i "hitachi.aix.support.rte" $tmpdir/software/software_lslpp-L.txt >> $TMPVAR 2>&1
if [ $? = 0 ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/hds_odm_level.txt'>HDS ODM level</a></td></tr> " >> $WEBLEFT 2>&1
cat $TMPVAR >> $tmpdir/software/hds_odm_level.txt 2>&1
fi
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/lslpp_driver_levels.txt'>lslpp driver levels</a></td></tr> " >> $WEBLEFT 2>&1
grep devices.pci $tmpdir/software/software_lslpp-L.txt |egrep i 'rte|com|adapter|pci|fibre|fc'  >>$tmpdir/software/lslpp_driver_levels.txt 2>&1
 
printf "."
grep -i hacmp $tmpdir/software/software_lslpp-L.txt > $OUTDIR/.ha
if [ $? = 0 ]; then
mv $OUTDIR/.ha $tmpdir/software/hacmp.txt > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/hacmp.txt'>HACMP version</a></td></tr> " >> $WEBLEFT 2>&1
else
rm -f $OUTDIR/.ha > /dev/null 2>&1
fi
printf "\n"

printf "Gathering a list of files in /opt ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>ls /opt</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /opt" >> $tmpdir/software/ls.opt.txt 2>&1
ls -Al /opt  >> $tmpdir/software/ls.opt.txt 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING LUNSTAT INFO
#--------------------------------------------------------------------

lunstat > /dev/null 2>&1
if [ $? = 0 ] ; then
 printf "/n"
 echo "Found Lunstat ..."
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>LUNSTAT</B></td></tr> " >> $WEBLEFT 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lunstat/lunstat.txt'>Lunstat output</a></td></tr> " >> $WEBLEFT 2>&1
 mkdir $tmpdir/lunstat
 echo "#lunstat -ts" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ts 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -ta" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -ta 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tp" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tp 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -tr" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -tr 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "."
 echo "#lunstat -th" 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 lunstat -th 1>> $tmpdir/lunstat/lunstat.txt 2>&1
 echo $LINE >> $tmpdir/lunstat/lunstat.txt 2>&1
 printf "\n"
fi

#------------------------------------------------------
checkfirm()
{
if [ -f /tmp/.setx ]; then
 set -x
fi
      DIR=$tmpdir/hba
      FILE=$2
      a=`grep "Network Address" $FILE |awk -F. '{print $14}'`
      b=`grep "Device Specific.(ZA)" $FILE | awk -F. '{print $10"."$11}'`
      c=`grep "Device Specific.(ZB)" $FILE | awk -F. '{print $10"."$11}' |cut -dD -f2`
      d=`grep "CONNECTED" $FILE |awk '{print $2}'`
      e=`grep "init_link" $FILE |awk '{print $2}'`
#------------------------------------------------------
      echo $c |egrep "2.10X8" >/dev/null 2>&1
      if [ $? = 0 ]; then
       type=5759
      fi

      echo $c |egrep "1.90A4|1.90X13|1.91A5" > /dev/null 2>&1
      if [ $? = 0 ]; then
       type=5716
      fi

      echo $c |egrep "2.71A2" > /dev/null 2>&1
      if [ $? = 0 ]; then
       type=5774
      fi

      echo $c |egrep "1.91A5|1.92A1|1.91X4|1.90X2|1.81X3|1.81X1|1.00X5" > /dev/null 2>&1
      if [ $? = 0 ]; then
       type=6239
      fi

      echo $c |egrep "3.30X1|3.22A1" > /dev/null 2>&1
      if [ $? = 0 ]; then
       type=6227
      fi

      echo $c |egrep "3.91A1|3.91A3|3.91X4|3.82A1|3.90X3|3.93A0" > /dev/null 2>&1
      if [ $? = 0 ]; then
       type=6228
      fi

#------------------------------------------------------
      printf "[Adapter]:\t$1" >> $DIR/hba_summary.txt 2>&1
      printf "\n[HBA Type]:\t$type" >> $DIR/hba_summary.txt 2>&1
      printf "\n[WWN]:\t$a" >> $DIR/hba_summary.txt 2>&1
#      printf "\n[Driver Version]:\t$b " >> $DIR/hba_summary.txt 2>&1
      printf "\n[Firmware Version]:\t$c " >> $DIR/hba_summary.txt 2>&1
      printf "\n[SAN Attached via]:\t$d " >> $DIR/hba_summary.txt 2>&1
      printf "\n[loop/p2p mode]:\t$e" >> $DIR/hba_summary.txt 2>&1
      printf "\n----------------------------------------------------------\n" >> $DIR/hba_summary.txt 2>&1
}

checkdisk()
{
if [ -f /tmp/.setx ]; then
 set -x
fi
      DIR=$tmpdir/disk
      FILE=$2
      a=`grep "Device Specific.(Z1)" $FILE |awk -F. '{print $10}`
      b=`grep "ww_name" $FILE |awk '{print $2}`
      c=`grep "queue_depth" $FILE |awk '{print $2}`
      d=`grep "q_type" $FILE|awk '{print $2}`
      e=`grep "rw_timeout" $FILE |awk '{print $2}'`
      f=`grep "pvid" $FILE |awk '{print $2}'`
      printf "[DISK]:\t$1" >> $DIR/disk_summary.txt 2>&1
      printf "\n[LDEV&PORT]:\t$a " >> $DIR/disk_summary.txt 2>&1
      printf "\n[WWN HDS SUBSYSTEM]:\t$b" >> $DIR/disk_summary.txt 2>&1
      printf "\n[Queue Depth]:\t$c" >> $DIR/disk_summary.txt 2>&1
      printf "\n[Queue Type]:\t$d " >> $DIR/disk_summary.txt 2>&1
      printf "\n[Timeout]:\t$e " >> $DIR/disk_summary.txt 2>&1
      printf "\n[PVID]:\t$f " >> $DIR/disk_summary.txt 2>&1
      printf "\n----------------------------------------------------------\n" >> $DIR/disk_summary.txt 2>&1
}
  
 
####################################################################################################
#    HBA README FILE
###################################################################################################
echo "
===================================================================================================
THIS IS A README FILE THAT IS FOR REFERENCE AND IS NOT COLLECTED FROM THE HOST. IT IS USED
FOR REFERENCE IN TROUBLESHOOTING AND VERIFYING HOST/HBA INFO.
===================================================================================================
GENERAL OVERVIEW
===================================================================================================
All of this data should be in the hba_summary.txt and the disk_summary.txt.


To doublecheck the results, here are some of the most common things to look for in the current AIX getconfig script.
 
First we take a look at the HBA's installed in the system.
lsdev -C | grep 'fcs[0-9] ' |
fcs0 Available 11-08 FC Adapter
fcs1 Available 21-08 FC Adapter
shows 2 fibre adapters fcs0 in slot 11-08 and fcs1 in slot 21-08. Those location codes are important in determining which of the 2 adapters is malfunctioning.
 
Next we look at the properties of one of those adapters.
lscfg -vl fcs0
DEVICE LOCATION DESCRIPTION
        
fcs0 11-08 FC Adapter
 
Part Number.................03N2452
EC Level....................D
Serial Number...............1C1400A13C
Manufacturer................001C
FRU Number..................09P0102
Network Address.............10000000C92A94B0
^^^^WWN of HBA^^^
Device Specific.(Z8)........20000000C92A94B0
Device Specific.(Z9)........CS3.82A0 
Device Specific.(ZA)........C1D3.82A0
Device Specific.(ZB)........C2D3.82A0
^^^firmware/driver ver^^ (ex. firmware ver 3.82A0)
^^^The device specific Z9, ZA, and ZB contain the firmware version of the HBA, usually the last 6 characters 
Device Specific.(YL)........U0.1-P1-I1/Q1
 
 
lsattr -El fcs0
 
pref_alpa 0x1 Preferred AL_PA True
sw_fc_class 2 FC Class for Fabric True
init_link al INIT Link flags True
^^interface mode (loop/point)^^
 
Now let's look at the disks.
lsdev -Cc disk
hdisk0 Available 40-60-00-4,0 16 Bit LVD SCSI Disk Drive
hdisk1 Available 40-61-00-8,0 16 Bit LVD SCSI Disk Drive
hdisk2 Defined 21-08-01 Other FC SCSI Disk Drive
hdisk3 Defined 21-08-01 Other FC SCSI Disk Drive
hdisk4 Defined 21-08-01 Other FC SCSI Disk Drive
hdisk5 Available 11-08-01 Other FC SCSI Disk Drive
hdisk6 Available 11-08-01 Other FC SCSI Disk Drive
 
Again note the location codes. This shows that we have 2 internal disks at 40-6*, 3 luns on the fcs1 adapter, and 2 luns on the fcs0 adapter. Note that hdisk2-4 show defined. That means that these disks were detected at one point but are no longer available (bad HBA, bad path, unmapped from subsystem).
 
OK let's look at the properties of a disk.
lscfg -vl hdisk3
DEVICE LOCATION DESCRIPTION
        
hdisk3 21-08-01 Other FC SCSI Disk Drive
 
Manufacturer................HITACHI 
Machine Type and Model......OPEN-9 
ROS Level and ID............30313136
Serial Number...............0400A0BE
Device Specific.(Z0)........0000032273000002
Device Specific.(Z1)........0105 2A ....
^^Ldev & port on the subsystem this one is 1:05 on port 2A^^ 
 
lsattr -El hdisk3
scsi_id 0x230513 SCSI ID 
lun_id 0x6000000000000 Logical Unit Number ID 
ww_name 0x500060e802a0be10 FC World Wide Name 
^^^ WWN of the HDS subsystem ^^^
pvid 000f115f86e224360000000000000000 Physical volume identifier 
queue_depth 5 Queue DEPTH 
^^^ Remember that all luns on a port must have same depth ^^^
q_type simple Queuing TYPE
^^^ Queue type should always be simple for fibre ^^^
rw_timeout 60 READ/WRITE time out value
^^^ Timeout must be 60 ^^^
 
Now let's make sure that we have PVID's in the right place
lspv
hdisk0 000f115f06e4513c rootvg 
hdisk1 000f115fdc5d2cdf rootvg 
hdisk2 000f115f86df1a9e homevg 
hdisk3 000f115f86e22436 optvg 
hdisk4 000f115f86e27856 None 
hdisk5 none None 
hdisk6 none None 
vpath0 000f115f86e27856 None 
vpath1 none None 
vpath2 none None 
===================================================================================================
HBA ADAPTER TYPES:
===================================================================================================

These are the characteristics for the following host bus adapters:


-------------------------------------
5774 (Feature Code 5774) 
Part number and FRU number: 10N7255 
Device Specific.(Z9)........ZS2.71A2 

-------------------------------------

5773 (Feature Code 5773) 
Part number and FRU number: 10N7249 
Device Specific.(Z9)........ZS2.71A2 

-------------------------------------

5759
part number: 03N5029 (FRU 03N5029)
IBM pSeries 4 Gigabit PCI-X 2.0 Dual Port Fiber Channel Adapter. Each port of this adapter is fully independent with it's own firmware image. When updating firmware on this adapter, both ports should be updated. 
Device Specific.(Z9)........BS2.10X8 
Device specific (Z9) (Firmware level)=BS2.10X8 (GA level) 
Device Specific.(Z9)........BS2.10X2 (LA level) 

-------------------------------------

5716 (Feature code 280B)
Part Number: 03N6441 
03N7067 
Part Number: 80P4543 (FRU 80P4544) (2gb adapter) 
Part Number: 03N7069 (FRU 03N7069) (2gb adapter) 
Device specific (Z9) (Firmware Level)=1.90X13
1.90A4
1.91A5

-------------------------------------
6239
Part Number: 00P4295 (FRU 00P4297) (2gb adapter)
Device Specific (Z9) (Firmware Level) =1.91x4
Part Number: 80p6415 (FRU 80p6416)
1.92A1 (new 10/07) IBM for fixing cmd timeouts.
READ CAUTIONS AND IMPORTANT NOTES (SECTION 4.0) PRIOR TO INSTALLING THIS FIRMWARE LEVEL 
-Fix FC_DISK_ERR (command timeout ) command not processed due to a race condition clearing interrupts. 
-Fix transmit hang that results in out of resources condition. 

1.81X3
1.90X2
1.81X1
1.00X5

-------------------------------------
6227
Part Number: 09P4038 (1gb adapter)
09P1162
03N4167
24L0023
Device Specific (Z9) (Firmware level) = 3.30X1
3.22A1 


Note: IBM has pulled support for firmware 1.90X2. ( no longer valid)
Firmware 1.90x2 was pulled do to disk cmd time out errors on 6239 HBA 
Firmware 1.91x4 has been replaced with 1.91A5 for cmd timeout errors also on 6239 HBA(NEW). 
Note:FC 6228 Firmware LEVEL 3.91A3 has been pulled due to the following regression:
On FC adapters with black connectors:

-------------------------------------
6228
Part Number: 03N2452 (FRU 09P0102) (2gb adapter) 
09P5079 (FRU 09P5080) 
00P2995 (FRU 00P2996) 
00P4494 (FRU 00P4495)  
80P4383 (FRU 80P4384)
New driver 11/1 = 3.93A0  From IBM website, 

* * * * * * * * * * * 
This is the Current  Level of Microcode for The IBM pSeries and iSeries (running AIX or Linux) Gigabit Fiber Channel PCI Adapter for 64 bit bus, which replaces Revision Level 3.82a1, 3.90X3 and 3.91A3, 3.91A1. 
  
Note: Firmware LEVEL 3.91A3 has been pulled due to the following regression:
On FC adapters with black connectors:

When attaching to certain disk subsystems and switches, the laser will not turn on and the link is not established 
* * * * * * * * * * * * 
Device Specific (Z9) (Firmware level) = 3.91x4 
3.91A1
3.82A1
3.90X3 
-------------------------------------





">> $tmpdir/hba/README.HBA.txt 2>&1

################################################################################################

#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA</B></td></tr> " >> $WEBLEFT 2>&1
QDepth README_queue_depth.txt
QDepthReadme
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/README.HBA.txt'>HBA README</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba_summary.txt'>HBA Summary</a></td></tr> " >> $WEBLEFT 2>&1

echo "#lslpp -l devices.pci.df* |grep Adapter|egrep com|rte |sort"  >> $tmpdir/hba/hba_driver_summary.txt 2>&1
lslpp -l devices.pci.df* |grep Adapter|egrep "com|rte" |sort  >> $tmpdir/hba/hba_driver_summary.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba_driver_summary.txt'>HBA Driver Info</a></td></tr> " >> $WEBLEFT 2>&1

outfile=$OUTDIR/.hba
printf "Gathering scsi adapter settings ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba_fcstat.txt'>HBA FCSTAT</a></td></tr> " >> $WEBLEFT 2>&1
VAR=`lsdev -Cc adapter | grep -i scsi | awk '{print $1}'`
for adapter in $VAR
do
  printf "\n\n#lscfg -vl $adapter"  >> $outfile 2>&1
  lscfg -vl $adapter  >> $outfile 2>&1
  echo "#lsattr -El $adapter"  >> $outfile 2>&1
  lsattr -El $adapter >> $outfile 2>&1
  checkfirm $adapter $outfile
  printf "."
  cat $outfile >> $tmpdir/hba/hba_adapters_scsi.txt 2>&1 
  rm -f $outfile > /dev/null 2>&1
done
printf "\n"

echo "Checking for HBA's ..."

#get emulex adapters
lsdev -C |grep -i lpfc > /dev/null 2>&1
if [ $? = 0 ]; then
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba_adapters_lpfc.txt'>HBA Emulex LPFC</a></td></tr> " >> $WEBLEFT 2>&1
 printf "Gathering emulex adapter settings ..."
 VAR=`lsdev -C |grep lpfc |grep -v 'lpfc[0-9]\.[0-9]' |awk '{print $1}'`
 for adapter in $VAR
  do
   echo "#lscfg -vl $adapter" >> $outfile 2>&1
   lscfg -vl $adapter >> $outfile 2>&1
   echo "#lsattr -El  $adapter" >> $outfile 2>&1
   lsattr -El  $adapter >> $outfile 2>&1
   checkfirm $adapter $outfile
   printf "."
   cat $outfile >> $tmpdir/hba/hba_adapters_lpfc.txt 2>&1
   rm -f $outfile;
 done
 printf "\n"
fi

#get IBM AIX adapters
lsdev -C |grep ^fcs[0-9]  > /dev/null 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba_adapters_fcs.txt'>HBA Attributes </a></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering IBM AIX adapter settings ..."
VAR=`lsdev -C |grep ^fcs[0-9] |awk '{print $1}'`
for adapter in $VAR
do
  echo "#lscfg -vl $adapter" >> $outfile 2>&1
  lscfg -vl $adapter >> $outfile 2>&1
  echo "#lsattr -El $adapter" >> $outfile 2>&1
  lsattr -El  $adapter >> $outfile 2>&1
  number=`echo $adapter |cut -c 4`
  echo "#lsattr -El fscsi$adapter" >> $outfile 2>&1
  lsattr -El fscsi$number >> $outfile 2>&1
  checkfirm $adapter $outfile
  printf "." 
  cat $outfile >> $tmpdir/hba/hba_adapters_fcs.txt 2>&1
  rm -f $outfile;
done
printf "."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lsdev-C_fscsi.txt'>lsdev -C |grep fscsi</a></td></tr> " >> $WEBLEFT 2>&1
echo "lsdev -C |grep fscsi" >> $tmpdir/hba/lsdev-C_fscsi.txt 2>&1
lsdev -C |grep fscsi >> $tmpdir/hba/lsdev-C_fscsi.txt 2>&1

echo "#lsnports" >> $tmpdir/hba/lsnports.txt 2>&1
/usr/ios/cli/ioscli lsnports >> $tmpdir/hba/lsnports.txt 2>&1
printf "\n"
fi



#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_summary.txt'>DISK Summary</a></td></tr> " >> $WEBLEFT 2>&1

# get disk info
outfile=$OUTDIR/.disk
printf "Gathering disk information ..."
ls -Al /dev >> $tmpdir/disk/ls.dev.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/ls.dev.txt'>ls /dev</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

lspv >> $tmpdir/disk/disk_lspv.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_lspv.txt'>lspv</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

lspath >> $tmpdir/disk/disk_lspath.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_lspath.txt'>lspath</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

lsdev -Cc disk >> $tmpdir/disk/disk_lsdev.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_lsdev.txt'>lsdev -Cc disk</a></td></tr> " >> $WEBLEFT 2>&1

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lsdev_cl.txt'>lsdev -C -l disk</a></td></tr> " >> $WEBLEFT 2>&1

lsdev -virtual >/tmp/lv 2>&1
if [ $? = 0 ]; then
 mv /tmp/lv $tmpdir/disk/disk_lsdev-virtual.txt 2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_lsdev-virtual.txt'>lsdev -virtual</a></td></tr> " >> $WEBLEFT 2>&1
else
 rm /tmp/lv >/dev/null 2>&1
fi

qtmp=$tmpfile/qtmp.out
qfile=$tmpdir/disk/disk_queue_depth.txt 2>&1
VAR=`lspv |awk '{print $1}'`
SMLINE="...................................................................."
for disk in $VAR
do
  echo $LINE >> $outfile 2>&1
  echo "DETAILS FOR DISK $disk" >> $outfile 2>&1
  echo $LINE >> $outfile 2>&1
  echo "#lspv $disk" >> $outfile 2>&1
  lspv $disk >> $outfile 2>&1
  printf "." 

  echo $SMLINE >> $outfile 2>&1
  echo "#lsdev -C -l $disk" > $tmpdir/disk/lsdev_cl.txt 2>&1
  echo "#lsdev -C -l $disk" >> $outfile 2>&1
  lsdev -C -l $disk >> $tmpdir/disk/lsdev_cl.txt 2>&1
  cat $tmpdir/disk/lsdev_cl.txt  >> $outfile 2>&1
  echo $SMLINE >> $outfile 2>&1
  printf "." 

  echo $SMLINE >> $outfile 2>&1
  echo "#lspv -l $disk" >> $outfile 2>&1
  lspv -l $disk >> $outfile 2>&1
  echo $SMLINE >> $outfile 2>&1
  printf "." 

  echo $SMLINE >> $outfile 2>&1
  echo "#lscfg -vl $disk" >> $outfile 2>&1
  lscfg -vl $disk >> $outfile 2>&1
  echo $SMLINE >> $outfile 2>&1
  printf "." 

  lsattr -El $disk >> $qtmp 2>&1
  qd=`grep queue_depth $qtmp|awk '{print $2}'`
  echo $SMLINE >> $outfile 2>&1
  echo "Queue Depth for $disk = $qd" >> $qfile 2>&1
  cat $qtmp >> $outfile 2>&1
  echo $SMLINE >> $outfile 2>&1
  rm -f  $qtmp >/dev/null 2>&1
  printf "." 

  checkdisk $disk $outfile
  printf "." 
  cat $outfile >> $tmpdir/disk/disk_all_lsdev.txt 2>&1
  rm -f $outfile > /dev/null 2>&1
done 
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_all_lsdev.txt'>Detailed Disk Info</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lspath.txt'>lspath</a></td></tr> " >> $WEBLEFT 2>&1

echo "lspath -F name:connection:parent:path_status:status" >> $tmpdir/disk/lspath.txt 2>&1
lspath -F"name:connection:parent:path_status:status" >> $tmpdir/disk/lspath.txt 2>&1

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk_queue_depth.txt'><font color='#FF0000'><b>Queue Depth for hdisk(s)</font></b></a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING LOGICAL VOLUME (LVM) INFO
#--------------------------------------------------------------------
printf "Gathering logical volume info ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>LVM INFO</B></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/volumes/volumes_rootvg.txt'>lsvg rootvg -l</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lsvg rootvg -l" >> $tmpdir/volumes/volumes_rootvg.txt 2>&1
lsvg rootvg -l >> $tmpdir/volumes/volumes_rootvg.txt 2>&1
printf "."


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/volumes/volumes_lsvg-o.txt'>lsvg -o</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lsvg -o" >> $tmpdir/volumes/volumes_lsvg-o.txt 2>&1
lsvg -o >> $tmpdir/volumes/volumes_lsvg-o.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/volumes/volumes_lsvg.txt'>lsvg</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lsvg" >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
lsvg >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
printf "\n"
printf "Gathering volume group info using lsvg ..."
VAR=`lsvg -o`
for vg in $VAR
do
  echo "#lsvg $vg"    >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  lsvg $vg    >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  echo "#lsvg -l $vg" >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  lsvg -l $vg >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  echo "#lsvg -p $vg" >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  lsvg -p $vg >> $tmpdir/volumes/volumes_lsvg.txt 2>&1
  printf "."
done
printf "\n"


echo "Extracting volume group info from lslv and lsvg ..."
lsvg | while read i
 do
   lsvg -l $i | tail -n +3 | while read j junk
    do
     printf "."
     echo $LINE  >> $tmpdir/volumes/volumes_lslv.txt 2>&1
     echo "#lslv $j " >> $tmpdir/volumes/volumes_lslv.txt 2>&1
     echo $LINE  >> $tmpdir/volumes/volumes_lslv.txt 2>&1
     lslv $j  >> $tmpdir/volumes/volumes_lslv.txt 2>&1
   done
done
printf "\n"



#--------------------------------------------------------------------
# GATHERING ERROR LOGS
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering system error logs ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/errpt-a.txt'>errpt -a</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/errpt.txt'>errpt</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/errpt_summary.txt'>errpt summary</a></td></tr> " >> $WEBLEFT 2>&1
echo "#errpt -a" >> $tmpdir/messages/errpt-a.txt 2>&1
errpt -a >> $tmpdir/messages/errpt-a.txt 2>&1
printf "."
echo "#errpt" >> $tmpdir/messages/errpt.txt 2>&1
errpt  >> $tmpdir/messages/errpt.txt 2>&1
printf "\n"
echo "Extracting summary data from errpt ..."
echo "#cat $tmpdir/messages/errpt-a.txt |egrep '\-\-\-\-|LABEL|Resource|'" >> $tmpdir/messages/errpt_summary.txt 2>&1
cat $tmpdir/messages/errpt-a.txt |egrep "\-\-\-\-|LABEL|Resource|Specific.(Z1)" >> $tmpdir/messages/errpt_summary.txt 2>&1

#--------------------------------------------------------------------
# GATHERING HACMP INFO
#--------------------------------------------------------------------

echo "Looking for HACMP ..."
if [ -e /usr/sbin/cluster/utilities ] ; then
 mkdir $tmpdir/hacmp
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HACMP</B></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hacmp/hacmp.txt'>HACMP info</a></td></tr> " >> $WEBLEFT 2>&1
 printf "Found HACMP, gathering data ..." 
 /usr/sbin/cluster/utilities/cllscf >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "."
 /usr/sbin/cluster/utilities/cllsclstr >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "."
 /usr/sbin/cluster/utilities/cllsnw >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "."
 /usr/sbin/cluster/utilities/cllsif >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "."
 /usr/sbin/cluster/utilities/cllsres >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "."
 /usr/sbin/cluster/utilities/cllsvg >> $tmpdir/hacmp/hacmp.txt 2>&1
 printf "\n"
fi


#--------------------------------------------------------------------
# GATHERING NETWORKING INFO
#--------------------------------------------------------------------


echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING</B></td></tr> " >> $WEBLEFT 2>&1
echo "Gathering netstat info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat.txt'>netstat info</a></td></tr> " >> $WEBLEFT 2>&1
echo "#netstat -rn" >> $tmpdir/networking/netstat.txt 2>&1
netstat -rn >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
echo "netstat -a" >> $tmpdir/networking/netstat.txt 2>&1
netstat -a >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1


echo "Gathering DNS info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/dns.txt'>DNS Info</a></td></tr> " >> $WEBLEFT 2>&1
echo "hostname=$HOSTNAME" >> $tmpdir/networking/dns.txt 2>&1
echo "------------Hostname-----------------"  >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME  >> $tmpdir/networking/dns.txt 2>&1
echo "------------Forward------------------"  >> $tmpdir/networking/dns.txt 2>&1
echo $HOSTNAME |nslookup >> $tmpdir/networking/dns.txt 2>&1
echo "------------Reverse------------------"  >> $tmpdir/networking/dns.txt 2>&1
grep -i `hostname` /etc/hosts |awk '{print $1}' |nslookup >> $tmpdir/networking/dns.txt 2>&1

echo "hostname=$HOSTNAME" >> $tmpdir/getconfig_v${VERSION}_${HOSTNAME}.txt 2>&1


#------------------------------
#echo "Gathering rpcinfo ..."
#echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/rpcinfo.txt'>rpcinfo -p</a></td></tr> " >> $WEBLEFT 2>&1
#echo "#rpcinfo -p" >> $tmpdir/networking/rpcinfo.txt 2>&1
#rpcinfo -p >> $tmpdir/networking/rpcinfo.txt 2>&1
#------------------------------

echo "Gathering interface info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/ifconfig-a.txt'>ifconfig -a</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ifconfig -a " >> $tmpdir/networking/ifconfig-a.txt 2>&1
ifconfig -a >> $tmpdir/networking/ifconfig-a.txt 2>&1

printf "Gathering /etc/services & /etc/hosts ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/services.txt'>/etc/services</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/services $tmpdir/networking/services.txt 2>&1
printf "."

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/hosts $tmpdir/networking/hosts.txt 2>&1

if [ -f /etc/inetd.conf ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/inetd.conf.txt'>inetd.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inetd.conf  $tmpdir/networking/inetd.conf.txt 2>&1
fi
printf "."


printf "\n"

#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
printf "Gathering performance info ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1
ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering basic performance info ..."
echo "#vmstat 1 10" >> $tmpdir/performance/vmstat.txt 2>&1 
vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmstat 1 10" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

ps -ef |grep iostat|grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/iostat.txt'>iostat</a></td></tr> " >> $WEBLEFT 2>&1
echo "#iostat 2 6" >> $tmpdir/performance/iostat.txt2>&1
iostat 2 6 >> $tmpdir/performance/iostat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "iostat 2 6" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi


ps -ef |grep vmo |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmo.txt'>vmo -L</a></td></tr> " >> $WEBLEFT 2>&1
echo "#vmo -L" >> $tmpdir/performance/vmo.txt 2>&1
/usr/sbin/vmo -L >> $tmpdir/performance/vmo.txt 2>&1
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmo -L" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

ps -ef |grep ioo |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ioo.txt'>ioo -L</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ioo -L" >> $tmpdir/performance/ioo.txt 2>&1
/usr/sbin/ioo -L >> $tmpdir/performance/ioo.txt 2>&1
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "ioo -L" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

printf "."
top -b -n2 >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "\n"

#--------------------------------------------------------------------
# GATHERING KERNEL INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering Kernel info ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/kernel_version.txt'>Kernel Version</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/ls.stand.txt'>ls /stand</a></td></tr> " >> $WEBLEFT 2>&1
echo "#prtconf -k" >> $tmpdir/kernel/kernel_version.txt 2>&1
echo "#ls -alR /stand" >> $tmpdir/kernel/ls.stand.txt 2>&1
prtconf -k >> $tmpdir/kernel/kernel_version.txt 2>&1


# END AIX functions

}

###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
# LINUX FUNCTIONS
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################

linux()
{

if [ -f /tmp/.setx ]; then
 set -x
fi
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'>GetConfig Help</a></td></tr> " >> $WEBLEFT 2>&1

mkdir $tmpdir/boot > /dev/null 2>&1

#--------------------------------------------------------------------
# GATHERING SYSTEM INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering Detailed System Information ..."

echo "#uname -a" >> $tmpdir/os_files/uname.txt 2>&1
uname -a >> $tmpdir/os_files/uname.txt 2>&1
echo "#uname -m" >> $tmpdir/os_files/uname-m.txt 2>&1
uname -m >> $tmpdir/os_files/uname-m.txt 2>&1

if [ -f /proc/version ]; then
 echo "#cat /proc/version"  >> $tmpdir/os_files/uname.txt 2>&1
 cat /proc/version  >> $tmpdir/os_files/uname.txt 2>&1
fi
if [ -f /proc/cpuinfo ]; then
 echo "#cat /proc/cpuinfo"  >> $tmpdir/os_files/uname.txt 2>&1
 cat /proc/cpuinfo  >> $tmpdir/os_files/uname.txt 2>&1
fi

if [ -f /etc/redhat-release ]; then
 echo "#cat /etc/redhat-release" >>$tmpdir/os_files/redhat-release.txt  2>&1
 cat /etc/redhat-release >>$tmpdir/os_files/redhat-release.txt  2>&1
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/redhat-release.txt'>/etc/redhat-release</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."
fi

echo "#date" >>$tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
v=`uname -rv`
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>OS Version[$v]</a></td></tr> " >> $WEBLEFT 2>&1
h=`uname -m`
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname-m.txt'>Processor[$h]</a></td></tr> " >> $WEBLEFT 2>&1


echo "#df -k" >> $tmpdir/os_files/df.txt 2>&1
df -k >> $tmpdir/os_files/df.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/df.txt'>df -k</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


if [ -f /etc/sysconfig/hwconf ]; then
 echo "#cat /etc/sysconfig/hwconf" >> $tmpdir/os_files/hwconf.txt
 cat /etc/sysconfig/hwconf >> $tmpdir/os_files/hwconf.txt
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hwconf.txt'>/etc/hwconf</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."
fi 

if [ -f /etc/sysconfig/grub ]; then
 echo  "#cat /etc/sysconfig/grub" >>$tmpdir/os_files/grub.txt 2>&1
 cat /etc/sysconfig/grub >>$tmpdir/os_files/grub.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/grub.txt'>/etc/grub</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
fi 

if [ -f /etc/sysconfig/kernel ]; then
 echo "#cat /etc/sysconfig/kernel" >>$tmpdir/os_files/kernel.txt 2>&1
 cat /etc/sysconfig/kernel >>$tmpdir/os_files/kernel.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/kernel.txt'>/etc/sysconfig/kernel</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
fi 

if [ -f /etc/sysconfig/rawdevices ]; then
 cp /etc/sysconfig/rawdevices $tmpdir/os_files/rawdevices.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/rawdevices.txt'>/etc/sysconfig/rawdevices</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
fi 


echo "#crontab -l" >> $tmpdir/os_files/crontabs.txt 2>&1
crontab -l >> $tmpdir/os_files/crontabs.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/crontabs.txt'>crontabs</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#uptime" > $tmpdir/os_files/uptime.txt 2>&1
uptime >> $tmpdir/os_files/uptime.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uptime.txt'>uptime</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


if [ -f /etc/modules.conf ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/modules.conf.txt'>/etc/modules.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/modules.conf  $tmpdir/os_files/modules.conf.txt 2>&1
 printf "."
fi



echo "#/sbin/sysctl -a" > $tmpdir/os_files/sysctl-a.txt 2>&1
/sbin/sysctl -a >> $tmpdir/os_files/sysctl-a.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/sysctl-a.txt'>sysctl -a</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f /etc/inittab ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/inittab.txt'>/etc/inittab</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inittab  $tmpdir/os_files/inittab.txt 2>&1
fi
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lspci.txt'>lspci</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/sbin/lspci"  >> $tmpdir/os_files/lspci.txt 2>&1
/sbin/lspci  >> $tmpdir/os_files/lspci.txt 2>&1
printf "."

echo $LINE >> $tmpdir/os_files/date.txt 2>&1
echo "#/sbin/hwclock" >> $tmpdir/os_files/date.txt 2>&1
/sbin/hwclock >> $tmpdir/os_files/date.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ld.so.conf.txt'>ld.so.conf</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cat /etc/ld.so.conf" >>  $tmpdir/os_files/ld.so.conf.txt 2>&1
cat /etc/ld.so.conf >> $tmpdir/os_files/ld.so.conf.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/init.d'>/etc/init.d files</a></td></tr> " >> $WEBLEFT 2>&1
if [ ! -d $tmpdir/os_files/init.d ]; then
mkdir $tmpdir/os_files/init.d >/dev/null 
fi
cp /etc/init.d/* $tmpdir/os_files/init.d >/dev/null 2>&1
for File in "$tmpdir/os_files/init.d/*"
  do
     find $File -type f |while read change
       do
        printf "."
         mv ${change} ${change}.txt > /dev/null 2>&1
        done
  done
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ls.init.d.txt'>ls /etc/init.d</a></td></tr> " >> $WEBLEFT 2>&1
ls -Al /etc/init.d $tmpdir/os_files/ls.init.d.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/fstab.txt'>fstab</a></td></tr> " >> $WEBLEFT 2>&1
cat /etc/fstab > $tmpdir/os_files/fstab.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>Environment Variables</a></td></tr> " >> $WEBLEFT 2>&1
echo "#env" > $tmpdir/os_files/env.txt 2>&1
env >> $tmpdir/os_files/env.txt 2>&1
printf "\n"
 
#-------------------------------------------------------------
printf "Gathering system configuration files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc'>/etc conf files</a></td></tr> " >> $WEBLEFT 2>&1
DIR=/etc
OUTPUT=$tmpdir/etc
TAR=/tmp/_gsctub.tar
LOG=$tmpdir/etc/tar_output.log.txt

if [ ! -d $OUTPUT ]; then
  mkdir $OUTPUT >/dev/null 2>&1
fi
if [ ! -f $LOG ]; then
  rm $LOG >/dev/null 2>&1
fi
if [ ! -f $TAR ]; then
  rm $TAR >/dev/null 2>&1
fi
for i in "conf" "tab"
 do
   echo "#cd $DIR ; find . -type f -name '*.$i' |xargs tar -cvf $TAR " >> $LOG 2>&1
   cd $DIR ; find . -type f -name "*.$i" |xargs tar -cvf $TAR  >> $LOG 2>&1
   echo "#cd $OUTPUT; tar -xvf $TAR  >/dev/null 2>&1" >> $LOG 2>&1
   cd $OUTPUT; tar -xvf $TAR  >>$LOG 2>&1
   rm -f $TAR >/dev/null 2>&1
   printf "."
done

for File in "$OUTPUT/*"
  do
   find $File -type f |while read change
    do
      printf "."
      mv ${change} ${change}.txt > /dev/null 2>&1
    done
 done
 printf "\n"
#-------------------------------------------------------------

#--------------------------------------------------------------------
# GATHERING ERROR LOGS
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr>" >> $WEBLEFT 2>&1
printf "Looking for error logs ..."
if [ -d /var/log/messages ] ||  [ -f /var/log/messages ] ; then
printf "\n"
printf "Gathering /var/log/message logs..."
cp /var/log/messages $tmpdir/messages/messages.txt > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.txt'>/var/log/messages</a></td></tr> " >> $WEBLEFT 2>&1

n=1
num=`ls $tmpdir/messages/m* |wc -l|awk '{print $1}'`
while [ $n -le $num ]
 do
  if [ -f /var/log/messages.$n ]; then
   cp /var/log/messages.$n* $tmpdir/messages/messages.$n.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.$n.txt'>/var/log/messages.$n</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
  fi
  n=`expr $n + 1`
 done
 printf "\n"
fi

if [ -f /var/adm/messages ] || [ -d /var/adm/messages ] ; then
printf "\n"
printf "Gathering /var/adm/message logs..."
cp /var/adm/messages* $tmpdir/messages/messages.txt > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.txt'>/var/adm/messages</a></td></tr> " >> $WEBLEFT 2>&1
n=1
num=`ls $tmpdir/messages/m* |wc -l |awk '{print $1}' `
while [ $n -le $num ]
do
  if [ -f /var/adm/messages.$n ]; then
   cp /var/adm/messages.$n $tmpdir/messages/messages.$n.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.$n.txt'>/var/adm/messages.$n</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
 fi
done
printf "\n"
fi

if [ -d /var/log/syslog ] || [ -f /var/log/syslog ]; then
printf "\n"
printf "Gathering /var/log/syslog logs..."
cp /var/log/syslog $tmpdir/messages/syslog.txt > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.txt'>/var/log/syslog</a></td></tr> " >> $WEBLEFT 2>&1
for n in 1 2 3 4 5 6 
do
cp /var/log/syslog.$n $tmpdir/messages/syslog.$n.txt > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.$n.txt'>/var/log/syslog.$n</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
done
printf "\n"
fi

echo "Gathering dmesg ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/dmesg.txt'>dmesg</a></td></tr> " >> $WEBLEFT 2>&1
dmesg > $tmpdir/messages/dmesg.txt 2>&1


#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA</B></td></tr> " >> $WEBLEFT 2>&1

echo "Looking for persistent binding ..."
grep scsi-qla $tmpdir/messages/messages.txt >> $OUTDIR/qlog 2>&1
if [ $? = 0 ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/persistent_binding.txt'>persistent binding</a></td></tr> " >> $WEBLEFT 2>&1
 echo "#grep scsi-qla $tmpdir/messages/messages.txt" >> $OUTDIR/qlog 2>&1
 mv $OUTDIR/qlog $tmpdir/hba/persistent_binding.txt 2>&1
else
 rm -f $OUTDIR/qlog >/dev/null 2>&1
fi

echo "Checking for HBA's ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba.drivers.txt'>HBA Drivers(Quick View)</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cd /proc/scsi; find . -type f -print | xargs egrep -i driver|version" > $tmpdir/hba/hba.drivers.txt 2>&1
cd /proc/scsi; find . -type f -print | xargs egrep -i "driver|version" >> $tmpdir/hba/hba.drivers.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba.mesg.txt'>HBA info</a></td></tr> " >> $WEBLEFT 2>&1
egrep -i "firmware|driver|qlogic|emulex"  $tmpdir/messages/* >> $tmpdir/hba/hba.mesg.txt 2>&1


ls /proc/scsi/qla* > /dev/null 2>&1
if [ $? = 0 ]; then
 printf "Gathering Qlogic HBA information ..."
 ls /proc/scsi |grep qla |while read x
   do
   if [ -d /proc/scsi/${x}  ]; then
   for i in 0 1 2 3 4 5 6 7
    do
     if [ -f /proc/scsi/${x}/${i}  ]; then
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      echo "---------------------- /proc/scsi/${x}/${i} -------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      cat /proc/scsi/${x}/${i} >>$tmpdir/hba/qlogic.hba.drivers.txt  2>&1
      printf "."
     fi
    done
    fi
  done
 printf "\n" 
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic.hba.drivers.txt'>Qlogic HBA Drivers</a></td></tr> " >> $WEBLEFT 2>&1
fi


ls -Al /proc |grep -v "^dr" |grep qla >/dev/null 2>&1
if [ $? = 0 ]; then
cd /proc |ls qla* |while read file
do 
  cp /proc/$file $tmpdir/hba/${file}.txt >/dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/$file.txt'>Qlogic $file</a></td></tr> " >> $WEBLEFT 2>&1
done
fi



cd /tmp >/dev/null 2>&1
QLOG=$tmpdir/hba/qlogic_iscli.txt

#####################################################################
# Gather iscli info (if it is installed)
#####################################################################
echo -n "Searching for iscli ... "
if test -x /usr/local/bin/iscli -o -x /usr/bin/iscli
then
   echo -n "installed ... "
   echo -n "Gathering HBA configuration information ... "
   QLOG=$LOGDIR/iscli.out

   #####################################################################
   # Display program version
   #####################################################################
   echo "=================================================" > $QLOG
   echo "Program Version" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -ver >> $QLOG; echo >> $QLOG

   #####################################################################
   # Display general information
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "General Information" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -g >> $QLOG

   #####################################################################
   # Display number of hba_nos 
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "HBA Instance Information" >> $QLOG
   echo "=================================================" >> $QLOG
   HBA_COUNT=`iscli -i | tee -a $QLOG | grep Instance | wc -l`

   #####################################################################
   # if HBA_COUNT > 0, loop through all instances for additional information
   #####################################################################
   HBA_INSTANCE=0
   while test $HBA_COUNT -gt 0
   do
      echo >> $QLOG
      echo "===========================================================" >> $QLOG
      echo "Detailed Information for HBA Instance $HBA_INSTANCE" >> $QLOG
      echo "===========================================================" >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Configuration Settings" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -c $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Port Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -pinfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Statistics" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -stat $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Bootcode Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -binfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE VPD Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -vpd $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Information" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -dspchap $HBA_INSTANCE >> $QLOG
      iscli -dspchap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Map to Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -chapmap $HBA_INSTANCE >> $QLOG
      iscli -chapmap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Persistently Bound Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -ps $HBA_INSTANCE >> $QLOG


      ##################################################################
      # Get list of targets to loop through specific information
      ##################################################################
      TARGET_LIST=`iscli -t $HBA_INSTANCE | grep "Target ID" | cut -c11-15`
      for TARGET_NO in $TARGET_LIST
      do
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO Information" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -t $HBA_INSTANCE $TARGET_NO >> $QLOG
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO LUN List" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -l $HBA_INSTANCE $TARGET_NO >> $QLOG
      done

      echo >> $QLOG
      echo "=================================================" >> $QLOG
      echo "Retrieving HBA $HBA_INSTANCE Crash Dump (if exists)" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -gcr $HBA_INSTANCE $LOGDIR/iscsi_crash_$HBA_INSTANCE.out

      HBA_COUNT=`expr $HBA_COUNT - 1`
      HBA_INSTANCE=`expr $HBA_INSTANCE + 1`
   done

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic_iscli.txt'>Qlogic HBA iscli output</a></td></tr> " >> $WEBLEFT 2>&1
fi


scli -v >$OUTDIR/.scli 2>&1
if [ $? = 0 ]; then
echo "Found Qlogic HBAs ... extracting hba info ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic.scli.txt'>Qlogic HBA scli output</a></td></tr> " >> $WEBLEFT 2>&1
  mv $OUTDIR/.scli $tmpdir/hba/qlogic.scli.txt 
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -c all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -c all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -i all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -i all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -t all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -t all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -p all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -p all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -z all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -z all >>$tmpdir/hba/qlogic.scli.txt 2>&1
else
 rm -f $OUTDIR/.scli >/dev/null 2>&1
fi

ls /proc/scsi/lpfc > /dev/null 2>&1
if [ $? = 0 ]; then
 printf "Gathering Emulex HBA information ..."
 ls  /proc/scsi/lpfc  |while read x
   do
     if [ -f /proc/scsi/lpfc/${x} ]; then
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      echo "-------------------- /proc/scsi/${x}----- --------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      cat /proc/scsi/${x} >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      printf "."
     fi
    done
 printf "\n" 
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hba.drivers.txt'>Emulex HBA Drivers</a></td></tr> " >> $WEBLEFT 2>&1
fi

cp /etc/ql*.conf $tmpdir/hba/ > /dev/null 2>&1
if [ -f $tmpdir/hba/qla2xxx.conf ]; then 
 mv $tmpdir/hba/qla2xxx.conf $tmpdir/hba/qla2xxx.conf.txt
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qla2xxx.conf.txt'>Qlogic /etc/qla2xxx.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/hba/qla3xxx.conf ]; then 
 mv $tmpdir/hba/qla3xxx.conf $tmpdir/hba/qla3xxx.conf.txt
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qla3xxx.conf.txt'>Qlogic /etc/qla3xxx.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi


fa=0
hbaw=0
hbacmd version >> /dev/null 2>&1
if [ $? = 0 ]; then
 hbaw=1
fi

if [ -f /usr/sbin/hbanyware/hbacmd ] || [ $hbaw == 1 ] ; then
fa=1
echo "Found hbanyware ..."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.txt'>Hbanyware info</a></td></tr> " >> $WEBLEFT 2>&1
echo "/usr/sbin/hbanyware/hbacmd version " >>$tmpdir/hba/emulex.hbanyware.txt 2>&1
/usr/sbin/hbanyware/hbacmd version >>$tmpdir/hba/emulex.hbanyware.txt 2>&1
echo $LINE >> $tmpdir/hba/emulex.hbanyware.txt 2>&1

echo "/usr/sbin/hbanyware/hbacmd listhbas" >> $tmpdir/hba/emulex.hbanyware.listhbas.txt 2>&1
/usr/sbin/hbanyware/hbacmd listhbas >> $tmpdir/hba/emulex.hbanyware.listhbas.txt 2>&1


echo "Gathering HBA information from hbanyware ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.hbainfo.txt'>Hbanyware HBAinfo</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.listhbas.txt'>Hbanyware listhbas</a></td></tr> " >> $WEBLEFT 2>&1
grep "Port WWN" $tmpdir/hba/emulex.hbanyware.listhbas.txt |awk '{print $4}' |while read wwpn 
 do
	echo "[$wwpn] ====================================" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd DriverParams $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd DriverParams $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd getdriverparams $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd getdriverparams $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd getdriverparamsglobal $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd getdriverparamsglobal $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd HBAAttrib $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd HBAAttrib $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd AllNodeInfo $wwpn " >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd AllNodeInfo $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd TargetMapping $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd TargetMapping $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
done
fi

if [ -d /sys/class/scsi_host/host0 ]; then

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.hbainfo.txt'>Hbanyware HBAinfo</a></td></tr> " >> $WEBLEFT 2>&1

echo "Checking for Emulex firmware versions ..."
ls /sys/class/scsi_host |while read host
do

printf $host: >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
cat /sys/class/scsi_host/$host/lpfc_drvr_version >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
printf "Firmware:" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
cat /sys/class/scsi_host/$host/fwrev >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
printf "WWN:"  >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
cat /sys/class/scsi_host/$host/hdw >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
done

fi

if [ -f /etc/lpfc.conf ] ; then
echo "Found lpfc.conf ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpfc.conf.txt'>Emulex lpfc.conf</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/lpfc.conf $tmpdir/hba/lpfc.conf.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpfc.queue.depth.txt'>Emulex Queue Depth</a></td></tr> " >> $WEBLEFT 2>&1
echo "grep queue /etc/lpfc.conf" >> $tmpdir/hba/lpfc.queue.depth.txt 2>&1
grep queue /etc/lpfc.conf >> $tmpdir/hba/lpfc.queue.depth.txt 2>&1
fi

cimprovider -l >> $OUTDIR/.cfile 2>&1
if [ $? = 0 ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/cimprovider-l.txt'>cimprovider -l</a></td></tr> " >> $WEBLEFT 2>&1
 mv $OUTDIR/.cfile $tmpdir/hba/cimprovider-l.txt 2>&1
else 
 rm $OUTDIR/.cfile > /dev/null 2>&1
fi
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba'>HBA Directory</a></td></tr> " >> $WEBLEFT 2>&1
#--------------------------------------------------------------------
# GATHERING BOOT INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>BOOT INFO</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering System Boot Information ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/boot/boot.txt'>ls /boot</a></td></tr> " >> $WEBLEFT 2>&1

echo "#ls -Al /boot" >> $tmpdir/boot/boot.txt 2>&1
ls -Al /boot >> $tmpdir/boot/boot.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/rcfiles.txt'>/etc/rc.d files</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /etc/rc.d/rc0.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc0.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1
echo "#ls -Al /etc/rc.d/rc1.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc1.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1
echo "#ls -Al /etc/rc.d/rc2.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc2.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1
echo "#ls -Al /etc/rc.d/rc3.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc3.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1
echo "#ls -Al /etc/rc.d/rc4.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc4.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1
echo "#ls -Al /etc/rc.d/rc5.d" >> $tmpdir/etc/rcfiles.txt 2>&1
ls -Al /etc/rc.d/rc5.d >> $tmpdir/etc/rcfiles.txt 2>&1
echo $LINE >> $tmpdir/etc/rcfiles.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/rc.local.txt'>/etc/rc.local</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cat /etc/rc.d/rc.local" >> $tmpdir/etc/rc.local.txt 2>&1
cat /etc/rc.d/rc.local >> $tmpdir/etc/rc.local.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/rc.d.txt'>ls /etc/rc.d</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /etc/rc.d" >> $tmpdir/etc/rc.d.txt 2>&1
ls -Al /etc/rc.d >> $tmpdir/etc/rc.d.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc/ls.init.d.txt'>ls /etc/init.d</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /etc/init.d" >> $tmpdir/etc/ls.init.d.txt 2>&1
ls -Al /etc/init.d >> $tmpdir/etc/ls.init.d.txt 2>&1

if [ -f /etc/lilo.conf ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/boot/lilo.conf.txt'>lilo.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/lilo.conf $tmpdir/boot/lilo.conf.txt 2>&1
fi

#--------------------------------------------------------------------
# GATHERING KERNEL INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering Kernel Information ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/lsmod.txt'>lsmod</a></td></tr> " >> $WEBLEFT 2>&1
/sbin/lsmod > $tmpdir/kernel/lsmod.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/kernel.txt'>kernel</a></td></tr> " >> $WEBLEFT 2>&1
echo "/bin/rpm -qa |grep -i kernel" >> $tmpdir/kernel/kernel.txt 2>&1
/bin/rpm -qa |grep -i kernel >> $tmpdir/kernel/kernel.txt 2>&1
printf "\n"
printf "Listing files in /proc ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/proc.txt'>/proc</a></td></tr> " >> $WEBLEFT 2>&1
ls -alR /proc >>$tmpdir/kernel/proc.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/proc_partitions.txt'>/proc partitions</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cat /proc/partitions"  >> $tmpdir/kernel/proc_partitions.txt 2>&1
cat /proc/partitions  >> $tmpdir/kernel/proc_partitions.txt 2>&1
printf "\n"

QDepth README_queue_depth.txt
QDepthReadme

#--------------------------------------------------------------------
# GATHERING SOFTWARE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SOFTWARE</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering software info using rpm -qisva ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/rpm.qisva.txt'>rpm -qisva</a></td></tr> " >> $WEBLEFT 2>&1
echo "#rpm -qisva" >> $tmpdir/software/rpm.qisva.txt 2>&1
rpm -qisva >> $tmpdir/software/rpm.qisva.txt 2>&1

printf "Gathering software info ..."
echo "#perl -v" >> $tmpdir/software/perl.txt 2>&1
perl -v >> $tmpdir/software/perl.txt 2>&1
echo $LINE >> $tmpdir/software/perl.txt 2>&1
echo "#ls -al /usr/bin/perl">> $tmpdir/software/perl.txt 2>&1
ls -al /usr/bin/perl >> $tmpdir/software/perl.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/perl.txt'>perl -v</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#gcc -v " >> $tmpdir/software/gcc.txt 2>&1
(gcc -v)  >> $tmpdir/software/gcc.txt 2>&1
if [ $? = 0 ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/gcc.txt'>gcc -v</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "."

echo "#ls -Al /opt" >> $tmpdir/software/ls.opt.txt 2>&1
ls -Al /opt  >> $tmpdir/software/ls.opt.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>List of /opt</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#java -version"  >> $tmpdir/software/java.txt 2>&1
java -version  >> $tmpdir/software/java.txt 2>&1
echo $LINE >> $tmpdir/software/java.txt 2>&1
echo "#ls -al /usr/ |grep java" >> $tmpdir/software/java.txt 2>&1
ls -al /usr/ |grep java >> $tmpdir/software/java.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/java.txt'>Java Info</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"



#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------
printf "Gathering disk info ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1

echo "#mount" >>$tmpdir/disk/mount.txt 2>&1
mount >>$tmpdir/disk/mount.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f /proc/mounts ]; then
 echo $LINE >> $tmpdir/disk/mount.txt 2>&1
 cat /proc/mounts >> $tmpdir/disk/mount.txt 2>&1
fi

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lsraid.txt'>lsraid</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lsraid -R -p" > $tmpdir/disk/lsraid.txt 2>&1
lsraid -R -p >> $tmpdir/disk/lsraid.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/sginfo-l.txt'>sginfo -l</a></td></tr> " >> $WEBLEFT 2>&1
echo "#sginfo -l" > $tmpdir/disk/sginfo-l.txt 2>&1
sginfo -l >> $tmpdir/disk/sginfo-l.txt 2>&1
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/fdisk-l.txt'>fdisk</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/sbin/fdisk -l" > $tmpdir/disk/fdisk-l.txt 2>&1
/sbin/fdisk -l >> $tmpdir/disk/fdisk-l.txt 2>&1
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/dev.sd_devices.txt'>ls /dev/sd </a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /dev/sd*" > $tmpdir/disk/dev.sd_devices.txt 2>&1
ls -Al /dev/sd* >> $tmpdir/disk/dev.sd_devices.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/proc.scsi.txt'>/proc/scsi/scsi</a></td></tr>" >> $WEBLEFT 2>&1
echo "#cat /proc/scsi/scsi " >> $tmpdir/disk/proc.scsi.txt 2>&1
cat /proc/scsi/scsi >> $tmpdir/disk/proc.scsi.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/vgdisplay-v.txt'>vgdisplay</a></td></tr> " >> $WEBLEFT 2>&1
echo "#vgdisplay -v" >> $tmpdir/disk/vgdisplay-v.txt 2>&1
vgdisplay -v >> $tmpdir/disk/vgdisplay-v.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/pvscan.txt'>pvscan</a></td></tr> " >> $WEBLEFT 2>&1
echo "#pvscan" >> $tmpdir/disk/pvscan.txt 2>&1
pvscan >> $tmpdir/disk/pvscan.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lvmdiskscan.txt'>lvmdiskscan </a></td></tr> " >> $WEBLEFT 2>&1
echo "# lvmdiskscan" > $tmpdir/disk/lvmdiskscan.txt 2>&1
lvmdiskscan >> $tmpdir/disk/lvmdiskscan.txt 2>&1
printf "\n"

if [ -f /etc/sysconfig/devlabel ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/devlabel.txt'>devlabel</a></td></tr> " >> $WEBLEFT 2>&1
if [ -f /etc/sysconfig/devlabel ] ; then
 echo "Found devlabel ..."
 echo "# cat /etc/sysconfig/devlabel" >> $tmpdir/disk/devlabel.txt 2>&1
 cat /etc/sysconfig/devlabel >> $tmpdir/disk/devlabel.txt 2>&1
fi
fi



if  [ -f /sbin/tune2fs ]; then
 printf "Running tune2fs on /dev/sd* ..."
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/tune2fs.txt'>Tune2fs</a></td></tr>" >> $WEBLEFT 2>&1
 cat /proc/partitions |grep sd |awk '{print $4}'|while read x
  do
  echo "==================/dev/$x========================" >> $tmpdir/disk/tune2fs.txt 2>&1
  echo "tune2fs -l /dev/$x" >> $tmpdir/disk/tune2fs.txt 2>&1
  tune2fs -l /dev/$x >> $tmpdir/disk/tune2fs.txt 2>&1
  printf "."
 done
 printf "\n"
fi


if [ -f /etc/lvm/lvm.conf ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lvm.conf.txt'>/etc/lvm/lvm.conf</a></td></tr>" >> $WEBLEFT 2>&1
cp /etc/lvm/lvm.conf $tmpdir/disk/lvm.conf.txt 2>&1
fi

if [ -f /etc/lvm/.cache ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/.cache.txt'>/etc/lvm/.cache</a></td></tr>" >> $WEBLEFT 2>&1
cp /etc/lvm/.cache $tmpdir/disk/cache.txt 2>&1
fi

if [ -f /etc/raidtab ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/raidtab.txt'>/etc/raidtab</a></td></tr>" >> $WEBLEFT 2>&1
 cp /etc/raidtab $tmpdir/disk/raidtab.txt  2>&1
fi

#--------------------------------------------------------------------
# GATHERING NETWORKING INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/dns.txt'>DNS lookup info</a></td></tr> " >> $WEBLEFT 2>&1

echo "Performing a forward dig lookup based on hostname ..."
hostname | dig +qr $y >> $tmpdir/networking/dns.txt 2>&1
echo $LINE >> $tmpdir/networking/dns.txt 2>&1

echo "Performing a reverse dig based on IP Address ..."
grep localhost /etc/hosts | awk '{print $1}' |dig -x >> $tmpdir/networking/dns.txt 2>&1
echo $LINE >> $tmpdir/networking/dns.txt 2>&1

/sbin/arp -a >> $tmpdir/networking/dns.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/etc.hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
cat /etc/hosts > $tmpdir/networking/etc.hosts.txt 2>&1
echo $LINE >> $tmpdir/networking/dns.txt 2>&1
cat /etc/resolv.conf >> $tmpdir/networking/dns.txt 2>&1

echo "hostname=$HOSTNAME" > $tmpdir/getconfig_v${VERSION}_${HOSTNAME}.txt 2>&1

echo "Checking available ports ..."
/bin/netstat -an >> $tmpdir/networking/netstat-an.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat-an.txt'>netstat -an</a></td></tr> " >> $WEBLEFT 2>&1
/bin/netstat -rn >> $tmpdir/networking/netstat-rn.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat-rn.txt'>netstat -rn</a></td></tr> " >> $WEBLEFT 2>&1
/bin/netstat -autp >> $tmpdir/networking/netstat-autp.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat-autp.txt'>netstat -autp</a></td></tr> " >> $WEBLEFT 2>&1
ifconfig -a >> $tmpdir/networking/ifconfig-a.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/ifconfig-a.txt'>ifconfig -a</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /etc/inetd.conf ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/inetd.conf.txt'>inetd.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inetd.conf  $tmpdir/networking/inetd.conf.txt 2>&1
fi
printf "\n"

echo "Gathering misc system networking information ..."
if [ -f /etc/sysconfig/network ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/network.txt'>/etc/sysconfig/network</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/sysconfig/network   $tmpdir/networking/network.txt 2>&1
fi

#--------------------------------------------------------------------
# GATHERING MULTIPATH
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>MULTIPATH</B></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering System Multipath Information ... "
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/multipath-l.txt'>multipath -l</a></td></tr> " >> $WEBLEFT 2>&1
echo "#multipath -l" >> $tmpdir/os_files/multipath-l.txt 2>&1
multipath -l >> $tmpdir/os_files/multipath-l.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/multipath-v3.txt'>multipath -v3</a></td></tr> " >> $WEBLEFT 2>&1
echo "#multipath -v3" >> $tmpdir/os_files/multipath-v3.txt 2>&1
multipath -v3 >> $tmpdir/os_files/multipath-v3.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/dmsetup-ls.txt'>dmsetup ls</a></td></tr> " >> $WEBLEFT 2>&1
echo "#dmsetup ls" >> $tmpdir/os_files/dmsetup-ls.txt 2>&1
dmsetup ls >> $tmpdir/os_files/dmsetup-ls.txt 2>&1
printf "."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/dmsetup-status-v.txt'>dmsetup status -v</a></td></tr> " >> $WEBLEFT 2>&1
echo "#dmsetup status -v" >> $tmpdir/os_files/dmsetup-status-v.txt 2>&1
dmsetup status -v >> $tmpdir/os_files/dmsetup-status-v.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/dmsetup-ls.txt'>dmsetup ls</a></td></tr> " >> $WEBLEFT 2>&1
echo "#dmsetup ls" >> $tmpdir/os_files/dmsetup-ls.txt 2>&1
dmsetup ls >> $tmpdir/os_files/dmsetup-ls.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/udevinfo-d.txt'>udevinfo -d</a></td></tr> " >> $WEBLEFT 2>&1
echo "#udevinfo -d" >> $tmpdir/os_files/udevinfo-d.txt 2>&1
udevinfo -d >> $tmpdir/os_files/udevinfo-d.txt 2>&1
printf "."
printf "\n"

#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1

#
printf "Gathering System Performance Information ... (may take 30 seconds)"

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-aux.txt'>ps aux</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps aux" >> $tmpdir/performance/ps-aux.txt 2>&1
ps aux >> $tmpdir/performance/ps-aux.txt 2>&1

echo "#ps -elf" >> $tmpdir/performance/ps-elf.txt 2>&1
ps -elf >> $tmpdir/performance/ps-elf.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-elf.txt'>ps -elf</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#free" >> $tmpdir/performance/free.txt 2>&1
free >> $tmpdir/performance/free.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/free.txt'>free</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#cat /proc/swaps" >>$tmpdir/performance/swaps.txt 2>&1
cat /proc/swaps >>$tmpdir/performance/swaps.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/swaps.txt'>cat /proc/swaps</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f /proc/cpuinfo ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/cpuinfo.txt'>/proc/cpuinfo</a></td></tr> " >> $WEBLEFT 2>&1
 echo "#cat /proc/cpuinfo " >> $tmpdir/performance/cpuinfo.txt 2>&1
 cat /proc/cpuinfo  >> $tmpdir/performance/cpuinfo.txt 2>&1
 printf "."
fi

ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
echo "#vmstat 1 10" >> $tmpdir/performance/vmstat.txt 2>&1 
vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmstat 1 10" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

ps -ef |grep iostat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "#iostat -p ALL 2 6" >> $tmpdir/performance/iostat.txt 2>&1 
iostat -p ALL 2 6 >> $tmpdir/performance/iostat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "iostat" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/iostat.txt'>iostat -p ALL 2 6</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "."
top -b -n2 >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "\n"

# End Linux Functions
}


###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
# TRU64 /ALPHA FUNCTIONS
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
tru64() 
{
if [ -f /tmp/.setx ]; then
 set -x
fi
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'>GetConfig Help</a></td></tr> " >> $WEBLEFT 2>&1

#######################################################################
###  This will create and define the directory to place files in
mkdir $tmpdir/boot > /dev/null 2>&1
mkdir $tmpdir/devices > /dev/null 2>&1
mkdir $tmpdir/syscheck > /dev/null 2>&1
#######################################################################

#--------------------------------------------------------------------
# GATHERING SYSCHECK/SYSTEM INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSCHECK</B></td></tr> " >> $WEBLEFT 2>&1

echo "Running /usr/sbin/sys_check ... relax, this may take a while" 
/usr/sbin/sys_check > $tmpdir/syscheck/sys_check.html  2>&1 &
waitfor $!

echo "sys_check complete."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/syscheck/sys_check.html'>Sys Check</a></td></tr> " >> $WEBLEFT 2>&1


#--------------------------------------------------------------------
# GATHERING ERROR LOGS
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering error logs ..."

cp /var/adm/syslog $tmpdir/messages/syslog.txt 2>&1
cp /var/adm/syslog.0 $tmpdir/messages/syslog.0.txt 2>&1
cp /var/adm/syslog.1 $tmpdir/messages/syslog.1.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.txt'>syslog</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.0.txt'>syslog.0</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/syslog.1.txt'>syslog.1</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/message/uerf.txt'>uerf output</a></td></tr> " >> $WEBLEFT 2>&1

printf "."
uerf |grep memory >>$tmpdir/messages/uerf.memory.txt 2>&1
echo $LINE >> $tmpdir/messages/uerf.txt 2>&1
uerf -R -o full >>$tmpdir/messages/uerf.txt 2>&1
printf "\n"


#--------------------------------------------------------------------
# GATHERING DEVICE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DEVICE INFO</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering device data ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/'>Error Logs</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/devices/hwmgr.txt'>hwmgr and dsfmgr</a></td></tr> " >> $WEBLEFT 2>&1
echo "/sbin/hwmgr -show scsi" >>$tmpdir/devices/hwmgr.txt 2>&1
/sbin/hwmgr -show scsi >>$tmpdir/devices/hwmgr.txt 2>&1
echo $LINE >> $tmpdir/devices/hwmgr.txt 2>&1

echo "/sbin/hwmgr -show devices"  >>$tmpdir/devices/hwmgr.txt 2>&1
/sbin/hwmgr -show devices  >>$tmpdir/devices/hwmgr.txt 2>&1
echo $LINE >> $tmpdir/devices/hwmgr.txt 2>&1

echo "/sbin/dsfmgr -s"  >$tmpdir/devices/hwmgr.txt 2>&1
/sbin/dsfmgr -s  >$tmpdir/devices/hwmgr.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/devices/devices.txt'>ls /devices</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -AlR /devices" > $tmpdir/devices/devices.txt 2>&1
ls -AlR /devices >> $tmpdir/devices/devices.txt 2>&1
printf "."

#--------------------------------------------------------------------
# GATHERING SYSTEM OS INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM INFO</B></td></tr> " >> $WEBLEFT 2>&1
printf "Gathering os information ..."

echo "#date" >$tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#uname -a" >$tmpdir/os_files/uname.txt 2>&1
uname -a >> $tmpdir/os_files/uname.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>OS Version[uname]</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/vmunix.txt'>ls /vmunix</a></td></tr> " >> $WEBLEFT 2>&1
ls -AlR /vmunix >> $tmpdir/os_files/vmunix.txt 2>&1
echo $LINE >> $tmpdir/os_files/vmunix.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>shell environment</a></td></tr> " >> $WEBLEFT 2>&1
env >$tmpdir/os_files/env.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/psrinfo.txt'>psrinfo</a></td></tr> " >> $WEBLEFT 2>&1
/usr/sbin/psrinfo > $tmpdir/os_files/psrinfo.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/pset.txt'>pset</a></td></tr> " >> $WEBLEFT 2>&1
/usr/sbin/pset_info > $tmpdir/os_files/pset.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/consvar.txt'>consvar</a></td></tr> " >> $WEBLEFT 2>&1
/sbin/consvar >$tmpdir/os_files/consvar.txt 2>&1
cp /etc/sysconfigtab >$tmpdir/os_files/sysconfigtab.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/patch_level.txt'>patch level</a></td></tr> " >> $WEBLEFT 2>&1
echo "/usr/sbin/sizer -vB" >$tmpdir/os_files/patch_level.txt 2>&1
/usr/sbin/sizer -vB >>$tmpdir/os_files/patch_level.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/dupatch.txt'>dupatch</a></td></tr> " >> $WEBLEFT 2>&1
dupatch -track -type kit -nolog > $tmpdir/os_files/dupatch.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/sysconfig.txt'>sysconfig -s</a></td></tr> " >> $WEBLEFT 2>&1
/sbin/sysconfig -s >$tmpdir/os_files/sysconfig.txt 2>&1
printf "."

mkdir $tmpdir/sys > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/sys'>files in /usr/sys/data</a></td></tr> " >> $WEBLEFT 2>&1
cp /usr/sys/data/* $tmpdir/sys/ 2>&1


ls -AlR /sbin/init.d >>$tmpdir/os_files/sysinfo.txt 2>&1
echo $LINE >> $tmpdir/os_files/sysinfo 2>&1
who -r >>$tmpdir/os_files/runlevel.txt 2>&1
echo $LINE >> $tmpdir/os_files/sysinfo 2>&1
/sbin/swapon -s >>$tmpdir/os_files/swap.txt 2>&1
echo $LINE >> $tmpdir/os_files/sysinfo 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/fstab.txt'>/etc/fstab</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/fstab $tmpdir/os_files/fstab.txt 2>&1
printf "\n"

echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL</B></td></tr> " >> $WEBLEFT 2>&1
QDepth README_queue_depth.txt
QDepthReadme

#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering disk information ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disk.txt'>Disk Summary</a></td></tr> " >> $WEBLEFT 2>&1
ddr_config -s disk "HITACHI" "OPEN-3" >>$tmpdir/disk/disk.txt 2>&1
echo $LINE >> $tmpdir/disk/disk.txt 2>&1
strings /etc/ddr.dbase >>$tmpdir/os_files/ddr.dbase.txt 2>&1
echo $LINE >> $tmpdir/disk/disk.txt 2>&1

if [ -d /dev/fc ] ; then
 echo "#ls -AlR /dev/fc" >$tmpdir/disk/disk.txt 2>&1
 ls -AlR /dev/fc >>$tmpdir/disk/disk.txt 2>&1
 echo $LINE >> $tmpdir/disk/disk.txt 2>&1
fi

echo "#ls -AlR /dev/dsk" >>$tmpdir/disk/disk.txt 2>&1
ls -AlR /dev/dsk >>$tmpdir/disk/disk.txt 2>&1
echo $LINE >> $tmpdir/disk/disk.txt 2>&1

echo "#ls -AlR /dev/rdsk" >$tmpdir/disk/disk.txt 2>&1
ls -AlR /dev/rdsk >>$tmpdir/disk/disk.txt 2>&1
echo $LINE >> $tmpdir/disk/disk.txt 2>&1

ls /dev/disk |grep dsk |while read disks
do
 echo "-------------- $disk ---------------------" >>$tmpdir/disk/disklabel.txt 2>&1
 disklabel -r $disk >>$tmpdir/disk/disklabel.txt 2>&1
  printf "."
done
printf "\n"
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disklabel.txt'>disklabel output</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/disktab.txt'>/etc/disktab</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/disktab $tmpdir/disk/disktab.txt 2>&1

#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering disk info ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/device.paths.edt'>/sbin/scu show edt</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/sbin/scu show edt" >$tmpdir/hba/device.paths.edt 2>&1
/sbin/scu show edt >>$tmpdir/hba/device.paths.edt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1
echo "mount" >>$tmpdir/disk/mount.txt 2>&1
mount >>$tmpdir/disk/mount.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/df.txt'>df -k</a></td></tr> " >> $WEBLEFT 2>&1
echo "#df -k" >> $tmpdir/disk/df.txt 2>&1
df -k >> $tmpdir/disk/df.txt 2>&1
print "."

#--------------------------------------------------------------------
# GATHERING NETWORKING
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering networking information ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/network.txt'>Network Info</a></td></tr> " >> $WEBLEFT 2>&1
cat /etc/exports >>$tmpdir/networking/network.txt 2>&1
echo $LINE >> $tmpdir/networking/network.txt 2>&1
printf "."
cat /etc/resolv.conf >> $tmpdir/networking/network.txt  2>&1
echo $LINE >> $tmpdir/networking/network.txt 2>&1
printf "."
cat /etc/snmpd.conf >> $tmpdir/networking/network.txt 2>&1
echo $LINE >> $tmpdir/networking/network.txt 2>&1
printf "."
echo $LINE >> $tmpdir/networking/network.txt 2>&1
cp /etc/routest >> $tmpdir/networking/networking.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat.txt'>netstat -in</a></td></tr> " >> $WEBLEFT 2>&1
echo "#netstat -in" >>$tmpdir/networking/netstat.txt 2>&1
netstat -in >>$tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
printf "."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/ifconfig-a.txt'>ifconfig -a</a></td></tr> " >> $WEBLEFT 2>&1
ifconfig -a >$tmpdir/networking/ifconfig-a.txt 2>&1
printf "\n"

#--------------------------------------------------------------------
# GATHERING SOFTWARE
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SOFTWARE</B></td></tr> " >> $WEBLEFT 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/setld.txt'>setld -i</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/usr/sbin/setld -i" >>$tmpdir/software/setld.txt 2>&1
/usr/sbin/setld -i >$tmpdir/software/setld.txt 2>&1


#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
echo "Gathering performance info ..."
ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
echo "vmstat 1 10" >> $tmpdir/performance/vmstat.txt 2>&1
vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1
fi


#--------------------------------------------------------------------
# GATHERING TOP
#--------------------------------------------------------------------
echo "Running top ..."
top -b -n2 >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi

#--------------------------------------------------------------------
# GATHERING LOGICAL VOLUME (LVM)
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>VOLUME INFO</B></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering volume information ..."

mkdir $tmpdir/lvm > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/lvm/volprint.txt'>Volprint</a></td></tr> " >> $WEBLEFT 2>&1
echo "volprint -l -g rootdg" >>$tmpdir/lvm/volprint.txt 2>&1
volprint -l -g rootdg >>$tmpdir/lvm/volprint.txt 2>&1
echo $LINE >> $tmpdir/lvm/volprint.txt 2>&1
echo "volprint -dl"  >>$tmpdir/lvm/volprint.txt 2>&1
volprint -dl  >>$tmpdir/lvm/volprint.txt 2>&1



}

###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
# VMWARE FUNCTIONS
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
vmware()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

#-------------------------------------------------------------------------------------------
if [ $VMONLY = 1 ]; then    # GIVE USER THE OPTION TO USE VMWARE SUPPORT TOOL
  mkdir $tmpdir/vmware >  /dev/null 2>&1
  cp /usr/sbin/vm-support $tmpdir/vmware >  /dev/null 2>&1
  cd $tmpdir/vmware; ./vm-support >> $tmpdir/vmware/vm-support_output.txt
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware'>vmsupport</a></td></tr> " >> $WEBLEFT 2>&1
  cp $tmpdir/vmware/vm-support $tmpdir/vmware/$vm-support.txt >>  /dev/null 2>&1


else			# ELSE VMONLY


echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../_web/faq.htm'>GetConfig Help</a></td></tr> " >> $WEBLEFT 2>&1
mkdir $tmpdir/boot > /dev/null 2>&1

#--------------------------------------------------------------------
# GATHERING SYSTEM INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SYSTEM INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering Detailed System Information ..."

echo "#uname -a" >> $tmpdir/os_files/uname.txt 2>&1
uname -a >> $tmpdir/os_files/uname.txt 2>&1
echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
if [ -f /proc/version ]; then
 echo "#cat /proc/version"  >> $tmpdir/os_files/uname.txt 2>&1
 cat /proc/version  >> $tmpdir/os_files/uname.txt 2>&1
fi

echo "#date" >>$tmpdir/os_files/date.txt 2>&1
date >> $tmpdir/os_files/date.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/date.txt'>Current Date/Time</a></td></tr> " >> $WEBLEFT 2>&1

echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uname.txt'>OS Version[uname]</a></td></tr> " >> $WEBLEFT 2>&1


echo "#df -k" >> $tmpdir/os_files/df.txt 2>&1
df -k >> $tmpdir/os_files/df.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/df.txt'>df -k</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#vdf -h /vmfs" > $tmpdir/os_files/vdf.txt 2>&1
vdf -h /vmfs >> $tmpdir/os_files/vdf.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/vdf.txt'>vdf -h /vmfs </a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f /etc/sysconfig/hwconf ]; then
 echo "#cat /etc/sysconfig/hwconf" >> $tmpdir/os_files/hwconf.txt
 cat /etc/sysconfig/hwconf >> $tmpdir/os_files/hwconf.txt
 echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/hwconf.txt'>hwconf</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."
fi 


if [ -f /etc/sysconfig/kernel ]; then
 echo "#cat /etc/sysconfig/kernel" >>$tmpdir/os_files/kernel.txt 2>&1
 cat /etc/sysconfig/kernel >>$tmpdir/os_files/kernel.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/kernel.txt'>kernel</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
fi 

mkdir $tmpdir/os_files/root > /dev/null 2>&1
cp /root/vmware/linux/linux.vmx $tmpdir/os_files/root/linux.vmx.txt >/dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/root/linux.vmx.txt'>/root/vmware/linux/linux.vmx</a></td></tr> " >> $WEBLEFT 2>&1
cp /root/vmware/linux/vmware.log $tmpdir/os_files/root/vmware.log.txt >/dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/root/vmware.log.txt'>/root/vmware/linux/vmware.log</a></td></tr> " >> $WEBLEFT 2>&1
if [ -f /root/vmware/linux/vmware-0.log ]; then
 cp /root/vmware/linux/vmware-0.log $tmpdir/os_files/root/vmware-0.log.txt >/dev/null 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/root/vmware-0.log.txt'>/root/vmware/linux/vmware-0.log</a></td></tr> " >> $WEBLEFT 2>&1
fi
if [ -f /root/vmware/linux/vmware-1.log ]; then
 cp /root/vmware/linux/vmware-1.log $tmpdir/os_files/root/vmware-1.log.txt >/dev/null 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/root/vmware-1.log.txt'>/root/vmware/linux/vmware-1.log</a></td></tr> " >> $WEBLEFT 2>&1
fi


if [ -f /etc/sysconfig/rawdevices ]; then
 cp /etc/sysconfig/rawdevices $tmpdir/os_files/rawdevices.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/rawdevices.txt'>rawdevices</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
fi 

echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
echo "#cat /etc/redhat-release" >>$tmpdir/os_files/uname.txt  2>&1
cat /etc/redhat-release >>$tmpdir/os_files/uname.txt  2>&1
echo $LINE >> $tmpdir/os_files/uname.txt 2>&1
printf "."

mkdir $tmpdir/os_files/cron > /dev/null 2>&1
cp /etc/crontab $tmpdir/os_files/cron/crontab.txt  2>&1
if [ -f /etc/anacrontab ]; then
 cp /etc/anacrontab $tmpdir/os_files/cron/anacrontab.txt  2>&1
fi
getfiles /etc/cron.daily os_files/cron/cron.daily 
getfiles /etc/cron.hourly os_files/cron/cron.hourly
getfiles /etc/cron.weekly os_files/cron/cron.weekly
getfiles /etc/cron.monthly os_files/cron/cron.monthly
getfiles /etc/cron.removed os_files/cron/cron.removed

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/cron'>/etc/cron</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#uptime" > $tmpdir/os_files/uptime.txt 2>&1
uptime >> $tmpdir/os_files/uptime.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/uptime.txt'>uptime</a></td></tr> " >> $WEBLEFT 2>&1
printf "."


if [ -f /etc/modules.conf ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/modules.conf.txt'>modules</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/modules.conf  $tmpdir/os_files/modules.conf.txt 2>&1
 printf "."
fi


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/krb.conf.txt'>krb.conf</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/krb.conf  $tmpdir/os_files/krb.conf.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/krb5.conf.txt'>krb5.conf</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/krb5.conf  $tmpdir/os_files/krb5.conf.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/krb.realms.txt'>krb.realms</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/krb.realms  $tmpdir/os_files/krb.realms.txt 2>&1
printf "."


echo "#mount" >>$tmpdir/disk/mount.txt 2>&1
mount >>$tmpdir/disk/mount.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/mount.txt'>mount</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f /proc/mounts ]; then
 echo $LINE >> $tmpdir/disk/mount.txt 2>&1
 cat /proc/mounts >> $tmpdir/disk/mount.txt 2>&1
fi

echo "#/sbin/sysctl -a" > $tmpdir/os_files/sysctl-a.txt 2>&1
/sbin/sysctl -a >> $tmpdir/os_files/sysctl-a.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/sysctl-a.txt'>sysctl -a</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

if [ -f etc/inittab ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/inittab.txt'>inittab</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/inittab  $tmpdir/os_files/inittab.txt 2>&1
fi
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lspci.txt'>lspci</a></td></tr> " >> $WEBLEFT 2>&1

echo "#/sbin/lspci -Hl -M"  >> $tmpdir/os_files/lspci.txt 2>&1
lspci -H1 -M >> $tmpdir/os_files/lspci.txt 2>&1
echo $LINE >>$tmpdir/os_files/lspci.txt 2>&1
echo "#lspci -H1 -M" >> $tmpdir/os_files/lspci.txt 2>&1
lspci -H1 -M >> $tmpdir/os_files/lspci.txt 2>&1
echo $LINE >>$tmpdir/os_files/lspci.txt 2>&1
echo "#lspci -vv" >> $tmpdir/os_files/lspci.txt 2>&1
lspci -vv >> $tmpdir/os_files/lspci.txt 2>&1
echo $LINE >>$tmpdir/os_files/lspci.txt 2>&1
echo "#lspci -H1 -t -vv -n" >>$tmpdir/os_files/lspci.txt 2>&1
lspci -H1 -t -vv -n >>$tmpdir/os_files/lspci.txt 2>&1
echo $LINE >>$tmpdir/os_files/lspci.txt 2>&1
echo "#lspci -v -b"  >>$tmpdir/os_files/lspci.txt 2>&1
lspci -v -b  >>$tmpdir/os_files/lspci.txt 2>&1
echo $LINE >>$tmpdir/os_files/lspci.txt 2>&1
printf "."

echo $LINE >> $tmpdir/os_files/date.txt 2>&1
echo "#/sbin/hwclock" >> $tmpdir/os_files/date.txt 2>&1
/sbin/hwclock >> $tmpdir/os_files/date.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/lsusb.txt'>lsusb</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/sbin/lsusb"  >> $tmpdir/os_files/lsusb.txt 2>&1
/sbin/lsusb  >> $tmpdir/os_files/lsusb.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/ld.so.conf.txt'>ld.so.conf</a></td></tr> " >> $WEBLEFT 2>&1
echo "#cat /etc/ld.so.conf" >>  $tmpdir/os_files/ld.so.conf.txt 2>&1
cat /etc/ld.so.conf >> $tmpdir/os_files/ld.so.conf.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/xinetd.conf.txt'>xinetd.conf</a></td></tr> " >> $WEBLEFT 2>&1
cp /etc/xinetd.conf  $tmpdir/os_files/xinetd.conf.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/fstab.txt'>fstab</a></td></tr> " >> $WEBLEFT 2>&1
cat /etc/fstab > $tmpdir/os_files/fstab.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/env.txt'>shell environment</a></td></tr> " >> $WEBLEFT 2>&1
echo "#env" > $tmpdir/os_files/env.txt 2>&1
env >> $tmpdir/os_files/env.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/chkconfig.txt'>chkconfig --list</a></td></tr> " >> $WEBLEFT 2>&1
echo "#chkconfig --list" >>$tmpdir/os_files/chkconfig.txt 2>&1
chkconfig --list >>$tmpdir/os_files/chkconfig.txt 2>&1
printf "\n"

echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL</B></td></tr> " >> $WEBLEFT 2>&1
QDepth README_queue_depth.txt
QDepthReadme

if [ ! -d $tmpdir/os_files/proc ]; then
	mkdir $tmpdir/os_files/proc >/dev/null 
	mkdir $tmpdir/os_files/proc/scsi >/dev/null 
fi

printf "Gathering /proc/scsi info ..."
cp -iprv /proc/scsi $tmpdir/os_files/proc/scsi >/dev/null 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/os_files/proc/scsi'>/proc/scsi</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /usr/lib/vmware-mui/apache/conf/httpd.conf ]; then
 cp /usr/lib/vmware-mui/apache/conf/httpd.conf $tmpdir/os_files/httpd.conf.txt > /dev/null 2>&1
fi

printf "\n"


#-------------------------------------------------------------
printf "Gathering system configuration files ..."
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/etc'>/etc conf files</a></td></tr> " >> $WEBLEFT 2>&1
DIR=/etc
OUTPUT=$tmpdir/etc
TAR=/tmp/_gsctub.tar
LOG=$tmpdir/etc/tar_output.log.txt

if [ ! -d $OUTPUT ]; then
  mkdir $OUTPUT >/dev/null 2>&1
fi
if [ ! -f $LOG ]; then
  rm $LOG >/dev/null 2>&1
fi
if [ ! -f $TAR ]; then
  rm $TAR >/dev/null 2>&1
fi

echo "#cd $DIR ; find . -type f -name '*.conf' |xargs tar -cvf $TAR " >> $LOG 2>&1
cd $DIR ; find . -type f -name "*.conf" |xargs tar -cvf $TAR  >> $LOG 2>&1

echo "#cd $OUTPUT; tar -xvf $TAR  >/dev/null 2>&1" >> $LOG 2>&1
cd $OUTPUT; tar -xvf $TAR  >>$LOG 2>&1
rm -f $TAR >/dev/null 2>&1

for File in "$OUTPUT/*"
  do
   find $File -type f |while read change
    do
      printf "."
      mv ${change} ${change}.txt > /dev/null 2>&1
    done
 done
#-------------------------------------------------------------

#--------------------------------------------------------------------
# GATHERING ERROR LOGS
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ERROR LOGS</B></td></tr>" >> $WEBLEFT 2>&1
printf "Looking for error logs ..."
if [ -d /var/log ]; then
printf "\n"
printf "Gathering /var/log/message logs..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages'>/var/log/messages</a></td></tr> " >> $WEBLEFT 2>&1
cp -f /var/log/messages* $tmpdir/messages/ > /dev/null 2>&1
cp -R /var/log/vm* $tmpdir/messages > /dev/null 2>&1
cp -R /var/log/boot* $tmpdir/messages > /dev/null 2>&1
find $tmpdir/messages -type f -print |while read file
do
printf "."
 mv $file ${file}.txt > /dev/null 2>&1
done


printf "."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.txt'>/var/log/messages</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.1.txt'>/var/log/messages.1</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.2.txt'>/var/log/messages.2</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/messages.3.txt'>/var/log/messages.3</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/'>All Error Logs</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"
else
printf "\n"
fi

echo "Gathering dmesg ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/messages/dmesg.txt'>dmesg</a></td></tr> " >> $WEBLEFT 2>&1
dmesg > $tmpdir/messages/dmesg.txt 2>&1

#--------------------------------------------------------------------
# GATHERING HBA INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HBA</B></td></tr> " >> $WEBLEFT 2>&1

echo "Looking for persistent binding ..."
grep scsi-qla $tmpdir/messages/messages.txt >> $OUTDIR/qlog 2>&1
if [ $?  = 0 ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/persistent_binding.txt'>persistent binding</a></td></tr> " >> $WEBLEFT 2>&1
echo "#grep scsi-qla $tmpdir/messages/messages.txt" >> $OUTDIR/qlog 2>&1
 mv $OUTDIR/qlog $tmpdir/hba/persistent_binding.txt 2>&1
else 
 rm -f $OUTDIR/qlog >/dev/null 2>&1
fi

echo "Checking for HBA's ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/hba.drivers.txt'>HBA Drivers(Quick View)</a></td></tr> " >> $WEBLEFT 2>&1

echo "#cd /proc/scsi; find . -type f -print | xargs egrep -i \"driver|version\"" > $tmpdir/hba/hba.drivers.txt 2>&1
cd /proc/scsi; find . -type f -print | xargs egrep -i "driver|version|adaptor" >> $tmpdir/hba/hba.drivers.txt 2>&1
cp /etc/ql*.conf $tmpdir/hba/ > /dev/null 2>&1




ls /proc/scsi/lpfc > /dev/null 2>&1
if [ $? = 0 ]; then
 printf "Gathering Emulex HBA information ..."
 ls  /proc/scsi/lpfc  |while read x
   do
     if [ -f /proc/scsi/lpfc/${x} ]; then
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      echo "-------------------- /proc/scsi/${x}----- --------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      cat /proc/scsi/${x} >> $tmpdir/hba/emulex.hba.drivers.txt 2>&1
      printf "."
     fi
    done
 printf "\n" 
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hba.drivers.txt'>Emulex HBA Drivers</a></td></tr> " >> $WEBLEFT 2>&1
fi

ls /proc/scsi/qla* > /dev/null 2>&1
if [ $? = 0 ]; then
 printf "Gathering Qlogic HBA information ..."
 ls /proc/scsi |grep qla |while read x
   do
   if [ -f /proc/scsi/${x}  ]; then
   for i in 0 1 2 3 4 5 6 7
    do
     if [ -d /proc/scsi/${x}/${i}  ]; then
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      echo "---------------------- /proc/scsi/${x}/${i} -------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      echo "--------------------------------------------------------------------" >> $tmpdir/hba/qlogic.hba.drivers.txt 2>&1
      cat /proc/scsi/${x}/${i} >>$tmpdir/hba/qlogic.hba.drivers.txt  2>&1
      printf "."
     fi
    done
    fi
  done
 printf "\n"
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic.hba.drivers.txt'>Qlogic HBA Drivers</a></td></tr> " >> $WEBLEFT 2>&1
fi



scli -V >$OUTDIR/.scli 2>&1
if [ $? = 0 ]; then
echo "Found Qlogic scli command ... extracting hba info ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic.scli.txt'>Qlogic SCLI HBA Info</a></td></tr> " >> $WEBLEFT 2>&1
  mv $OUTDIR/.scli $tmpdir/hba/qlogic.scli.txt 
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -c all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -c all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -i all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -i all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -t all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -t all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -p all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -p all >>$tmpdir/hba/qlogic.scli.txt 2>&1
   echo $LINE >> $tmpdir/hba/qlogic.scli.txt 2>&1
  	echo "scli -z all" >>$tmpdir/hba/qlogic.scli.txt 2>&1
  scli -z all >>$tmpdir/hba/qlogic.scli.txt 2>&1
else
 rm -f $OUTDIR/.scli >/dev/null 2>&1
fi

QLOG=$tmpdir/hba/qlogic_iscli.txt

#####################################################################
# Gather iscli info (if it is installed)
#####################################################################
echo -n "Searching for iscli ... "
if test -x /usr/local/bin/iscli -o -x /usr/bin/iscli
then
   echo -n "installed ... "
   echo -n "Gathering HBA configuration information ... "
   QLOG=$LOGDIR/iscli.out

   #####################################################################
   # Display program version
   #####################################################################
   echo "=================================================" > $QLOG
   echo "Program Version" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -ver >> $QLOG; echo >> $QLOG

   #####################################################################
   # Display general information
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "General Information" >> $QLOG
   echo "=================================================" >> $QLOG
   iscli -g >> $QLOG

   #####################################################################
   # Display number of hba_nos 
   #####################################################################
   echo "=================================================" >> $QLOG
   echo "HBA Instance Information" >> $QLOG
   echo "=================================================" >> $QLOG
   HBA_COUNT=`iscli -i | tee -a $QLOG | grep Instance | wc -l`

   #####################################################################
   # if HBA_COUNT > 0, loop through all instances for additional information
   #####################################################################
   HBA_INSTANCE=0
   while test $HBA_COUNT -gt 0
   do
      echo >> $QLOG
      echo "===========================================================" >> $QLOG
      echo "Detailed Information for HBA Instance $HBA_INSTANCE" >> $QLOG
      echo "===========================================================" >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Configuration Settings" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -c $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Port Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -pinfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Statistics" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -stat $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Bootcode Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -binfo $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE VPD Information" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -vpd $HBA_INSTANCE >> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Information" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -dspchap $HBA_INSTANCE >> $QLOG
      iscli -dspchap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE CHAP Map to Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      # Some folks did not like having this extracted
      #   iscli -chapmap $HBA_INSTANCE >> $QLOG
      iscli -chapmap $HBA_INSTANCE |grep -v Name|grep -v Secret>> $QLOG

      echo "=================================================" >> $QLOG
      echo "HBA $HBA_INSTANCE Persistently Bound Targets" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -ps $HBA_INSTANCE >> $QLOG


      ##################################################################
      # Get list of targets to loop through specific information
      ##################################################################
      TARGET_LIST=`iscli -t $HBA_INSTANCE | grep "Target ID" | cut -c11-15`
      for TARGET_NO in $TARGET_LIST
      do
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO Information" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -t $HBA_INSTANCE $TARGET_NO >> $QLOG
         echo "=================================================" >> $QLOG
         echo "HBA $HBA_INSTANCE Target $TARGET_NO LUN List" >> $QLOG
         echo "=================================================" >> $QLOG
         iscli -l $HBA_INSTANCE $TARGET_NO >> $QLOG
      done

      echo >> $QLOG
      echo "=================================================" >> $QLOG
      echo "Retrieving HBA $HBA_INSTANCE Crash Dump (if exists)" >> $QLOG
      echo "=================================================" >> $QLOG
      iscli -gcr $HBA_INSTANCE $LOGDIR/iscsi_crash_$HBA_INSTANCE.out

      HBA_COUNT=`expr $HBA_COUNT - 1`
      HBA_INSTANCE=`expr $HBA_INSTANCE + 1`
   done

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qlogic_iscli.txt'>Qlogic HBA iscli output</a></td></tr> " >> $WEBLEFT 2>&1

fi



if [ -f $tmpdir/hba/qla2xxx.conf ]; then 
 mv $tmpdir/hba/qla2xxx.conf $tmpdir/hba/qla2xxx.conf.txt
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qla2xxx.conf.txt'>Qlogic /etc/qla2xxx.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f $tmpdir/hba/qla3xxx.conf ]; then 
 mv $tmpdir/hba/qla3xxx.conf $tmpdir/hba/qla3xxx.conf.txt
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/qla3xxx.conf.txt'>Qlogic /etc/qla3xxx.conf</a></td></tr> " >> $WEBLEFT 2>&1
fi

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba'>HBA Directory</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /usr/sbin/hbanyware/hbacmd ]; then

echo "Found hbanyware ..."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.txt'>Hbanyware info</a></td></tr> " >> $WEBLEFT 2>&1
echo "/usr/sbin/hbanyware/hbacmd version " >>$tmpdir/hba/emulex.hbanyware.txt 2>&1
/usr/sbin/hbanyware/hbacmd version >>$tmpdir/hba/emulex.hbanyware.txt 2>&1
echo $LINE >> $tmpdir/hba/emulex.hbanyware.txt 2>&1

echo "/usr/sbin/hbanyware/hbacmd listhbas" >> $tmpdir/hba/emulex.hbanyware.listhbas.txt 2>&1
/usr/sbin/hbanyware/hbacmd listhbas >> $tmpdir/hba/emulex.hbanyware.listhbas.txt 2>&1
echo $LINE >> $tmpdir/hba/emulex.hbanyware.listhbas.txt 2>&1

echo "Gathering HBA information from Emulex hbanyware ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.hbainfo.txt'>Emulex HBAnyware HBAinfo</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/emulex.hbanyware.listhbas.txt'>Emulex HBAnyware listhbas</a></td></tr> " >> $WEBLEFT 2>&1
grep "Port WWN" $tmpdir/hba/emulex.hbanyware.listhbas.txt |awk '{print $4}' |while read wwpn 
 do
	echo "[$wwpn] ====================================" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd DriverParams $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd DriverParams $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd HBAAttrib $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd HBAAttrib $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd AllNodeInfo $wwpn " >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd AllNodeInfo $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo $LINE >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	echo "/usr/sbin/hbanyware/hbacmd TargetMapping $wwpn" >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
	/usr/sbin/hbanyware/hbacmd TargetMapping $wwpn >> $tmpdir/hba/emulex.hbanyware.hbainfo.txt 2>&1
done
fi

if [ -f /etc/lpfc.conf ] ; then
 echo "Found lpfc.conf ..."
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpfc.conf.txt'>Emulex lpfc.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/lpfc.conf $tmpdir/hba/lpfc.conf.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/lpfc.queue.depth.txt'>Emulex Queue Depth</a></td></tr> " >> $WEBLEFT 2>&1
 echo "grep queue /etc/lpfc.conf" >> $tmpdir/hba/lpfc.queue.depth.txt 2>&1
 grep queue /etc/lpfc.conf >> $tmpdir/hba/lpfc.queue.depth.txt 2>&1
fi

cimprovider -l >> $OUTDIR/.cfile 2>&1
if [ $? = 0 ] ; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hba/cimprovider-l.txt'>cimprovider -l</a></td></tr> " >> $WEBLEFT 2>&1
 mv $OUTDIR/.cfile $tmpdir/hba/cimprovider-l.txt 2>&1
else 
 rm $OUTDIR/.cfile > /dev/null 2>&1
fi

#--------------------------------------------------------------------
# GATHERING BOOT INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>BOOT INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf  "Gathering System Boot Information ..."
getfiles /etc/rc.d boot
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/boot/'>/etc/rc.d</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /etc/lilo.conf ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/boot/lilo.conf.txt'>lilo.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/lilo.conf $tmpdir/boot/lilo.conf.txt 2>&1
fi

printf "\n"
#--------------------------------------------------------------------
# GATHERING KERNEL INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>KERNEL INFO</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering Kernel Information ..."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/lsmod.txt'>lsmod</a></td></tr>" >> $WEBLEFT 2>&1
/sbin/lsmod > $tmpdir/kernel/lsmod.txt 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/kernel.txt'>kernel</a></td></tr>" >> $WEBLEFT 2>&1
echo "#/bin/rpm -qa |grep -i kernel" >> $tmpdir/kernel/kernel.txt 2>&1
/bin/rpm -qa |grep -i kernel >> $tmpdir/kernel/kernel.txt 2>&1
printf "."

if [ -d /proc/vmware/config ]; then
 /usr/sbin/vmkload_mod -lv >> $tmpdir/kernel/vmkload_mod.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkload_mod.txt'>vmkload_mod -lv</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

 /sbin/vmware-sfdisk -l >> $tmpdir/kernel/vmware-sfdisk.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmware-sfdisk.txt'>vmware-sfdisk</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."

 vmkpcidivy -q vmkmod >> $tmpdir/kernel/vmkpcidivy.vmkmod.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_vmkmod.txt'>vmkpcidivy_vmkmod</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."


 vmkpcidivy -q vmkdump_part >> $tmpdir/kernel/vmkpcidivy.vmkdump_part.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_vmkdump_part.txt'>vmkpcidivy vmkdump_part</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."

 vmkpcidivy -q vmkdump_dev >> $tmpdir/kernel/vmkpcidivy.vmkdump_dev.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_vmkdump_dev.txt'>vmkpcidivy vmkdump_dev</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."

 vmkpcidivy -q vmhba_devs >> $tmpdir/kernel/vmkpcidivy.vmhba_devs.txt
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_vmhba_devs.txt'>vmkpcidivy vmhba_devs</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."

 vmkpcidivy -q labels >> $tmpdir/kernel/vmkpcidivy.labels.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_labels.txt'>vmkpcidivy labels</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."

 vmkpcidivy -q vmfs_part >> $tmpdir/kernel/vmkpcidivy.vmfs_part.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkpcidivy_vmfs_part.txt'>vmkpcidivy vmfs_part</a></td></tr> " >> $WEBLEFT 2>&1
 printf "."


  mkdir $tmpdir/kernel/mii-tool > /dev/null 2>&1
  for VMFS in `vmkpcidivy -q vmfs_part` 
  do
   vmkfstools -lM $VMFS >> $tmpdir/kernel/$VMFS.txt 2>&1
  done
  for vmnicNode in `ls -d /proc/vmware/net/vmnic*`
   do
     vmnic=`basename $vmnicNode`
     mii-tool -vv $vmnic >> $tmpdir/kernel/mii-tool/mii-tool-$vmnic.txt 2>&1
     printf "."
   done

   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/mii-tool/vmkpcidivy_vmkdump_dev.txt'>vmkpcidivy vmkdump_dev</a></td></tr> " >> $WEBLEFT 2>&1


     vmkchdev -L  >> $tmpdir/kernel/vmkchdev.txt 2>&1
     echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkchdev.txt'>vmkchdev -L</a></td></tr> " >> $WEBLEFT 2>&1
     printf "."
     vmkmultipath -q  >> $tmpdir/kernel/vmkmultipath.txt 2>&1
     echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/vmkmultipath.txt'>vmkmultipath -q</a></td></tr> " >> $WEBLEFT 2>&1
     printf "."
     cat /proc/vmware/sched/* >> $tmpdir/kernel/sched-all.txt 2>&1
     echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/kernel/sched-all.txt'>cat /proc/vmware/sched</a></td></tr> " >> $WEBLEFT 2>&1
     sleep 5
     echo $LINE >> $tmpdir/kernel/sched-all.txt 2>&1
     cat /proc/vmware/sched/* >> $tmpdir/kernel/sched-all.txt 2>&1

fi  # end IF

echo "#cat /proc/partitions"  >> $tmpdir/kernel/proc.txt 2>&1
cat /proc/partitions  >> $tmpdir/kernel/proc.txt 2>&1
printf "\n"


#--------------------------------------------------------------------
# GATHERING SOFTWARE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>SOFTWARE</B></td></tr> " >> $WEBLEFT 2>&1

printf "Gathering software info ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/rpm.qia.txt'>rpm -qia</a></td></tr> " >> $WEBLEFT 2>&1
echo "#rpm -qia" >> $tmpdir/software/rpm.qia.txt 2>&1
rpm -qia >> $tmpdir/software/rpm.qia.txt 2>&1


echo "#perl -v" >> $tmpdir/software/perl.txt 2>&1
perl -v >> $tmpdir/software/perl.txt 2>&1
echo $LINE >> $tmpdir/software/perl.txt 2>&1
echo "#ls -al /usr/bin/perl">> $tmpdir/software/perl.txt 2>&1
ls -al /usr/bin/perl >> $tmpdir/software/perl.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/perl.txt'>perl -v</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#gcc -v " >> $tmpdir/software/gcc.txt 2>&1
(gcc -v)  >> $tmpdir/software/gcc.txt 2>&1
if [ $? = 0 ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/gcc.txt'>gcc -v</a></td></tr> " >> $WEBLEFT 2>&1
fi

printf "."

echo "#ls -Al /opt" >> $tmpdir/software/ls.opt.txt 2>&1
ls -Al /opt  >> $tmpdir/software/ls.opt.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/ls.opt.txt'>List of /opt</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

echo "#java -version"  >> $tmpdir/software/java.txt 2>&1
java -version  >> $tmpdir/software/java.txt 2>&1
echo $LINE >> $tmpdir/software/java.txt 2>&1
echo "#ls -al /usr/ |grep java" >> $tmpdir/software/java.txt 2>&1
ls -al /usr/ |grep java >> $tmpdir/software/java.txt 2>&1
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/software/java.txt'>Java Info</a></td></tr> " >> $WEBLEFT 2>&1
printf "\n"



#--------------------------------------------------------------------
# GATHERING DISK INFO
#--------------------------------------------------------------------
printf "Gathering disk info ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>DISK INFO</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lsraid.txt'>lsraid</a></td></tr> " >> $WEBLEFT 2>&1
echo "#lsraid -R -p" > $tmpdir/disk/lsraid.txt 2>&1
lsraid -R -p >> $tmpdir/disk/lsraid.txt 2>&1
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/fdisk-l.txt'>fdisk</a></td></tr> " >> $WEBLEFT 2>&1
echo "#/sbin/fdisk -l" > $tmpdir/disk/fdisk-l.txt 2>&1
/sbin/fdisk -l >> $tmpdir/disk/fdisk-l.txt 2>&1
printf "."


echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/dev.sd_devices.txt'>ls /dev/sd </a></td></tr> " >> $WEBLEFT 2>&1
echo "#ls -Al /dev/sd*" > $tmpdir/disk/dev.sd_devices.txt 2>&1
ls -Al /dev/sd* >> $tmpdir/disk/dev.sd_devices.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/proc.scsi.txt'>/proc/scsi/scsi</a></td></tr>" >> $WEBLEFT 2>&1
echo "#cat /proc/scsi/scsi " >> $tmpdir/disk/proc.scsi.txt 2>&1
cat /proc/scsi/scsi >> $tmpdir/disk/proc.scsi.txt 2>&1
printf "."

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/lvmdiskscan.txt'>lvmdiskscan </a></td></tr> " >> $WEBLEFT 2>&1
echo "# lvmdiskscan" > $tmpdir/disk/lvmdiskscan.txt 2>&1
lvmdiskscan >> $tmpdir/disk/lvmdiskscan.txt 2>&1
printf "\n"

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/devlabel.txt'>devlabel</a></td></tr> " >> $WEBLEFT 2>&1
if [ -f /etc/sysconfig/devlabel ] ; then
 echo "Found devlabel ..."
 echo "# cat /etc/sysconfig/devlabel" >> $tmpdir/disk/devlabel.txt 2>&1
 cat /etc/sysconfig/devlabel >> $tmpdir/disk/devlabel.txt 2>&1
fi


if  [ -f /sbin/tune2fs ]; then
 printf "Running tune2fs on /dev/sd* ..."
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/disk/tune2fs.txt'>Tune2fs</a></td></tr>" >> $WEBLEFT 2>&1
 cat /proc/partitions |grep sd |awk '{print $4}'|while read x
  do
  echo "==================/dev/$x========================" >> $tmpdir/disk/tune2fs.txt 2>&1
  echo "tune2fs -l /dev/$x" >> $tmpdir/disk/tune2fs.txt 2>&1
  tune2fs -l /dev/$x >> $tmpdir/disk/tune2fs.txt 2>&1
  printf "."
 done
 printf "\n"
fi

#--------------------------------------------------------------------
# GATHERING NETWORKING INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>NETWORKING</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/dns.txt'>DNS lookup info</a></td></tr> " >> $WEBLEFT 2>&1

echo "Performing a forward dig lookup based on hostname ..."
hostname | dig +qr $y >> $tmpdir/networking/dns.txt 2>&1
echo $LINE >> $tmpdir/networking/dns.txt 2>&1

echo "Performing a reverse dig based on IP Address ..."
grep localhost /etc/hosts | awk '{print $1}' |dig -x >> $tmpdir/networking/dns.txt 2>&1
echo $LINE >> $tmpdir/networking/$dns.txt 2>&1

/sbin/arp -a >> $tmpdir/networking/dns.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/etc.hosts.txt'>/etc/hosts</a></td></tr> " >> $WEBLEFT 2>&1
cat /etc/hosts > $tmpdir/networking/etc.hosts.txt 2>&1
echo $LINE >> $tmpdir/networking/$dns.txt 2>&1
cat /etc/resolv.conf >> $tmpdir/networking/dns.txt 2>&1

echo "hostname=$HOSTNAME" > $tmpdir/getconfig_v${VERSION}_${HOSTNAME}.txt 2>&1

echo "Checking available ports ..."
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/netstat.txt'>netstat info</a></td></tr> " >> $WEBLEFT 2>&1
/bin/netstat -a -n -p >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
/bin/netstat -s >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1
/bin/netstat -i -a >> $tmpdir/networking/netstat.txt 2>&1
echo $LINE >> $tmpdir/networking/netstat.txt 2>&1

echo "Pinging Local Interface ..."
echo "#ping -c5 `/sbin/route -n | grep eth0 | tail -1 | awk '{print $2}'`" >> $tmpdir/networking/ping.txt 2>&1
ping -c5 `/sbin/route -n | grep eth0 | tail -1 | awk '{print $2}'` >> $tmpdir/networking/ping.txt 2>&1

echo "Checking Routing Table ..."
echo "#route" >> $tmpdir/networking/route.txt 2>&1
route >> $tmpdir/networking/route.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/route.txt'>route</a></td></tr> " >> $WEBLEFT 2>&1

echo "#mii-tool -v " >> $tmpdir/networking/mii-tool.txt 2>&1
mii-tool -v >> $tmpdir/networking/mii-tool.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/mii-tool.txt'>mii-tool</a></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering WWPN ..."
/usr/sbin/wwpn.pl -v >> $tmpdir/networking/wwpn.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/wwpn.txt'>wwpn</a></td></tr> " >> $WEBLEFT 2>&1

echo "Gathering misc system networking information ..."
if [ -f /etc/snmp/snmpd.conf ]; then
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/networking/snmpd.conf.txt'>snmpd.conf</a></td></tr> " >> $WEBLEFT 2>&1
 cp /etc/snmp/snmpd.conf   $tmpdir/networking/snmpd.conf.txt 2>&1
fi

#--------------------------------------------------------------------
# GATHERING VMWARE INFO
#--------------------------------------------------------------------
printf "Gathering /etc/vmware info ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>VMWARE INFO</B></td></tr> " >> $WEBLEFT 2>&1
mkdir $tmpdir/vmware > /dev/null 2>&1
mkdir $tmpdir/vmware/vmware > /dev/null 2>&1
mkdir $tmpdir/vmware/pam.d > /dev/null 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware/etc'>/etc/vmware</a></td></tr> " >> $WEBLEFT 2>&1
getfiles /etc/vmware os_files/vmware 

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware/pam.d'>/etc/pam.d</a></td></tr> " >> $WEBLEFT 2>&1
getfiles /etc/pam.d vmware/pam.d 

echo "#/sbin/hplog -v" >> $tmpdir/vmware/hplog-v.txt 2>&1
/sbin/hplog -v >> $tmpdir/vmware/hplog-v.txt 2>&1
printf "."
if [ -d  /home/hitachi/vmware/linux ]; then
cp /home/hitachi/vmware/linux/vmware.log $tmpdir/vmware/vmware.log.txt 2>&1
cp /home/hitachi/vmware/linux/linux.vmx $tmpdir/vmware/linux.vmx.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware/vmware.log.txt'>vmware.log</a></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware/linux.vmx.txt'>linux.vmx</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -x /usr/bin/omreport ]; then
printf "\n"
printf "Gathering omreport info ..."

   /usr/bin/omreport system alertlog >> $tmpdir/omreport/omreport-alert.txt 2>&1
   /usr/bin/omreport system cmdlog  >> $tmpdir/omreport/omreport-cmdlog.txt 2>&1
   /usr/bin/omreport system esmlog >> $tmpdir/omreport/omreport-esmlog.txt 2>&1
   /usr/bin/omreport system postlog >> $tmpdir/omreport-postlog.txt 2>&1
   /usr/bin/omreport chassis temps >> $tmpdir/omreport-temps.txt 2>&1
   /usr/bin/omreport chassis fans >> $tmpdir/omreport/omreport-fans.txt 2>&1
   /usr/bin/omreport chassis memory >> $tmpdir/omreport/omreport-memory.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-cmdlog.txt'>omreport cmdlog</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-esmlog.txt'>omreport esmlog</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport_alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-postlog.txt'>omreport postlog</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport_alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-temps.txt'>omreport temps</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport_alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-fans.txt'>omreport fans</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport_alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-memory.txt'>omreport memory</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport_alert.txt'>omreport alert</a></td></tr> " >> $WEBLEFT 2>&1

fi
printf "\n"
printf "Gathering vmware database dump info ..."
grab_vmdb=1
if [ \( $grab_vmdb -eq 1 \) -a \( -x /usr/sbin/vmdbsh \) ]; then
      cat > /tmp/vmdbdump.txt << VMDBDUMP_EOF
connect
mount / /all
rget /all
exit
VMDBDUMP_EOF

#/usr/sbin/vmdbsh -x /tmp/vmdbdump.txt >>$tmpdir/vmware/vmdbdump.txt 2>&1
/usr/sbin/vmdbsh -x /tmp/vmdbdump.txt >>$tmpdir/vmware/vmdbdump.txt 2>&1
rm -f /tmp/vmdbdump.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/omreport/omreport-memory.txt'>omreport memory</a></td></tr> " >> $WEBLEFT 2>&1   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/vmware/vmdbdump.txt'>vmdbdump</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "\n"
#--------------------------------------------------------------------
# GATHERING PERFORMANCE INFO
#--------------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>PERFORMANCE</B></td></tr> " >> $WEBLEFT 2>&1

#
printf "Gathering System Performance Information ... (may take 30 seconds)"

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-aux.txt'>ps aux</a></td></tr> " >> $WEBLEFT 2>&1
echo "#ps aux" >> $tmpdir/performance/ps-aux.txt 2>&1
ps aux >> $tmpdir/performance/ps-aux.txt 2>&1
echo "#ps -elF" >> $tmpdir/performance/ps-elf.txt 2>&1
ps -elF >> $tmpdir/performance/ps-elf.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/ps-elf.txt'>ps -elF</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
echo "#free" >> $tmpdir/performance/free.txt 2>&1
free >> $tmpdir/performance/free.txt 2>&1
echo $LINE >>$tmpdir/performance/free.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/free.txt'>free</a></td></tr> " >> $WEBLEFT 2>&1
printf "."
echo "#cat /proc/swaps" >>$tmpdir/performance/swaps.txt 2>&1
cat /proc/swaps >>$tmpdir/performance/swaps.txt 2>&1
echo $LINE >> $tmpdir/performance/swaps.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/swaps.txt'>cat /proc/swaps</a></td></tr> " >> $WEBLEFT 2>&1
printf "."

ps -ef |grep vmstat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/vmstat.txt'>vmstat</a></td></tr> " >> $WEBLEFT 2>&1
vmstat 1 10 >> $tmpdir/performance/vmstat.txt 2>&1 &
i=0;
while [ $i = 0 ]
do
 ps -ef |grep "vmstat 1 10" |grep -v grep  > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
fi

ps -ef |grep lsof |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
 if [ -x /usr/sbin/lsof ]; then
  echo "#lsof -l -n -P -b" >> $tmpdir/performance/lsof.txt 2>&1
  lsof -l -n -P -b >> $tmpdir/performance/lsof.txt 2>&1
  echo $LINE >> $tmpdir/performance/lsof.txt 2>&1
  echo "#lsof -i -n -P -b" >> $tmpdir/performance/lsof.txt 2>&1
  lsof -i -n -P -b >> $tmpdir/performance/lsof.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/lsof.txt'>lsof</a></td></tr> " >> $WEBLEFT 2>&1
 fi
fi

ps -ef |grep iostat |grep -v grep >/dev/null 2>&1
if [ $? != 0 ]; then
echo "#iostat -p" >> $tmpdir/performance/iostat.txt 2>&1 &
iostat -p >> $tmpdir/performance/iostat.txt 2>&1 &
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/iostat.txt'>iostat -p</a></td></tr> " >> $WEBLEFT 2>&1
fi


printf "."
top -b -n2 >> $tmpdir/performance/top.txt 2>&1
if [ $? = 0 ]; then
echo " <tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/performance/top.txt'>top</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "\n"

# End VMWARE Functions

fi # end VMWARE ONLY
}
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
printf "\n"
####################################################################
# HDLM/HPM FUNCTION
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################

hdlm()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

###  This section tests for HPM installation then obtains available data


echo "Checking to see if HPM/DLM is installed ..."

if [ -f /opt/HITdpo/bin/showvpath ]
then
echo "Found HPM ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HPM</B></td></tr> " >> $WEBLEFT 2>&1

echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hpm/hpmifo.txt'><B>HPM INFO</B></a></td></tr> " >> $WEBLEFT 2>&1
	mkdir $tmpdir/hpm > /dev/null 2>&1
	echo "" > $tmpdir/hpm/hpminfo.txt
	echo "This files contains HPM specific info" >> $tmpdir/hpm/hpminfo.txt
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "The following shows HPM package info" >> $tmpdir/hpm/hpminfo.txt
	echo $LINE >> $tmpdir/hpm/hpminfo.txt

	case $SYSOS in
	sun)
   		/bin/pkginfo -l HITdpo >> $tmpdir/hpm/hpminfo.txt 2>&1
  		;;
	hpux )
		grep HITdpo $tmpdir/software/swlist-l_product.txt >> $tmpdir/hpm/hpminfo.txt 2>&1
		 ;;
	aix)
	 	grep HITdpo $tmpdir/software/software_lslpp-L.txt >> $tmpdir/hpminfo.txt 2>&1
  		lsvpcfg >> $tmpdir/hpm/dlm_lsvpcfg.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hpm/dlm_lsvpcfg.txt'><B>HPM lsvpcfg</B></a></td></tr> " >> $WEBLEFT 2>&1
	 	;;
	linux)
	 	grep  HITdpo $tmpdir/os_files/rpm.qisva.txt >> $tmpdir/hpminfo.txt 2>&1
 		;;
	esac

	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "The following lists all system vpaths" >> $tmpdir/hpm/hpminfo.txt
	echo $LINE >> $tmpdir/hpm/hpminfo.txt
	/opt/HITdpo/bin/showvpath >> $tmpdir/hpm/hpminfo.txt 2>&1
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "The following lists all vpath adapters found" >> $tmpdir/hpm/hpminfo.txt
	echo $LINE >> $tmpdir/hpm/hpminfo.txt
	/opt/HITdpo/bin/datapath query adapter >> $tmpdir/hpm/hpminfo.txt 2>&1
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "" >> $tmpdir/hpm/hpminfo.txt
	echo "The following lists all vpath devices found" >> $tmpdir/hpm/hpminfo.txt
	echo $LINE >> $tmpdir/hpm/hpminfo.txt
	/opt/HITdpo/bin/datapath query device >> $tmpdir/hpm/hpminfo.txt 2>&1
else
	echo "Hitachi Path Manager was not found" > $tmpdir/not_found/no_hpm
fi

###  This section tests for HDLM installation, then obtains available data
FOUNDHDLM=0
if [ $SYSOS = aix ]; then
  if [ -d /usr/DynamicLinkManager/bin ] && [ $FOUNDHDLM = 0 ]; then
      FOUNDHDLM=1 
       echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HDLM</B></td></tr> " >> $WEBLEFT 2>&1
       echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdlm/ls.hdlm.txt'>HDLM File list</a></td></tr> " >> $WEBLEFT 2>&1
        mkdir $tmpdir/hdlm > /dev/null 2>&1
        echo "Gathering DLM information ..."
        echo "ls -AlR /usr/DynamicLinkManager" >> $tmpdir/hdlm/ls.hdlm.txt 2>&1
        ls -AlR /usr/DynamicLinkManager >> $tmpdir/hdlm/ls.hdlm.txt 2>&1
        printf "Running DLMGetras ..."
	if [ -f /usr/DynamicLinkManager/bin/DLMgetras ]; then
	 cd /usr/DynamicLinkManager/bin; /usr/DynamicLinkManager/bin/DLMgetras  $tmpdir/hdlm/dlmgetras  > $tmpdir/hdlm/dlmgetras_result.txt 2>&1 &
	 waitfor $!
	 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdlm/dlmgetras'>DLMgetras</a></td></tr> " >> $WEBLEFT 2>&1
	else
	 echo "Problem: DLMgetras not found in /usr/DynamicLinkManager/bin ..."
	 echo "Problem: DLMgetras not found in /usr/DynamicLinkManager/bin ..."  >> $tmpdir/not_found/no_hdlm 2>&1
	fi
        grep DLManager $tmpdir/software/software_lslpp-L.txt >> $tmpdir/hdlm/hdlminfo.txt 2>&1
	printf "\n"
  else
	echo "Hitachi Dynamic Link Manager was not found in /usr/DynamicLinkManager" > $tmpdir/not_found/no_hdlm 2>&1
  fi      

fi


if [ -d /opt/DynamicLinkManager/bin ] && [ $FOUNDHDLM = 0 ];
then
      FOUNDHDLM=1 
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HDLM</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdlm/'>HDLM Info</a></td></tr> " >> $WEBLEFT 2>&1
echo "Found HDLM ..."
        mkdir $tmpdir/hdlm > /dev/null 2>&1
        case $SYSOS in
        sun)
                /bin/pkginfo -l DLManager >> $tmpdir/hdlm/hdlminfo.txt 2>&1
                ;;
        hpux )
                grep DLManager $tmpdir/software/swlist-l_product.txt >> $tmpdir/hdlm/hdlminfo.txt 2>&1
                 ;;
        linux)
                grep  DLManager $tmpdir/os_files/rpm.qisva.txt >> $tmpdir/hdlm/hdlminfo.txt > /dev/null 2>&1
                ;;
        esac
        printf "Running DLMGetras ..."
	cd /opt/DynamicLinkManager/bin;/opt/DynamicLinkManager/bin/DLMgetras $tmpdir/hdlm/dlmgetras  > $tmpdir/hdlm/dlmgetras_result.txt 2>&1 &
        waitfor $!
        printf "\n"
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdlm/dlmgetras'>DLMgetras</a></td></tr> " >> $WEBLEFT 2>&1
else
	echo "Hitachi Dynamic Link Manager was not found in /opt/DynamicLinkManager" > $tmpdir/not_found/no_hdlm
fi

if [ -d /etc/opt/DynamicLinkManager ] 
then
 mkdir $tmpdir/hdlm > /dev/null 2>&1
 cp /etc/opt/DynamicLinkManager/.dlmfdrv*  $tmpdir/hdlm > /dev/null 2>&1
fi

if [ -f /opt/DynamicLinkManager/.dlmfdrv.conf ]
then
 mkdir $tmpdir/hdlm > /dev/null 2>&1
 cp /etc/opt/DynamicLinkManager/.dlmfdrv*  $tmpdir/hdlm > /dev/null 2>&1
fi

}

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# HORCM FUNCTIONS
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

horcm()
{
if [ -f /tmp/.setx ]; then
 set -x
fi


###  This section tests for HORCM installation then obtains available data
echo "Checking to see if HORCM is installed ..."
for horcmdir in "/HORCM" "/opt/HORCM" "/opt/hds/bin/HORCM" 
do 
 foundhorcm=0
 if [ -d $horcmdir ] && [ -d $horcmdir/usr/bin ] ; then
  foundhorcm=1
 fi

 if [ $foundhorcm = 1 ]; then
       echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HORCM</B></td></tr> " >> $WEBLEFT 2>&1
   	echo "Found HORCM in $horcmdir..."
	mkdir $tmpdir/horcm > /dev/null 2>&1
	echo $LINE > $tmpdir/horcm/horcm_info.txt
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm_info.txt'>HORCM INFO</a></td></tr> " >> $WEBLEFT 2>&1
	echo "This files contains HORCM specific info" >> $tmpdir/horcm/horcm_info.txt
	echo $LINE >> $tmpdir/horcm/horcm_info.txt
	echo "The following is the.txtput of the HORCMINST and the HORCC_MRCF variables:" >> $tmpdir/horcm/horcm_info.txt
	echo $LINE >> $tmpdir/horcm/horcm_info.txt
	echo "HORCMINST is set to $HORCMINST" >> $tmpdir/horcm/horcm_info.txt
	echo "HORCC_MRCF is set to $HORCC_MRCF" >> $tmpdir/horcm/horcm_info.txt
	echo $LINE >> $tmpdir/horcm/horcm_info.txt

	echo "Gathering logs from $horcmdir/logs ..."
 	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/logs'>HORCM Logs</a></td></tr> " >> $WEBLEFT 2>&1	
	mkdir $tmpdir/horcm/logs > /dev/null 2>&1
	cp -R $horcmdir/log* $tmpdir/horcm/logs > /dev/null 2>&1
	cp /etc/horcm*.conf $tmpdir/horcm
        cp $tmpdir/horcm/horcm.conf $tmpdir/horcm/horcm.conf.txt > /dev/null 2>&1
        cp $tmpdir/horcm/horcm0.conf $tmpdir/horcm/horcm0.conf.txt > /dev/null 2>&1
        cp $tmpdir/horcm/horcm1.conf $tmpdir/horcm/horcm1.conf.txt > /dev/null 2>&1
	if [ -f $tmpdir/horcm/horcm0.conf ]; then
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm0.conf.txt'>horcm0.conf</a></td></tr> " >> $WEBLEFT 2>&1	
	fi
	if [ -f $tmpdir/horcm/horcm1.conf ]; then
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm1.conf.txt'>horcm1.conf</a></td></tr> " >> $WEBLEFT 2>&1	
	fi
	if [ -f $tmpdir/horcm/horcm.conf ]; then
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm.conf.txt'>horcm.conf</a></td></tr> " >> $WEBLEFT 2>&1	
	fi
       echo "Running $horcmdir/usr/horcctl -D ..."
       echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcctl-D.txt'>horcctl -D</a></td></tr> " >> $WEBLEFT 2>&1	
       echo "$horcmdir/usr/bin/horcctl -D " >> $tmpdir/horcm/horcctl-D.txt 2>&1
       $horcmdir/usr/bin/horcctl -D >> $tmpdir/horcm/horcctl-D.txt 2>&1


       echo "Running $horcmdir/usr/bin/raidqry ..."
       echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/raidqry.txt'>raidqry -l</a></td></tr> " >> $WEBLEFT 2>&1	
       echo "$horcmdir/usr/bin/raidqry -l " >> $tmpdir/horcm/raidqry.txt 2>&1
       $horcmdir/usr/bin/raidqry -l  >> $tmpdir/horcm/raidqry.txt 2>&1


       echo "Running $horcmdir/usr/bin/inqraid ..."
       echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/inqraid.txt'>inqraid</a></td></tr> " >> $WEBLEFT 2>&1	
      case $SYSOS in
        sun)
            echo "#ls /dev/rdsk | $horcmdir/usr/bin/inqraid -fxg -CLI " >> $tmpdir/horcm/inqraid.txt 2>&1
            ls /dev/rdsk | $horcmdir/usr/bin/inqraid -fxg -CLI  >> $tmpdir/horcm/inqraid.txt 2>&1
            ;;
        hpux)
            echo "#ioscan -fun | grep rdsk | $horcmdir/usr/bin/inqraid -fxg -CLI " >> $tmpdir/horcm/inqraid.txt 2>&1
            ioscan -fun |grep rdsk | $horcmdir/usr/bin/inqraid -fxg -CLI  >> $tmpdir/horcm/inqraid.txt 2>&1
            ;;
        linux)
            echo "#ls /dev/rdisk/dsk* | $horcmdir/usr/bin/inqraid -fxg -CLI " >> $tmpdir/horcm/inqraid.txt 2>&1
            ls /dev/rdisk/dsk*  |$horcmdir/usr/bin/inqraid -fxg -CLI  >> $tmpdir/horcm/inqraid.txt 2>&1
            ;;
         aix)
             echo "#lsdev -Cc disk | grep hdisk | $horcmdir/usr/bin/inqraid -CLI ">> $tmpdir/horcm/inqraid.txt 2>&1
             lsdev -Cc disk | grep hdisk | $horcmdir/usr/bin/inqraid -CLI >> $tmpdir/horcm/inqraid.txt 2>&1
         ;;
      esac




      echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm_processes.txt'>ps -ef|grep horcm</a></td></tr> " >> $WEBLEFT 2>&1	
      echo "ps -ef |grep horcm " > $tmpdir/horcm/horcm_processes.txt 2>&1
      ps -ef |grep horcm|grep -v grep  >> $tmpdir/horcm/horcm_processes.txt 2>&1

#-----------------------------------------------------
if [ -f $tmpdir/horcm/horcm0.conf ]; then

flag=0
LOG=$OUTDIR/.horcmlog
PORTLOG=$OUTDIR/.horcmportlog
rm $LOG > /dev/null 2>&1
rm $PORTLOG > /dev/null 2>&1

printf "Gathering Group ID from horcm0.conf ..."
cat $tmpdir/horcm/horcm0.conf |awk '{print $1}' |sed '/^$/d' |while read line;
do
 echo $line |grep "HORCM_INST" > /dev/null 2>&1
 if [ $? = 0 ]; then
  flag=0; break;
 fi;
 echo $line |grep "dev_group" > /dev/null 2>&1
 if [ $? = 0  ]; then
  flag=1;
 fi;
 if [ $flag = 1 ]; then
  echo $line  >> $LOG 2>&1
 fi;
done
if [ -f $LOG ]; then 
 cat $LOG |grep -v \#| sed '/^$/d'|sort |uniq >$PORTLOG 2>&1
fi
printf "\n"

if [ -f $PORTLOG ]; then 
cat $PORTLOG |awk '{print $1}' |while read group
do
 printf "Running pairdisplay -g $group ..." 
 echo "# $horcmdir/usr/bin/pairdisplay -g $group" >> $tmpdir/horcm/pairdisplay_output.txt 2>&1
 $horcmdir/usr/bin/pairdisplay -g $group >> $tmpdir/horcm/pairdisplay_output.txt 2>&1
 printf "\n"
done
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/pairdisplay_output.txt'>pairdisplay -g</a></td></tr> " >> $WEBLEFT 2>&1	
fi 
rm -f $LOG > /dev/null 2>&1
rm -f $PORTLOG > /dev/null 2>&1
#-----------------------------------------------------
flag=0
LOG=$OUTDIR/.horcmlog
PORTLOG=$OUTDIR/.horcmportlog
rm $LOG > /dev/null 2>&1
rm $PORTLOG > /dev/null 2>&1
 printf "Gathering Port numbers from horcm0.conf ..."
 cat $tmpdir/horcm/horcm0.conf |awk '{print $3}' |sed '/^$/d' |while read line;
  do
  printf "."
  echo $line |grep service  > /dev/null 2>&1
  if [ $? = 0 ]; then
   flag=0;break;
  fi;
  if [ $line = "port#" ]; then
   flag=1;
  fi;
  if [ $flag = 1 ]; then
    echo $line  >>$LOG 2>&1
  fi;
 done
if [ -f $LOG ]; then
 cat $LOG |sort |uniq > $PORTLOG  2>&1
fi
printf "\n"

if [ -f $PORTLOG ]; then
cat $PORTLOG |while read port
do
 printf "Running Raidscan on port $port ... (please wait)\n"
 echo "$horcmdir/usr/bin/raidscan -p $port -fe -CLI" > $tmpdir/horcm/$port.log 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/$port.log'>raidscan -p $port</a></td></tr> " >> $WEBLEFT 2>&1	
 $horcmdir/usr/bin/raidscan -p $port -fe -CLI  >> $tmpdir/horcm/$port.log 2>&1
 echo $LINE >> $tmpdir/horcm/$port.log 2>&1
done
fi
rm $LOG > /dev/null 2>&1
rm $PORTLOG > /dev/null 2>&1
fi
#-----------------------------------------------------
      
 echo "set |grep HORCM" > $tmpdir/horcm/horcm_env.txt 2>&1
 set |grep HORCM >> $tmpdir/horcm/horcm_env.txt 2>&1
 echo $LINE >> $tmpdir/horcm/horcm_env.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/horcm_env.txt'>horcm ENV</a></td></tr> " >> $WEBLEFT 2>&1	
 echo "If no HORMC_CONF environment variable is set, then the default /etc/horcm.conf is used." >> $tmpdir/horcm/horcm_env.txt 2>&1

############ HORCM README #########################################################
printf "\n
One Instance
To start up one instance of CCI on a UNIX® system:
1. Modify /etc/services to register the port name/number (service) of the configuration
definition file. Make the port name/number the same on all servers.
horcm xxxxx/udp xxxxx = the port name/number of horcm.conf
2. If you want HORCM to start automatically each time the system starts up, add
/etc/horcmstart.sh to the system automatic start-up file (e.g., /sbin/rc).
3. Execute the horcmstart.sh script manually to start the CCI instance:
# horcmstart.sh
4. Set the log directory (HORCC_LOG) in the command execution environment as needed.
5. If you want to perform Synchronous TrueCopy. 9500V operations, do not set the
HORCC_MRCF environment variable. If you want to perform ShadowImage. 9500V
/QuickShadow. 9500V operations, set the HORCC_MRCF environment variable for the
HORCM execution environment.
For B shell:
# HORCC_MRCF=1
# export HORCC_MRCF
C shell:
# setenv HORCC_MRCF 1
6. Execute the pairdisplay command to verify the configuration.
# pairdisplay -g xxxx xxxx = group-name

#--------------------------------------------------------------------------------------------

Two Instances
To start up two instances of CCI on a UNIX® system:
1. Make two copies of the sample configuration definition file.
# cp /etc/horcm.conf /etc/horcm0.conf
# cp /etc/horcm.conf /etc/horcm1.conf
2. Modify /etc/services to register the port name/number (service) of each configuration
definition file. The port name/number must be different for each CCI instance.
horcm0 xxxxx/udp xxxxx = the port name/number for horcm0.conf
horcm1 yyyyy/udp yyyyy = the port name/number for horcm1.conf
3. If you want HORCM to start automatically each time the system starts up, add
/etc/horcmstart.sh 0 1 to the system automatic start-up file (e.g., /sbin/rc).
4. Execute the horcmstart.sh script manually to start the CCI instances:
# horcmstart.sh 0 1
5. Set an instance number to the environment which executes a command:
For B shell:
# HORCMINST=X X = instance number = 0 or 1
# export HORCMINST
C shell:
# setenv HORCMINST X
6. Set the log directory (HORCC_LOG) in the command execution environment as needed.
7. If you want to perform Synchronous TrueCopy. 9500V operations, do not set the
HORCC_MRCF environment variable. If you want to perform ShadowImage. 9500V
/QuickShadow. 9500V operations, set the HORCC_MRCF environment variable for the
HORCM execution environment.
For B shell:
# HORCC_MRCF=1
# export HORCC_MRCF
C shell:
# setenv HORCC_MRCF 1
8. Execute the pairdisplay command to verify the configuration.
# pairdisplay -g xxxx xxxx = group-name
\n
" > $tmpdir/horcm/README.HORCM.TXT 2>&1

#####  END HORCM README #########################################################
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/'>HORCM directory</a></td></tr> " >> $WEBLEFT 2>&1	


else
	echo "No HORCM Found in $horcmdir" >> $tmpdir/not_found/no_horcm
fi
done # end HORCM or LOOP


########################################################################################

if [ -d /home/nasroot ]
then
 mkdir $tmpdir/horcm/nasroot > /dev/null 2>&1
 cp -R /home/nasroot/log* $tmpdir/horcm/nasroot/ > /dev/null 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/horcm/nasroot'>NAS CCI logs</a></td></tr> " >> $WEBLEFT 2>&1
fi 
}


################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# RAPIDXCHANGE (FAL)
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################


rapidx()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

echo "Checking for RapidXchange ..."

if [ -f $OUTDIR/fal_error ]
then
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>RapidXchange</B></td></tr> " >> $WEBLEFT 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/rapidx/'>fal_error logs</a></td></tr> " >> $WEBLEFT 2>&1

 echo "Found RapidXchange ..."
 mkdir $tmpdir/rapidx > /dev/null 2>&1
 cp $OUTDIR/fal_* $tmpdir/rapidx 2>&1
fi
}
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# HICOMMAND DEVICE MANAGER HDVM /  FUNCTIONS
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################


hdvm()
{

if [ -f /tmp/.setx ]; then
 set -x
fi



#######################################################################################3
###  This section tests for HiCommand Device Manager installation then obtains available data

echo "Checking to see if the HiCommand Device Manager Server is installed ..."

if [ -d /opt/HiCommand/Base ] || [ -d /opt/HiCommand/Base64 ]
then
   	echo "Found HiCommand Device Manager Server ..."
	echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HDVM Server</B></td></tr> " >> $WEBLEFT 2>&1
	mkdir $tmpdir/hdvm_server >/dev/null 2>&1
	hdir=$tmpdir/hdvm_server
	echo "" > $hdir/hdvm_info.txt
	echo "This files contains HiCommand specific info" >> $hdir/hdvm_info.txt 2>&1
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm_info.txt'>HDVM Server Info</a></td></tr> " >> $WEBLEFT 2>&1
        case $SYSOS in
        sun)
                /bin/pkginfo -l HDVM >> $hdir/hdvm_pkginfo.txt 2>&1
                /bin/pkginfo -l HBASE >> $hdir/hdvm_pkginfo..txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm_pkginfo.txt'>pkginfo -l HDVM</a></td></tr> " >> $WEBLEFT 2>&1
                /bin/pkginfo -l IBCSN60 >> $hdir/interbase_pkginfo.txt 2>&1
		if [ $? = 0 ]; then
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/interbase_pkginfo.txt'>pkginfo -l IBCSN60</a></td></tr> " >> $WEBLEFT 2>&1
		fi
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/ls.hdvm.txt'>ls /opt/HDVM</a></td></tr>" >> $WEBLEFT 2>&1
		ls -AlR /opt/HDVM >>$hdir/ls.hdvm.txt 2>&1

                uname -r |grep 5.10 > /dev/null 2>&1
                if [ $? = 0 ]; then
   	        echo "#prctl -P -n $i $$ |grep priv |awk '{print "user.root "$1 " = "$3}' " >> $hdir/hdvm.sol10.resource.control.values.txt 2>&1
		echo "#prctl -P -n $i 1|grep priv   |awk '{print "system    "$1 " = "$3}' " >> $hdir/hdvm.sol10.resource.control.values.txt 2>&1
		echo $LINE >> $hdir/hdvm.sol10.resource.control.values.txt 2>&1
                for i in process.max-msg-messages \
 		process.max-sem-nsems \
		process.max-sem-ops \
		project.max-msg-ids \
		project.max-sem-ids \
		project.max-shm-ids \
		project.max-shm-memory 
		do
		 prctl -P -n $i $$ |grep priv |awk '{print "user.root "$1 " = "$3}' >> $hdir/hdvm.sol10.resource.control.values.txt 2>&1
		 prctl -P -n $i 1|grep priv   |awk '{print "system    "$1 " = "$3}' >> $hdir/hdvm.sol10.resource.control.values.txt 2>&1
		 echo 
		done
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm.sol10.resource.control.values.txt'>HDvM Resource Control Values</a></td></tr>" >> $WEBLEFT 2>&1
              	fi

                ;;
        hpux )
                grep HDVM $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_swinfo.txt 2>&1
                grep HBASE $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm_swinfo.txt'>HDVM swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                grep IBCSN60 $tmpdir/software/swlist-l_product.txt >> $hdir/interbase_swinfo.txt 2>&1
		if [ $? = 0 ]; then
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/interbase_swinfo.txt'>Interbase swinfo</a></td></tr> " >> $WEBLEFT 2>&1
		fi
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/ls.hdvm.txt'>ls /opt/HDVM</a></td></tr> " >> $WEBLEFT 2>&1
		ls -AlR /opt/HDVM >>$hdir/ls.hdvm.txt 2>&1

                 ;;
        aix)
                grep HDVM $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_swinfo.txt 2>&1
                grep HBASE $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm_swinfo.txt'>HDVM swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                grep IBCNS60 $tmpdir/software/software_lslpp-L.txt >> $hdir/interbase_swinfo.txt 2>&1
        	if [ $? = 0 ]; then
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/interbase_swinfo.txt'>Interbase swinfo</a></td></tr> " >> $WEBLEFT 2>&1
		fi
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/ls.hdvm.txt'>ls /usr/HDVM</a></td></tr> " >> $WEBLEFT 2>&1
		ls -AlR /usr/HDVM >>$hdir/ls.hdvm.txt 2>&1
                ;;
        linux)
                grep  HDVM $tmpdir/os_files/rpm.qisva.txt >>$hdir/hdvm-rpminfo.txt 2>&1
                grep  HBASE $tmpdir/os_files/rpm.qisva.txt >>$hdir/hdvm-rpminfo.txt 2>&1
                grep  IBCNS60 $tmpdir/os_files/rpm.qisva.txt >>$hdir/hdvm-rpminfo.txt  2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm-rpminfo.txt'>HDVM rpm info</a></td></tr> " >> $WEBLEFT 2>&1	
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/ls.hdvm.txt'>ls /opt/HDVM</a></td></tr> " >> $WEBLEFT 2>&1
		ls -AlR /opt/HDVM >>$hdir/ls.hdvm.txt 2>&1
		;;
        esac


	echo $LINE >> $hdir/hdvm_info.txt
	echo "The following shows the existence of the hicmd user" >> $hdir/hdvm_info.txt
	echo $LINE >> $hdir/hdvm_info.txt
	grep hicmd /etc/passwd >> $hdir/hdvm_info.txt 2>&1
	/usr/bin/finger hicmd >> $hdir/hdvm_info.txt 2>&1
	echo $LINE >> $hdir/hdvm_info.txt

        if [ -d /opt/HiCommand/Base64 ]
        then
       		### Collect log files and database file for HiCommand
        	printf "Running HiCommand hcmdsgetlogs ..."
        	/opt/HiCommand/Base64/bin/hcmds64getlogs -dir $hdir/hcmdsgetlogs  >> $hdir/hcmdsgetlogs_output.txt 2>&1 &
		waitfor $!
       		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hcmdsgetlogs'>hcmdsgetlogs</a></td></tr> " >> $WEBLEFT 2>&1	
 		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hcmdsgetlogs_output.txt'>hcmdsgetlogs command output</a></td></tr> " >> $WEBLEFT 2>&1	
		printf "\n"

	else
 		### Collect log files and database file for HiCommand
        	printf "Running HiCommand hcmdsgetlogs ..."
	       	/opt/HiCommand/Base/bin/hcmdsgetlogs -dir $hdir/hcmdsgetlogs  >> $hdir/hcmdsgetlogs_output.txt 2>&1 &
		waitfor $!
       		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hcmdsgetlogs'>hcmdsgetlogs</a></td></tr> " >> $WEBLEFT 2>&1	
 		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hcmdsgetlogs_output.txt'>hcmdsgetlogs command output</a></td></tr> " >> $WEBLEFT 2>&1	
		printf "\n"
         fi

        if [ -d /opt/interbase ]; then
        echo "Found Interbase logs  ..."
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/interbase'>Interbase</a></td></tr> " >> $WEBLEFT 2>&1	
         mkdir $hdir/interbase > /dev/null 2>&1
 	 cp /opt/interbase/*.log $hdir/interbase
	 cp /opt/interbase/*.msg $hdir/interbase
	 cp /opt/interbase/license.txt $hdir/interbase > /dev/null 2>&1
	 cp /opt/HiCommand/HiCommandServer/database/interbase/* $hdir/interbase > /dev/null 2>&1
	 cp /opt/interbase/VERSION.TXT $hdir/interbase > /dev/null 2>&1
        fi

       printf "Checking HiCommand Server Ports ..."

      printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HDVM\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
Port Process Application \n
21 ftp HDvM Server (9900 subsystems) \n
80 http HDvM Server (T3 Subsystems) \n
161 snmp HDvM Server \n
162 snmp HDvM Server (SNMP Traps) \n
1099 rmi HDvM Server (9900V subsystems) \n
2000 damp DAMP API \n
2001 hicommand HDvM Server \n
2443 hicommand HDvM Server (SSL) \n
3050 ibserver InterBase \n
3060 interserver InterClient \n
23012 HDvM Host Agent \n
23013 HDvM Host Agent default daemon port \n
23015 httpsd HiCommand Common Component \n
23016 httpsd HiCommand Common Component (SSL) \n
23017 hcmdssvmng HiCommand Single Signon \n
23018 hcmdssvmng HiCommand Single Signon \n
23032 pdrdmd HiRDB (4.0+) \n
" > $hdir/README_hdvm_ports.txt 2>&1

        netstat -a  >$OUTDIR/.netstat 2>&1
 for i in "162" "1099" "2000" "2001" "2443" "3050" "3060" "23015" "23016" "23017" "23018" "23019" "23032"
   do
        x=`grep $i $OUTDIR/.netstat  >> /dev/null 2>&1`
        if [ $? = 0 ]; then
         echo $LINE >> $hdir/hdvm_server_ports_in_use.txt 2>&1
         echo "found for $i" >> $hdir/hdvm_server_ports_in_use.txt 2>&1
         echo $x >> $hdir/hdvm_server_ports_in_use.txt 2>&1
  	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_server/hdvm_server_ports_in_use.txt'>HDVM Ports</a></td></tr> " >> $WEBLEFT 2>&1	
        else
         echo $LINE >> $hdir/hdvm_server_ports_in_use.txt 2>&1
         echo "did not find $i" >> $hdir/hdvm_server_ports_not-found.txt 2>&1
        fi
printf "."
   done
rm -f $OUTDIR/.netstat > /dev/null 2>&1
printf "\n"
else
 touch $tmpdir/not_found/no_hdvm_server
fi

#-------------------------------------------------------------------------------
# HDVM AGENT
#-------------------------------------------------------------------------------
if [ -d /opt/HDVM ]; then 
        echo "Found HDvM Agent..."
	echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HDVM Agent</B></td></tr> " >> $WEBLEFT 2>&1
        mkdir $tmpdir/hdvm_client > /dev/null 2>&1
	hdir=$tmpdir/hdvm_client
printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HDVM\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
Port Process Application \n
21 ftp HDvM Server (9900 subsystems) \n
80 http HDvM Server (T3 Subsystems) \n
161 snmp HDvM Server \n
162 snmp HDvM Server (SNMP Traps) \n
1099 rmi HDvM Server (9900V subsystems) \n
2000 damp DAMP API \n
2001 hicommand HDvM Server \n
2443 hicommand HDvM Server (SSL) \n
3050 ibserver InterBase \n
3060 interserver InterClient \n
23012 HDvM Host Agent (dynamic)\n
23013 HDvM Host Agent default daemon port \n
23015 httpsd HiCommand Common Component \n
23016 httpsd HiCommand Common Component (SSL) \n
23017 hcmdssvmng HiCommand Single Signon \n
23018 hcmdssvmng HiCommand Single Signon \n
23032 pdrdmd HiRDB (4.0+) \n
" > $hdir/README_hdvm_ports.txt 2>&1

	echo "Found HiCommand Device Manager Agent Logs ..."

        case $SYSOS in
        sun)
                /bin/pkginfo -l HDVM >> $hdir/hdvm_agent_pkginfo.txt 2>&1
                /bin/pkginfo -l HDVMAgent >> $hdir/hdvm_agent_pkginfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_pkginfo.txt'>HDVM Agent pkginfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        hpux )
                grep -i HDVM $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_swinfo.txt'>HDVM Agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                 ;;
        aix)
                grep -i HDVM $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_lslpp.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_lslpp.txt'>HDVM Agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        linux)
                grep  -i HDVM $tmpdir/software/rpm.qia.txt >> $hdir/hdvm_agent_rpminfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_rpminfo.txt'>HDVM Agent rpminfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        esac

	if [ -f /opt/HDVM/HBaseAgent/bin/hdvm_info ]; then
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_version.txt'>HDVM Agent version</a></td></tr> " >> $WEBLEFT 2>&1
        /opt/HDVM/HBaseAgent/bin/amc_modinfo >> $hdir/hdvm_version.txt 2>&1 
        fi

        printf "Checking HiCommand Agent Ports ..."
        netstat -a > $OUTDIR/.netstat 2>&1 
       	for i in 23011 23013 
         do
           x=`grep $i  $OUTDIR/.netstat  >> /dev/null 2>&1`
           if [ $? = 0 ]; then
           echo "# $x" >> $hdir/hdvm_agent_ports.txt 2>&1
           echo "found $i" >> $hdir/hdvm_agent_ports.txt 2>&1
           echo $x >> $hdir/hdvm_agent_ports.txt 2>&1

           else
             echo "did not find $i" >> $hdir/hdvm_agent_ports.txt 2>&1
           fi
         done 
	   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_ports.txt'>HDVM Agent Ports</a></td></tr> " >> $WEBLEFT 2>&1	
       rm -f $OUTDIR/.netstat > /dev/null 2>&1
       printf "\n"    

fi


#-------------------------------------------------------------------------------
# HISCAN AGENT
#-------------------------------------------------------------------------------

if [ -d /opt/HDSHiScan ]; then
	echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HISCAN Agent</B></td></tr> " >> $WEBLEFT 2>&1

	hdir=$tmpdir/hiscan
        mkdir $hdir > /dev/null 2>&1
        mkdir $hdir/logs > /dev/null 2>&1

printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HDvM as of v4.0\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
Port Process Application \n
21 ftp HDvM Server (9900 subsystems) \n
80 http HDvM Server (T3 Subsystems) \n
161 snmp HDvM Server \n
162 snmp HDvM Server (SNMP Traps) \n
1099 rmi HDvM Server (9900V subsystems) \n
2000 damp DAMP API \n
2001 hicommand HDvM Server \n
2443 hicommand HDvM Server (SSL) \n
3050 ibserver InterBase \n
3060 interserver InterClient \n
23012 hiscan HDvM Host Agent(dynamic) \n
23015 httpsd HiCommand Common Component \n
23016 httpsd HiCommand Common Component (SSL) \n
23017 hcmdssvmng HiCommand Single Signon \n
23018 hcmdssvmng HiCommand Single Signon \n
23032 pdrdmd HiRDB (4.0+) \n
And ports from 45001 to 49000
Solaris may use port number 48129 which is used by HIRDB may be used by NIS Map and does not show up in the /etc/services file
The NIS entry is in  /etc/nsswitch.conf \n
The actual port error is documented in the /var/adm/messages file at the time HiRDB tries to access the port

" > $hdir/README_hdvm_ports.txt 2>&1

	echo "Found OLD HiCommand Device Manager Agent  "
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan'>HiScan Error Logs</a></td></tr> " >> $WEBLEFT 2>&1
        cp /opt/HDSHiScan/bin/logs/*msg*  $hdir/logs > /dev/null 2>&1
        cp /opt/HDSHiScan/bin/logs/*err* $hdir/logs > /dev/null 2>&1

	case $SYSOS in
        sun)
                /bin/pkginfo -l HDVM >> $hdir/hdvm_agent_pkginfo.txt 2>&1
                /bin/pkginfo -l HDVMAgent >> $hdir/hdvm_agent_pkginfo.txt 2>&1
                /bin/pkginfo -l HDSHiScan >> $hdir/hdvm_agent_pkginfo.txt 2>&1
	        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hdvm_agent_pkginfo.txt'>HiSCAN agent pkginfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        hpux )
                grep -i HDVM $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
                grep -i HDVMAgent $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
                grep -i hiscan $tmpdir/software/swlist-l_product.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hdvm_agent_swinfo.txt'>HiSCAN agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                 ;;
        aix)
                grep -i HDVM $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_lslpp.txt 2>&1
                grep -i HDVMAgent $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_lslpp.txt 2>&1
                grep -i hiscan $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_lslpp.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hdvm_agent_lslpp.txt'>HiSCAN agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        linux)
                grep  -i HDVM $tmpdir/os_files/rpm.qisva.txt >>$hdir/hdvm_agent_rpminfo.txt 2>&1
                grep  -i hiscan $tmpdir/os_files/rpm.qisva.txt >>$hdir/hdvm_agent_rpminfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hdvm_agent_rpminfo.txt'>HiSCAN agent rpminfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        esac

	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hdvm_agent_swinfo.txt'>HiSCAN version</a></td></tr> " >> $WEBLEFT 2>&1
        /opt/HDSHiScan/bin/hdvm_info >> $hdir/hiscan_version.txt 2>&1 
         
        echo "Checking HiCommand Agent Ports ..."
        netstat -a >$OUTDIR/.netstat    >> /dev/null 2>&1
       	for i in 23011 23012 23013 
         do
           $x=`grep $i $OUTDIR/.netstat   >> /dev/null 2>&1`
           if [ $? = 0 ]; then
           echo "found $i" >> $hdir/hiscan_agent_ports_in_use.txt 2>&1
           echo $x >> $hdir/hiscan_agent_ports_in_use.txt 2>&1
	   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hiscan/hiscan_agent_ports_in_use.txt'>ports in use</a></td></tr> " >> $WEBLEFT 2>&1
           else
             echo "did not find $i" >> $hdir/hiscan_agent_ports_not-found.txt 2>&1
           fi
         printf "."
         done     
rm -f $OUTDIR/.netstat
printf "\n"

else
	echo "No HiScan Agent Found" > $tmpdir/not_found/no_hiscan
        rmdir $tmpdir/hiscan > /dev/null 2>&1
fi

#-------------------------------------------------------------------------------
# HRPM CLIENT
#-------------------------------------------------------------------------------

if [ -d /opt/HBaseAgent/mod/hrpm ] || [ -d /usr/HBaseAgent/mod/hrpm ]; then
	hdir=$tmpdir/hrpm
        mkdir $hdir > /dev/null 2>&1
	if [ -d /opt/HBaseAgent/mod/hrpm ]; then
	echo "Found HiCommand Replicator Monitor Agent ..."
        cp /opt/HBaseAgent/mod/hrpm/* $hdir/ >> /dev/null 2>&1
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/'>HRpM Agent logs</a></td></tr> " >> $WEBLEFT 2>&1
	fi

	if [ -d /usr/HBaseAgent/mod/hrpm ]; then
	echo "Found HiCommand Replicator Monitor Agent ..."
        cp /usr/HBaseAgent/mod/hrpm/* $hdir/ >> /dev/null 2>&1
	echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/'>HRpM Agent logs</a></td></tr> " >> $WEBLEFT 2>&1
	fi

	case $SYSOS in
        sun)
                /bin/pkginfo -li HRPM >> $hdir/hrpm_agent_pkginfo.txt 2>&1
	        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/hrpm_agent_pkginfo'>HRpM Agent pkginfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        hpux )
                grep -i HRPM $tmpdir/software/swlist-l_product.txt >> $hdir/hrpm_agent_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/hrpm_agent_swinfo'>HRpM Agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                 ;;
        aix)
                grep -i HRPM $tmpdir/software/software_lslpp-L.txt >> $hdir/hrpm_agent_lslpp.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/hrpm_agent_lslpp.txt'>HRpM Agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        linux)
                grep  -i HRPM $tmpdir/os_files/rpm.qisva.txt >>$hdir/hrpm_agent_rpminfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hrpm/hrpm_agent_rpminfo'>HRpM Agent rpminfo</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        esac


else
	echo "No HRPM Agent Found" > $tmpdir/not_found/no_hrpm
        rmdir $tmpdir/hrpm > /dev/null 2>&1
fi

#------------------------------------------------------------------------

if [ -f /opt/HDVM/agent/bin/TIC.sh ];
then
   hdir=$tmpdir/hdvm_client
   mkdir $hdir > /dev/null 2>&1
 printf "Running HDVM Agent TIC.sh script ...(This may take a while)"
(
 /opt/HDVM/agent/bin/TIC.sh -outdir $hdir/TIC -f  
) >> $hdir/tic.output.txt 2>&1 &
waitfor $!
printf "\n"
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/TIC'>TIC.sh output</a></td></tr> " >> $WEBLEFT 2>&1
fi

if [ -f /opt/HDVM/HBaseAgent/bin/TIC.sh ];
then
   hdir=$tmpdir/hdvm_client
   mkdir $hdir > /dev/null 2>&1
 printf "Running HDVM Agent TIC.sh script ...(This may take a while)"
(
 /opt/HDVM/HBaseAgent/bin/TIC.sh -outdir $hdir/TIC -f  
) >> $hdir/tic.output.txt 2>&1 &
waitfor $!
printf "\n"
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/TIC'>TIC.sh output</a></td></tr> " >> $WEBLEFT 2>&1
fi

  if [ -d /opt/HDVM/bin/logs ] && [ ! /opt/HDVM/agent/bin/TIC.sh ]; then
    mkdir $hdir/logs > /dev/null 2>&1
    echo "Did not find TIC.sh, gathering HDVM agent logs manually instead..."
    cp /opt/HDVM/bin/logs/*err* $hdir/logs > /dev/null 2>&1
    cp /opt/HDVM/bin/logs/*msg* $hdir/logs > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/'>HDVM Error</a></td></tr> " >> $WEBLEFT 2>&1
  fi

#--------------------------------------------------------------------------------------

if [ $SYSOS = aix ] && [ -f /usr/HDVM/agent/bin/TIC.sh  ] ;
then

  hdir=$tmpdir/hdvm_client
  mkdir $hdir > /dev/null 2>&1
printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HDvM as of v4.0\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
Port Process Application \n
21 ftp HDvM Server (9900 subsystems) \n
80 http HDvM Server (T3 Subsystems) \n
161 snmp HDvM Server \n
162 snmp HDvM Server (SNMP Traps) \n
1099 rmi HDvM Server (9900V subsystems) \n
2000 damp DAMP API \n
2001 hicommand HDvM Server \n
2443 hicommand HDvM Server (SSL) \n
3050 ibserver InterBase \n
3060 interserver InterClient \n
23012 hiscan HDvM Host Agent \n
23015 httpsd HiCommand Common Component \n
23016 httpsd HiCommand Common Component (SSL) \n
23017 hcmdssvmng HiCommand Single Signon \n
23018 hcmdssvmng HiCommand Single Signon \n
23032 pdrdmd HiRDB (4.0+) \n
And ports from 45001 to 49000
Solaris may use port number 48129 which is used by HIRDB may be used by NIS Map and does not show up in the /etc/services file
The NIS entry is in  /etc/nsswitch.conf 
The actual port error is documented in the /var/adm/messages file at the time HiRDB tries to access the port
" > $hdir/README_hdvm_ports.txt 2>&1

        printf "Checking HiCommand Agent Ports ..."
           netstat -a >$OUTDIR/.netstat   >> /dev/null 2>&1
       	for i in 23011 23012 23013 
         do
           x=`grep $i $OUTDIR/.netstat   >> /dev/null 2>&1`
           if [ $? = 0 ]; then
           echo "found $i" >> $hdir/hdvm_agent_ports_in_use.txt 2>&1
          echo $x >> $hdir/hdvm_agent_ports_in_use.txt 2>&1
	  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_ports_in_use.txt'>HDVM ports</a></td></tr> " >> $WEBLEFT 2>&1
           else
             echo "did not find $i" >> $hdir/hdvm_agent_ports_not-found.txt 2>&1
           fi
	printf "."
         done     
	printf "\n"

 grep -i HDVM $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_swinfo.txt'>agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
 echo "Running HDVM Agent /usr/HDVM/agent/bin/TIC.sh script ..."
(
 /usr/HDVM/agent/bin/TIC.sh -outdir $hdir/TIC -f  
) >> $hdir/tic.output.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/TIC'>TIC.sh output</a></td></tr> " >> $WEBLEFT 2>&1
fi

#---------------------------------------------------------------------

if [ $SYSOS = aix ] && [ -f /usr/HDVM/HBaseAgent/bin/TIC.sh  ] ;
then
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/'>HDVM Client Logs</a></td></tr> " >> $WEBLEFT 2>&1
  hdir=$tmpdir/hdvm_client
  mkdir $hdir > /dev/null 2>&1
printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HDvM as of v4.0\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
Port Process Application \n
21 ftp HDvM Server (9900 subsystems) \n
80 http HDvM Server (T3 Subsystems) \n
161 snmp HDvM Server \n
162 snmp HDvM Server (SNMP Traps) \n
1099 rmi HDvM Server (9900V subsystems) \n
2000 damp DAMP API \n
2001 hicommand HDvM Server \n
2443 hicommand HDvM Server (SSL) \n
3050 ibserver InterBase \n
3060 interserver InterClient \n
23012 hiscan HDvM Host Agent \n
23015 httpsd HiCommand Common Component \n
23016 httpsd HiCommand Common Component (SSL) \n
23017 hcmdssvmng HiCommand Single Signon \n
23018 hcmdssvmng HiCommand Single Signon \n
23032 pdrdmd HiRDB (4.0+) \n
And ports from 45001 to 49000
Solaris may use port number 48129 which is used by HIRDB may be used by NIS Map and does not show up in the /etc/services file
The NIS entry is in  /etc/nsswitch.conf 
The actual port error is documented in the /var/adm/messages file at the time HiRDB tries to access the port
" > $hdir/README_hdvm_ports.txt 2>&1

        echo "Checking HiCommand Agent Ports ..."
           netstat -a >$OUTDIR/.netstat   >> /dev/null 2>&1
       	for i in 23011 23012 23013 
         do
           x=`grep $i $OUTDIR/.netstat   >> /dev/null 2>&1`
           if [ $? = 0 ]; then
           echo "found $i" >> $hdir/hdvm_agent_ports_in_use.txt 2>&1
          echo $x >> $hdir/hdvm_agent_ports_in_use.txt 2>&1
     	  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_ports_in_use.txt'>HDVM ports</a></td></tr> " >> $WEBLEFT 2>&1
           else
             echo "did not find $i" >> $hdir/hdvm_agent_ports_not-found.txt 2>&1
           fi
printf "."
         done     
printf "\n"

 grep -i HDVM $tmpdir/software/software_lslpp-L.txt >> $hdir/hdvm_agent_swinfo.txt 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/hdvm_agent_swinfo.txt'>agent swinfo</a></td></tr> " >> $WEBLEFT 2>&1
 echo "Running HDVM Agent /usr/HDVM/HBaseAgent/bin/TIC.sh script ..."
(
 /usr/HDVM/HBaseAgent/bin/TIC.sh -outdir $hdir/TIC -f  
) >> $hdir/tic.output.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hdvm_client/TIC'>TIC.sh output</a></td></tr> " >> $WEBLEFT 2>&1
fi


if [ ! -d $tmpdir/hdvm_client ]; then
   touch $tmpdir/not_found/no_hdvm_client
fi

}

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# HICOMMAND TUNING MANAGER  HTNM /  FUNCTIONS
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################


htnm()
{

if [ -f /tmp/.setx ]; then
 set -x
fi

#######################################################################################3
###  This section tests for HiCommand Device Manager installation then obtains available data

echo "Checking to see if the HiCommand Tuning Manager Server is installed ..."

if [ -d /opt/HiCommand/TuningManager ]
then
   	echo "Found HiCommand Tuning Manager Server ..."
	echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HTnM Server</B></td></tr> " >> $WEBLEFT 2>&1
	mkdir $tmpdir/htnm_server
	hdir=$tmpdir/htnm_server
	echo "" > $hdir/htnm_info.txt
	echo "This files contains HiCommand specific info" >> $hdir/htnm_info.txt 2>&1

        case $SYSOS in
        sun)
                /bin/pkginfo -l HTNM >> $hdir/htnm_pkginfo.txt 2>&1
                /bin/pkginfo -l HBASE >> $hdir/htnm_pkginfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htnm_pkginfo.txt'>pkginfo htnm</a></td></tr> " >> $WEBLEFT 2>&1
                /bin/pkginfo -l IBCSN60 >> $hdir/interbase_pkginfo.txt 2>&1
		if [ $? = 0 ]; then
		 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/interbase_pkginfo.txt'>pkginfo interbase</a></td></tr> " >> $WEBLEFT 2>&1
		fi
                ls -AlR /opt/HiCommand/TuningManager >>$hdir/ls.htnm.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/ls.htnm.txt'>ls HTnM</a></td></tr> " >> $WEBLEFT 2>&1
		;;
        hpux )
                grep HTNM $tmpdir/software/swlist-l_product.txt >> $hdir/htnm_swinfo.txt 2>&1
                grep HBASE $tmpdir/software/swlist-l_product.txt >> $hdir/htnm_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htnm_swinfo.txt'>htnm swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                grep IBCSN60 $tmpdir/software/swlist-l_product.txt >> $hdir/interbase_swinfo.txt 2>&1
		if [ $? = 0 ]; then
		 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/interbase_swinfo.txt'>interbase swinfo</a></td></tr> " >> $WEBLEFT 2>&1
		fi
                ls -AlR /opt/HiCommand/TuningManager >>$hdir/ls.htnm.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/ls.htnm.txt'>ls HTnM</a></td></tr> " >> $WEBLEFT 2>&1

                 ;;
        aix)
                grep HTNM $tmpdir/software/software_lslpp-L.txt >> $hdir/htnm_swinfo.txt 2>&1
                grep HBASE $tmpdir/software/software_lslpp-L.txt >> $hdir/htnm_swinfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htnm_swinfo.txt'>htnm swinfo</a></td></tr> " >> $WEBLEFT 2>&1
                grep IBCNS60 $tmpdir/software/software_lslpp-L.txt >> $hdir/interbase_swinfo.txt 2>&1
		if [ $? = 0 ]; then
		 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/interbase_swinfo.txt'>interbase swinfo</a></td></tr> " >> $WEBLEFT 2>&1
		fi
                ls -AlR /usr/HiCommand/TuningManager >>$hdir/ls.htnm.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/ls.htnm.txt'>ls HTnM</a></td></tr> " >> $WEBLEFT 2>&1

                ;;
        linux)
                grep  HTNM $tmpdir/os_files/rpm.qisva.txt >>$hdir/htnm_rpminfo.txt 2>&1
                grep  HBASE $tmpdir/os_files/rpm.qisva.txt >>$hdir/htnm_rpminfo.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htnm_rpminfo.txt'>htnm rpminfo</a></td></tr> " >> $WEBLEFT 2>&1
                grep  IBCNS60 $tmpdir/os_files/rpm.qisva.txt >>$hdir/htnm_rpminfo.txt  2>&1
                ls -AlR /opt/HiCommand/TuningManager >> $hdir/ls.htnm.txt 2>&1
		echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/ls.htnm.txt'>ls HTnM</a></td></tr> " >> $WEBLEFT 2>&1
                ;;
        esac


	### Collect log files and database file for HiCommand
if [ -f htm-install-cd1.log ] || [ -f htm-install-cd2.log ]; then
 printf "Gathering HTnM Install logs ..." 
 cat $OUTDIR/htm-install-cd1.log >> $hdir/htnm_install_logs.txt  2>&1
 printf "."
 cat $OUTDIR/htm-install-cd2.log >> $hdir/htnm_install_logs.txt  2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htm_install_logs.txt'>Install logs</a></td></tr> " >> $WEBLEFT 2>&1
fi
printf "\n"

      printf "
--------------------------------------------------------------------- \n
The following is a list of all ports for HTnM Server\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
23015 Access port of HiCommand Suite Common Web Service (non-SSL) \n
23016 Access port of HiCommand Suite Common Web Service (SSL) \n
23017 AJP port of HiCommand Suite Single Sign On Service \n
23018 Stop request reception port of HiCommand Suite Single Sign On Service\ n
23019 AJP port of HiCommand Suite Tuning Manager \n
23020 Stop request reception port of HiCommand Suite Tuning Manager. \n
23021 AJP port of HiCommand Tuning Manager SOAP-API service  \n
23022 Stop request reception port of HiCommand Tuning Manager SOAP-API service \n
23023 AJP port of HiCommand Performance Reporter \n
23024 Stop request reception port of HiCommand Performance Reporter \n
23025 to 23031 Reserved ports \n
23032 Access port for HiRDB \n
\n\n
The following table shows the port numbers that Collection Manager and Agent use. Note \n
that except for port numbers 22285 and 22286, all remaining port numbers are assigned if \n
you do not specify port numbers when you execute the jpcnsconfig port command. If you do \n
not execute the jpcnsconfig port command, port numbers that are not being used by the \n
system are assigned automatically each time these services are restarted. \n
Table A.6 Port Numbers Used by Collection Manager and Agent \n
 
Service Name\t    Parameter\t   Port Number \n
----------------------------------------- \n
Name Server\t     jp1pcnsvr\t   22285 \n
Master Manager\t  jp1pcmm\t     20271 \n
Master Store\t    jp1pcsto\t    20272 \n
Correlator\t      jp1pcep\t     20273 \n
Trap Generator\t  jp1pctrap\t   20274 \n
View Server\t     jp1pcvsvr\t   22276 \n
View Server\t     jp1pcvsvr\t   22286 \n
(between Performance Reporter and the View Server services)
Action Handler\t  jp1pcah\t     20275 \n
Agent Store\t     jp1pcstot\t   20279 \n
Agent Collector\t jp1pcagtt\t   20280 \n
" > $hdir/README_htnm_ports.txt 2>&1

 printf "Checking HiCommand Tuning Manager Ports ..."
netstat -a  >> $OUTDIR/.netstat 2>&1
 for i in "23015" "23016" "23017" "23018" "23019" "23020" "23021" "23022" "23023" "23024" "23025" "23032" "22285" "22286" "20279" "20280" "162"
   do
        grep $i $OUTDIR/.netstat  > /dev/null 2>&1
        if [ $? = 0 ]; then
         echo $LINE >> $hdir/htnm_ports_in_use.txt 2>&1
         echo "found $i in netstat" >> $hdir/htnm_ports_in_use.txt 2>&1
         echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_server/htnm_ports_in_use.txt'>htnm ports</a></td></tr> " >> $WEBLEFT 2>&1
        else
         echo $LINE >> $hdir/htnm_ports_in_use.txt 2>&1
         echo "did not find $i" >> $hdir/htnm_ports_not-found.txt 2>&1
        fi
   printf "."
   done
   rm -f $OUTDIR/.netstat > /dev/null 2>&1

printf "\n"
else
 touch $tmpdir/not_found/no_htnm_server
fi


#------------------------------------------------------------------------
# Checking for HTnM Client in /opt/jp1pc
#------------------------------------------------------------------------

if [ -d /opt/jp1pc/tools ]; then
 echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HTnM Client</B></td></tr> " >> $WEBLEFT 2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_client/'>HTnM Client Logs</a></td></tr> " >> $WEBLEFT 2>&1
 echo "Found HTnM Agent ..."
 if [ ! -d $tmpdir/htnm_client ]; then
  mkdir $tmpdir/htnm_client > /dev/null 2>&1 
  mkdir $tmpdir/htnm_client/jpcras > /dev/null 2>&1
  printf "Running HTnM Agent jpcras script ..."
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/htnm_client/jpcras_script_output.txt'>jpcras script output</a></td></tr> " >> $WEBLEFT 2>&1
  cd /opt/jp1pc/tools; (./jpcras  $tmpdir/htnm_client/jpcras all all ) > $tmpdir/htnm_client/jpcras_script_output.txt  2>&1 &
  waitfor $!
  printf "\n"
 fi
fi


}
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
# HSSM FUNCTIONS
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
####################################################################################
hssm()
{

if [ -f /tmp/.setx ]; then
 set -x
fi

##############################################################
#   HSSM CLIENT
##############################################################

echo "Looking for HSSM Client Logs ..." 

if [ -d /opt/APPQcime ]; then
echo "Found HSSM Client ..."
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HSSM CIM</B></td></tr> " >> $WEBLEFT 2>&1
mkdir $tmpdir/hssm_agent

  echo "Determining HSSM CIM Agent Version ..."
  /opt/APPQcime/tools/start -version >> $tmpdir/hssm_agent/cim_version.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/cim_version.txt'>CIM Agent Version</a></td></tr> " >> $WEBLEFT 2>&1

if [ -f /opt/APPQcime/tools/status ]; then
  echo "Determining HSSM CIM Agent Status ..."
  echo "#/opt/APPQcime/tools/status"  >$tmpdir/hssm_agent/status.txt 2>&1
  /opt/APPQcime/tools/status  >> $tmpdir/hssm_agent/status.txt 2>&1
  /opt/APPQcime/tools/status |grep not > /dev/null 2>&1
  if [ $? = 0 ]; then
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/status.txt'>HSSM Agent <font color='#FF0000'>is NOT Running</a></td></tr> " >> $WEBLEFT 2>&1
  else
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/status.txt'>HSSM Agent <font color='#008000'>is Running</font></a></td></tr> " >> $WEBLEFT 2>&1
  fi
else
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/status.txt'>HSSM Agent status</a></td></tr> " >> $WEBLEFT 2>&1
   echo "#ps -ef |grep cxws|grep -v grep" >> $tmpdir/hssm_agent/status.txt 2>&1
   ps -ef |grep cxws|grep -v grep >> $tmpdir/hssm_agent/status.txt 2>&1
fi


  if [ $? != 0 ]; then
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/status.txt'>HSSM Agent <font color='#FF0000'>is NOT Running</a></td></tr> " >> $WEBLEFT 2>&1
  else
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a href='../txt/hssm_agent/status.txt'>HSSM Agent <font color='#008000'>is Running</font></a></td></tr> " >> $WEBLEFT 2>&1
  fi


#----------------------------------------------------------------
echo  "
--------------------------------------------------------------------- \n
The following is a list of all ports for HSSM Agent\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
The oracle QoS agent uses port 1521 by default\n
The CIM Agent uses port 17000 by default for Agent v4\n
The CIM Agent uses port 4673 by default for Agent v4.1+  \n
Default http connection is port 80\n
Default SSL connection is port 443\n
Windows Hosts use DCOM which by default listens on port 135\n
HiCommand listens on default port 2001\n
" > $tmpdir/hssm_agent/README_hssm_agent_ports.txt 2>&1
#----------------------------------------------------------------
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/hssm_info.txt'>HSSM Agent Info</a></td></tr> " >> $WEBLEFT 2>&1


   echo "Checking for CIM agent version  ..."
   /opt/APPQcime/tools/start -version >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
   if [ -f /etc/init.d/appqcime ]; then 
    cp /etc/init.d/appqcime $tmpdir/hssm_agent/appqcime.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/appqcime.txt'>/etc/init.d/appqcime</a></td></tr> " >> $WEBLEFT 2>&1
   fi
    echo "HOSTNAME = $HOSTNAME" >> $tmpdir/hssm_agent/cim_environment.txt 2>&1
    echo "JAVA_HOME = $JAVA_HOME" >> $tmpdir/hssm_agent/cim_environment.txt 2>&1
    echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH" >> $tmpdir/hssm_agent/cim_environment.txt 2>&1
    echo "PATH = $PATH" >> $tmpdir/hssm_agent/cim_environment.txt 2>&1
    echo "SHELL = $SHELL" >> $tmpdir/hssm_agent/cim_environment.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/cim_environment.txt'>CIM Environment Variables</a></td></tr> " >> $WEBLEFT 2>&1

   cp /opt/APPQcime/tools/* $tmpdir/hssm_agent/ > /dev/null 2>&1
   cp /opt/APPQcime/conf/* $tmpdir/hssm_agent/ > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/cxws.out'>cxws.out</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/cxws.log'>cxws.log</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/stop'>stop</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/stop'>start</a></td></tr> " >> $WEBLEFT 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/cim.extension.parameter'>cim.extension.parameter</a></td></tr> " >> $WEBLEFT 2>&1

   if [ -d /opt/APPQcime/xData ]; then
   echo "Copying HSSM Cim Agent FileSRM logs ..."
   mkdir $tmpdir/hssm_agent/xData
   cp -R /opt/APPQcime/xData/*.* $tmpdir/hssm_agent/xData > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/xData'>xData Directory</a></td></tr> " >> $WEBLEFT 2>&1
   fi
   
   cp /opt/APPQcime/tools/* $tmpdir/hssm_agent/tools > /dev/null 2>&1
   if [ -f /opt/APPQcime/tools/cxlog4j.properties ]; then
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/cxlog4j.properties.txt'>cxlog4j.properties </a></td></tr> " >> $WEBLEFT 2>&1
   cp $tmpdir/hssm_agent/tools/cxlog4j.properties $tmpdir/hssm_agent/tools/cxlog4j.properties.txt > /dev/null 2>&1
   fi
   if [ -f /etc/init.d/appqcime ]; then 
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/appqcime.txt'>/etc/init.d/appqcime</a></td></tr> " >> $WEBLEFT 2>&1
    cp /etc/init.d/appqcime $tmpdir/hssm_agent/appqcime.txt 2>&1
   fi

   echo $LINE >> $tmpdir/hssm_agent/hssm_info.txt 2>&1

   if [ -f  /etc/rc2.d/S99appqcime ]; then
    cp /etc/rc2.d/S99appqcime $tmpdir/hssm_agent/S99appqcime.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/S99appqcime.txt'>S99appqcime.txt</a></td></tr> " >> $WEBLEFT 2>&1
   fi

   if [ -f /etc/rc.d/rc2.d/S99appqcime ]; then 
    cp /etc/rc.d/rc2.d/S99appqcime $tmpdir/hssm_agent/S99appqcime.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/S99appqcime.txt'>S99appqcime.txt</a></td></tr> " >> $WEBLEFT 2>&1
   fi
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/logging.properties.txt'>logging.properties</a></td></tr> " >> $WEBLEFT 2>&1
   cp /opt/APPQcime/jre/lib/logging.properties $tmpdir/hssm_agent/logging.properties.txt > /dev/null 2>&1


  echo "Checking HSSM CIM Agent Ports using [netstat -a] ..."
   echo $LINE >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
   netstat -a >$OUTDIR/.netstat
   x=`cat $OUTDIR/.netstat |grep 17000 `
   if [ $? = 0 ]; then
     echo "found 17000" >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
     echo $x >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
   else 
     echo "Port 17000 not open for HSSM agent! ..." >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
     touch $tmpdir/hssm_agent/hssm_info.txt 2>&1
   fi
   
   x=`cat $OUTDIR/.netstat |grep 17000 `
   if [ $? = 0 ]; then
     echo "found 17000" >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
     echo $x >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
   else 
     echo "Port 17000 not open for HSSM agent! ..." >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
     touch $tmpdir/hssm_agent/hssm_info.txt 2>&1
   fi
  rm -f $OUTDIR/.netstat > /dev/null 2>&1

  echo $LINE >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
  echo "#perl -v" >>$tmpdir/hssm_agent/hssm_info.txt 2>&1
  perl -v >>$tmpdir/hssm_agent/hssm_info.txt 2>&1
  echo $LINE >> $tmpdir/hssm_agent/hssm_info.txt 2>&1
  ls -AlR /opt/APPQcime > $tmpdir/hssm_agent/hssm_info.txt 2>&1

        case $SYSOS in
        sun)
                if [ -f /etc/hba.conf ]; then
                echo "#find /usr/lib |grep -i hbaapi" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                find /usr/lib |grep -i hbaapi >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		echo "#cat /etc/hba.conf " >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		cat /etc/hba.conf >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/hbaapi.txt'>HBAAPI Info</a></td></tr>" >> $WEBLEFT 2>&1
		else
                 echo "SNIA HBAAAPI LIBRARY NOT FOUND!" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
   	        fi	
                ;;
        hpux )
                if [  -f $tmpdir/hba/hba.conf ]; then
                echo "#find /usr/lib |grep -i hbaapi" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                find /usr/lib |grep -i hbaapi >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "#find /opt/snia" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                find /opt/snia >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		echo "#cat /etc/hba.conf " >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		cat /etc/hba.conf >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/hbaapi.txt'>HBAAPI Info</a></td></tr>" >> $WEBLEFT 2>&1
		else
                  echo "SNIA HBAAAPI LIBRARY NOT FOUND!" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		fi

                 ;;
        aix)
		if [ -f /etc/hba.conf ] ; then
                echo "grep devices.common.IBM.fc.hba-api $tmpdir/software/software_lslpp-L.txt" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                grep devices.common.IBM.fc.hba-api $tmpdir/software/software_lslpp-L.txt >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		echo "#cat /etc/hba.conf " >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		cat /etc/hba.conf >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/hbaapi.txt'>HBAAPI Info</a></td></tr>" >> $WEBLEFT 2>&1
		else
                  echo "SNIA HBAAAPI LIBRARY NOT FOUND!" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		fi
                ;;
        linux)
		if [ -f /etc/hba.conf ]; then
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		echo "#cat /etc/hba.conf " >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		cat /etc/hba.conf >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                echo "--------------------------------------" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
                grep  -i "HBA API" $tmpdir/os_files/rpm.qisva.txt >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		else
                  echo "SNIA HBAAAPI LIBRARY NOT FOUND!" >> $tmpdir/hssm_agent/hbaapi.txt 2>&1
		fi
                ;;
        esac

java -version >> $tmpdir/hssm_agent/java.version.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_agent/java.version.txt'>Java Version</a></td></tr>" >> $WEBLEFT 2>&1

else
echo "no hssm CIM client" > $tmpdir/not_found/no_hssm_agent 2>&1
fi

####################################################################3
# CHECK  FOR HSSM SERVER
####################################################################3


echo "Looking for HSSM Server Logs ..." 

#==============================
x=0
check=0
exvar=0
test $APPIQ_DIST >/dev/null 2>&1
if [ $? != 0 ]; then
 APPIQ_DIST=/opt/HiCommand_StorageServices_Manager 
fi

while [ $exvar = 0 ]; 
do

for i in "$APPIQ_DIST" "/opt/hssm" "/opt/HSSM" 
do

if [ -d $i ] && [ $exvar = 0 ]; then
  exvar=1
  echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HSSM SERVER</B></td></tr> " >> $WEBLEFT 2>&1
  #i="HiCommand_StorageServices_Manager";
  echo "Found HSSM Server in $i ..."
  mkdir $tmpdir/hssm_server > /dev/null 2>&1
  printf "Gathering HSSM Server logs from ${i} ..."
  tail -10000 ${i}/logs/appiq.log >> $tmpdir/hssm_server/appiq.10k.txt  2>&1 &
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/appiq.10k.txt'>appiq.log -10k</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
    cp ${i}/logs/appiq.log $tmpdir/hssm_server/appiq.log.txt  > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/appiq.log.txt'>appiq.log</a></td></tr> " >> $WEBLEFT 2>&1

  for n in 1 2 3 4 5
   do
   if [ -f ${i}/logs/appiq.log.${n} ]; then
    cp ${i}/logs/appiq.log.${n} $tmpdir/hssm_server/appiq.log.${n}.txt  > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/appiq.log.${n}.txt'>appiq.log.${n}</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."
   fi
  done

  tail -10000 ${i}/logs/cimom.log >> $tmpdir/hssm_server/cimom.10k.txt > /dev/null 2>&1 &
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom.10k.txt'>cimom.log -10k</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."

  cp ${i}/logs/cimom.log $tmpdir/hssm_server/cimom.log.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom.log.txt'>cimom.log</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."

  for n in 1 2 3 4 5 
   do
   if [ -f ${i}/logs/cimom.log.${n} ]; then
    cp ${i}/logs/cimom.log.{n}  $tmpdir/hssm_server/cimom.log.${n}.txt  > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom.log.${n}.txt'>cimom.log.${n}</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."
   fi
  done

  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/version.txt'>HSSM Version</a></td></tr> " >> $WEBLEFT 2>&1
  cat ${i}/Version.txt >> $tmpdir/hssm_server/version.txt 2>&1



   echo "HOSTNAME = $HOSTNAME" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "APPIQ_DIST = $APPIQ_DIST" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "CIMIQ_DIST = $CIMIQ_DIST" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "CLI_DIR = $CLI_DIR" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "JBOSS4_DIST = $JBOSS4_DIST" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "JBOSS_DIST = $JBOSS_DIST" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "MGR_DIST = $MGR_DIST" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ODBC_HOME = $ODBC_HOME" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORACLE_BASE = $ORACLE_BASE" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORACLE_HOME = $ORACLE_HOME" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORACLE_OWNER = $ORACLE_OWNER" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORACLE_SID = $ORACLE_SID" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORA_SID = $ORA_SID" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "ORA_USER_HOME = $ORA_USER_HOME" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "JAVA_HOME = $JAVA_HOME" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "LIBPATH = $LIBPATH" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "DISPLAY = $DISPLAY" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "PATH = $PATH" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   echo "SHELL = $SHELL" >> $tmpdir/hssm_server/hssm_environment.txt 2>&1
   printf "."
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/hssm_environment.txt'>HSSM Environment Variables</a></
td></tr> " >> $WEBLEFT 2>&1

  cp ${i}/logs/GAEDSummary.log $tmpdir/hssm_server/gaed_summary.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/gaed_summary.txt'>GAED_summary.log</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."
  cp ${i}/logs/cimom-summary.log $tmpdir/hssm_server/cimom_summary.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom_summary.txt'>cimom_summary.log</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."

  for n in 1 2 3 4 5
   do
   if [ -f ${i}/logs/cimom-segment${n}.log ]; then
    cp ${i}/logs/cimom-segment${n}.log  $tmpdir/hssm_server/cimom-segment${n}.log.txt  > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom-segment${n}.log.txt'>cimom-segment${n}.log</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."
   fi
  done

  for n in 1 2 3 4 5
   do
   if [ -f ${i}/logs/cimom-summary-segment${n}.log ]; then
    cp ${i}/logs/cimom-summary-segment${n}.log  $tmpdir/hssm_server/cimom-summary-segment${n}.log.txt  > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimom-summary-segment${n}.log.txt'>cimom-summary-segment${n}.log</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."
   fi
  done
 
   
  cp ${i}/logs/LicenseChanges.log $tmpdir/hssm_server/LicenseChanges.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/LicenseChanges.txt'>License Changes</a></td></tr> " >> $WEBLEFT 2>&1
  printf "."

  cp ${i}/logs/HiCommand_StorageServices_Manager_InstallLog.log $tmpdir/hssm_server/HiCommand_StorageServices_Manager_InstallLog.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/HiCommand_StorageServices_Manager_InstallLog.txt'>HSSM Install Log</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  cp ${i}/logs/dbAdmin.log $tmpdir/hssm_server/dbAdmin.log.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/dbAdmin.log.txt'>dbAdmin.log</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  
  if [ -f ${i}/logs/FtpServer.log ]; then
  cp ${i}/logs/FtpServer.log $tmpdir/hssm_server/FtpServer.log.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/FtpServer.log.txt'>FtpServer.log</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  fi
 
  cd ${i}/logs/ ; ls Install*.log >/dev/null 2>&1
  if [ $? = 0 ]; then 
  cd ${i}/logs/ ; ls Install*.log |while read file
   do
  cp ${i}/logs/$file $tmpdir/hssm_server/${file}.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/${file}.txt'>Install Log</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
   done
  fi
  if [ -f $tmpdir/hssm_server/appiq.log ] ; then
   tail -3000 $tmpdir/hssm_server/appiq.log |grep -v INFO >> $tmpdir/hssm_server/appiq.noinfo.txt  2>&1 &
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/appiq.noinfo.txt'>appiq.log | grep -v INFO</a></td></tr> " >> $WEBLEFT  2>&1
   printf "."
  fi
  cp $APPIQ_DIST/Tools/start-appstormanager.sh $tmpdir/hssm_server/start-appstormanager.sh.txt  > /dev/null 2>&1
  cp $APPIQ_DIST/Tools/stop-appstormanager.sh $tmpdir/hssm_server/stop-appstormanager.sh.txt  > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/start-appstormanager.sh.txt'>start-appstormanager.sh</a></td></tr> " >> $WEBLEFT  2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/stop-appstormanager.sh.txt'>stop-appstormanager.sh</a></td></tr> " >> $WEBLEFT  2>&1

  cp /etc/init.d/appstormanager $tmpdir/hssm_server > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/appstormanager'>/etc/init.d/appstormanager</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cat ${i}/JBossandJetty/server/appiq/conf/jboss.properties >> $tmpdir/hssm_server/jboss.properties.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/jboss.properties.txt'>jboss.properties</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  cat ${i}/Data/Configuration/customProperties.properties >> $tmpdir/hssm_server/customProperties.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/customProperties.txt'>customProperties</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  cp ${i}/ManagerData/conf/solaris-wrapper.conf $tmpdir/hssm_server/solaris-wrapper.conf.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/solaris-wrapper.conf.txt'>solaris-wrapper.conf</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

   if [ -f ${i}/CimExtension/conf/cim.extension.parameters ]; then
     cp ${i}/CimExtension/conf/cim.extension.parameters $tmpdir/hssm_server/cim.extension.parameters.txt 2>&1
     echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cim.extension.parameters.txt'>cim.extension.parameters</a></td></tr> " >> $WEBLEFT  2>&1
     printf "."
   fi

  cp ${i}/Cimom/config/cimomlog4jbase.properties $tmpdir/hssm_server/cimomlog4jbase.properties.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/cimomlog4jbase.properties.txt'>cimomlog4jbase.properties</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  cp /var/.com.zerog.registry.xml $tmpdir/hssm_server/
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/.com.zerog.registry.xml '>zerog xml file</a></td></tr> " >> $WEBLEFT  2>&1

  cp ${i}/logs/boot.log $tmpdir/hssm_server/boot.log.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/boot.log.txt'>boot.log</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  echo "#egrep 'bootstrap|Started in' appiq.log" >> $tmpdir/hssm_server/hssm_startup_times.txt 2>&1
  egrep "bootstrap|Started in" appiq.log >> $tmpdir/hssm_server/hssm_startup_times.txt 2>&1
  printf "."
  egrep "bootstrap|Started in" appiq.log.1 >> $tmpdir/hssm_server/hssm_startup_times.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/hssm_startup_times.txt'>HSSM Server Startup Times</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."

  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/hssm_perl_info.txt'>hssm perl info</a></td></tr> " >> $WEBLEFT 2>&1

  echo "#perl -v ">> $tmpdir/hssm_server/hssm_perl_info.txt 2>&1
  perl -v >> $tmpdir/hssm_server/hssm_perl_info.txt 2>&1
  echo $LINE >> $tmpdir/hssm_server/hssm_perl_info.txt 2>&1
  check=1
  printf "\n"


echo "Gathering list files in $i ..."
  ls -Al ${i}/ >> $tmpdir/hssm_server/ls.hssm.server.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/ls.hssm.server.txt'>ls $i</a></td></tr> " >> $WEBLEFT  2>&1

  ls -AlR $i  >> $tmpdir/hssm_server/ls.hssm.server.output.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/ls.hssm.server.output.txt'> ls -AlR $i" >> $WEBLEFT  2>&1


######################################
echo  "
--------------------------------------------------------------------- \n
The following is a list of all ports for HSSM as of v4\n
They all may or not be open depending on the customer configuration \n
--------------------------------------------------------------------- \n
The oracle QoS agent uses port 1521 by default\n
The CIM Agent uses port 17000 by default for agent version  > 4\n
Default http connection is port 80\n
Default SSL connection is port 443\n
Windows Hosts use DCOM which by default listens on port 135\n
HiCommand listens on default port 2001\n
Cisco Switches listen on ports 161 and 162 by default\n
Qlogic Switches listen on port 161 and 162 by default\n
McData SNMP listens on port 161 and 162 by default\n
Brocade switches listen via http on port 80 and on port 111 to determine higher RPC dynamic ports\n
The McData SWAPI API management server listens on port 59521 by default\n
CNT Switches/Directors listen on ports 161 and 137 by default\n
EMC Symmetrix and DMX solutions enabler listens on port 2707 by default\n
HP XP series StorageWorks Command View server listens on port 5988\n
EMC Clariion listens on port 6389 by default\n
Engenio storage listens on port 2463 by default\n
SUN StorEdge 3510/6920 SMI-S provider server listens on port 5988\n
The high ranges default ports that are dynamically assigned for UNIX hosts are:\n
IBM AIX 32768 . 65535\n
HP-UX 49152 . 65535\n
Linux 49152 . 65535\n
" > $tmpdir/hssm_server/README_hssm_server_ports.txt 2>&1
echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/README_hssm_server_ports.txt'>HSSM Port README" >> $WEBLEFT  2>&1


else
 if [ $check = 0 ];
  then
  echo "no hssm server" > $tmpdir/not_found/no_hssm_server 2>&1
 fi
fi
########################################
done   # done for 
exvar=1
done  # done while exvar

###################################################################
# ORACLE
###################################################################


exvar=0
test $ORACLE_BASE >/dev/null 2>&1
if [ $? != 0 ]; then
ORACLE_BASE=/opt/oracle/product/9.2.0.1.0
fi

while [ $exvar = 0 ];
do

for oradir in "$ORACLE_BASE"  /opt/oracle "/oracle" 
do

if [ -d $oradir/oradata ] && [ $exvar = 0 ]; then
  exvar=1
  echo "Found Oracle ..."
  echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>ORACLE</B></td></tr> " >> $WEBLEFT 2>&1

  mkdir $tmpdir/hssm_server > /dev/null 2>&1
  mkdir $tmpdir/hssm_server/oracle > /dev/null 2>&1
  mkdir $tmpdir/hssm_server/oracle/logs > /dev/null 2>&1
  odir=$tmpdir/hssm_server/oracle
  printf "Gathering oracle files required for analysis ..."
  du -k $oradir/oradata > $odir/du.oracle.oradata.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/du.oracle.oradata.txt'>du -k $oradir</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
 echo "# ls -Alt  $oradir/oradata/APPIQ" > $odir/ls.oracle.oradata.txt 2>&1
  ls -Alt  $oradir/oradata/APPIQ >> $odir/ls.oracle.oradata.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/ls.oracle.oradata.txt'>ls oradata</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cp /etc/init.d/dbora $odir/dbora.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/dbora.txt'>/etc/init.d/dbora</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  echo "cat $oradir/admin/APPIQ/pfile/init.ora*" >>$odir/init.ora.files.txt > /dev/null 2>&1
  cat $oradir/admin/APPIQ/pfile/init.ora* >>$odir/init.ora.files.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/init.ora.files.txt'>init.ora files</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cp $oradir/network/admin/tnsnames.ora $odir/tnsnames.ora.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/tnsnames.ora.txt'>tnsnames.ora</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cp $oradir/network/admin/listener.ora $odir/listener.ora.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/listener.ora.txt'>listener.ora</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cp $oradir/dbs/initAPPIQ.ora $odir/initAPPIQ.ora.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/initAPPIQ.ora.txt'>initAPPIQ.ora</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  cp $oradir/database/spfileAPPIQ.ora $odir/spfileAPPIQ.ora.txt > /dev/null 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/spfileAPPIQ.ora.txt'>spfileAPPIQ.ora</a></td></tr> " >> $WEBLEFT  2>&1
  printf "."
  printf "\n"

  echo "Gathering a list of files in Oracle directory ..."
  find $oradir > $odir/find.oracle.output.txt 2>&1
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/find.oracle.output.txt'>find $oradir</a></td></tr> " >> $WEBLEFT  2>&1
  printf "Searching for and Copying Oracle logs ..."
  cat $odir/find.oracle.output.txt |grep -v sample |grep "\.log" |while read logfile
    do
      cp $logfile $odir/logs > /dev/null 2>&1
    printf "."
    done
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/logs'>misc oracle logs</a></td></tr> " >> $WEBLEFT  2>&1
   printf "\n"

 dt=`date +'%b'`
for dumpdir in bdump udump pfile create
do
 if [ -d  $oradir/admin/APPIQ/${dumpdir} ] ; then
 printf "Gathering oracle user trace files from $dumpdir ..."
 x=0
cd $oradir/admin/APPIQ/${dumpdir}/ ; ls -Alt |awk '{print $9}' | while read file
  do
     mkdir $odir/${dumpdir} > /dev/null 2>&1
     cp $file $odir/${dumpdir}> /dev/null 2>&1
     printf "."
     x=`expr $x + 1`
     if [ $x = 8 ];
      then
       break
     fi
  done
  printf "\n"
 fi
done

 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/bdump/'> APPIQ/bdump logs" >> $WEBLEFT  2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/udump/'> APPIQ/udump logs" >> $WEBLEFT  2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/pfile/'> APPIQ/pfile logs" >> $WEBLEFT  2>&1
 echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/oracle/create/'> APPIQ/create logs" >> $WEBLEFT  2>&1

if [ -d /var/sadm/appiq ]; then
  cp -R /var/sadm/appiq/* $tmpdir/hssm_server/ > /dev/null 2>&1
  mv $tmpdir/hssm_server/orahome $tmpdir/hssm_server/orahome.txt
  echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hssm_server/orahome.txt'>/var/sadm/appiq/orahome</a></td></tr> " >> $WEBLEFT  2>&1
fi

fi
done # end for
exvar=1
done  # end while

}

#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
# VERITAS FUNCTIONS
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################

veritas()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

#############################################################
###  This section  will generate some Veritas info if available

echo "Checking to see if Veritas Volume Manager is installed ..."

if [ -f /usr/sbin/vxdctl ]
then
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>VERITAS</B></td></tr> " >> $WEBLEFT 2>&1

   printf "Found Veritas Volume Manager ..."
    mkdir $tmpdir/veritas > /dev/null 2>&1
    /usr/sbin/vxprint -hrt >> $tmpdir/veritas/vxprint-hrt.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxinfo.txt'>Veritas Info</a></td></tr> " >> $WEBLEFT 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxprint-hrt.txt'>vxprint-hrt.txt</a></td></tr> " >> $WEBLEFT 2>&1
     if [ ! -s $tmpdir/veritas/vxprint-hrt.txt ]; then
        echo "PROBLEM issuing vxprint command! Please ensure that Veritas is Running!" >> $tmpdir/veritas/vxinfo.txt 2>&1
        printf "\n"
        echo "PROBLEM issuing vxprint command! Please ensure that Veritas is Running!" 
      else	
        if [ -f /kernel/drv/vxdmp.conf ]; then 
         cp /kernel/drv/vxdmp.conf $tmpdir/veritas/vxdmp.conf.txt
         echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdmp.conf.txt'>vxdmp.conf</a></td></tr> " >> $WEBLEFT 2>&1
        fi
        printf "."
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "This files contains Veritas specific info" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "The following is node License info" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	(vxlicense -p) >> $tmpdir/veritas/vxinfo.txt 2>&1
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	/usr/lib/vxvm/bin/vxliccheck -pv >> $tmpdir/veritas/vxinfo.txt 2>&1
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "The following is extended package info" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt

        printf "."
	case $SYSOS in
        sun)
                /bin/pkginfo -l VRTSvxvm.* >> $tmpdir/veritas/vxinfo.txt 2>&1
		echo $LINE >> $tmpdir/veritas/vxinfo.txt
                ;;
        hpux )
                grep -i VRTS $tmpdir/software/swlist-l_product.txt >> $tmpdir/veritas/vxinfo.txt 2>&1
		echo $LINE >> $tmpdir/veritas/vxinfo.txt
                 ;;
        aix)
                grep -i VRTS $tmpdir/software/software_lslpp-L.txt >> $tmpdir/veritas/vxinfo.txt 2>&1
		echo $LINE >> $tmpdir/veritas/vxinfo.txt
                ;;
        linux)
                grep  -i VRTS $tmpdir/os_files/rpm.qisva.txt >>$tmpdir/veritas/vxinfo.txt 2>&1
		echo $LINE >> $tmpdir/veritas/vxinfo.txt
                ;;
        esac

        printf "."
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "The following lists the system vx modules" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "The following lists all controllers Veritas found" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
        printf "."
	/usr/sbin/vxdmpadm listctlr all >> $tmpdir/veritas/vxinfo.txt 2>&1
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
	echo "This last section lists vxdisks" >> $tmpdir/veritas/vxinfo.txt
	echo $LINE >> $tmpdir/veritas/vxinfo.txt
        printf "."



	/usr/sbin/vxdg list >> $tmpdir/veritas/vxdg.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdg.txt'>vxdg list</a></td></tr> " >> $WEBLEFT 2>&1
        printf "."
	/usr/sbin/vxinfo >> $tmpdir/veritas/vxinfo.cmd.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdg.txt'>vxinfo</a></td></tr> " >> $WEBLEFT 2>&1
        printf "."
        /usr/sbin/vxdisk -o alldgs list >> $tmpdir/veritas/vxdisk-list.alldgs.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdisk-list.alldgs.txt'>vxdisk list alldgs</a></td></tr> " >> $WEBLEFT 2>&1
        printf "."
	/usr/sbin/vxdmpadm listenclosure all  >> $tmpdir/veritas/vxdmp.listenclosure.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxstat.txt'>vxstat</a></td></tr> " >> $WEBLEFT 2>&1
        printf "."
	/usr/sbin/vxdisk list >> $tmpdir/veritas/vxdisk_list.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdisk_list.txt'>vxdisk list</a></td></tr> " >> $WEBLEFT 2>&1
         awk '{print $1}' $tmpdir/veritas/vxdisk_list.txt |grep -v DEVICE |while read vx_dev
	    do
	        vxdisk list $vx_dev >> $tmpdir/veritas/vxdisk_list_detail.txt 2>&1
	    printf "."
	    done
            echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxdisk_list_detail.txt'>vxdisk list detail</a></td></tr> " >> $WEBLEFT 2>&1
            printf "\n"
     fi

else
	echo "Veritas was not found. File /usr/sbin/vxdctl does not exist." > $tmpdir/not_found/no_veritas
fi


if [ -f /opt/VRTS/bin/vxlicrep ]; then
   /opt/VRTS/bin/vxlicrep >$tmpdir/veritas/vxlicrep.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vxlicrep.txt'>vxlicrep</a></td></tr> " >> $WEBLEFT 2>&1
fi

############ LOOKING FOR VCS ###################

if [ -f /opt/VRTSvcs/bin/hastatus ]
then
echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>VERITAS CLUSTER</B></td></tr> " >> $WEBLEFT 2>&1
   echo "Found Veritas Cluster Server ..."
   if [ ! -d $tmpdir/veritas ]; then
    mkdir $tmpdir/veritas > /dev/null 2>&1
   fi
   if [ ! -d $tmpdir/veritas/vcs ]; then
    mkdir $tmpdir/veritas/vcs > /dev/null 2>&1
   fi
   vcs=$tmpdir/veritas/vcs
   printf "Gathering main configuration files ..."
   cp /etc/VRTSvcs/conf/config/main.cf $vcs/main.cf.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/main.cf.txt'>main.cf</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   cp /etc/llttab $vcs/llttab.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/llttab.txt.txt'>llttab</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   cp /etc/llthosts $vcs/lltthosts.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/llthosts.txt'>llthosts</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   cp /etc/gabtab $vcs/gabtab.txt > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/gabtab.txt'>gabtab</a></td></tr> " >> $WEBLEFT 2>&1
   printf "\n"
   echo "Gathering VCS log files (this may take a minute) ..."
   mkdir $vcs/logs > /dev/null 2>&1
   cp /var/VRTSvcs/log/* $vcs/logs/ > /dev/null 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/logs/'>VCS Error logs</a></td></tr> " >> $WEBLEFT 2>&1

   printf "Checking VCS status and finishing up..."
   echo "/opt/VRTSvcs/bin/hares -display " >> $vcs/hares.txt 2>&1
   /opt/VRTSvcs/bin/hares -display  >> $vcs/hares.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/hares.txt'>hares -display</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   echo "/opt/VRTSvcs/bin/hastatus -summary " >> $vcs/hares.txt 2>&1
   /opt/VRTSvcs/bin/hastatus -summary  >> $vcs/hastatus_summary.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/hastatus_summary.txt'>hastatus -summary</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   echo "#vxlicense -p " >> $vcs/vxlicense-p.txt 2>&1
   (vxlicense -p) >> $vcs/vxlicense-p.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/vxlicense-p.txt'>VCS License</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   (lltstat -nvv) >> $vcs/lltstat-nvv.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/lltstat-nvv.txt'>lltstat -nvv</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
   (lltstat -p) >> $vcs/lltstat-p.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/lltstat-p.txt'>lltstat -p</a></td></tr> " >> $WEBLEFT 2>&1
   printf "."
  ( /sbin/gabconfig -a) >> $vcs/gabconfig-a.txt 2>&1
   echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/veritas/vcs/gabconfig-a.txt'>gabconfig -a</a></td></tr> " >> $WEBLEFT 2>&1
  printf "\n"
else
      echo "Veritas Cluster Server was not found. File /opt/VRTSvcs/bin/hastatus  does not exist." > $tmpdir/not_found/no_vcs 
fi



}




#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
# HITRACK MONITOR
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################

hitrack()
{
if [ -f /tmp/.setx ]; then
 set -x
fi

echo "Checking to see if HiTrack Monitor is installed ..."

for HITDIR in "/usr/hds/hitdfmon" "/opt/hds/hitdfmon" "/opt/hitdfmon" "/opt/hitrack"
do
if [ -f ${HITDIR}/rundfmon ]; then
    printf "\n"
    printf "Found HiTrack Monitor in [${HITDIR}] ..."
    mkdir $tmpdir/hitrack > /dev/null 2>&1
    mkdir $tmpdir/hitrack/logs > /dev/null 2>&1
    mkdir $tmpdir/hitrack/data > /dev/null 2>&1

    HTVER=`grep Version $HITDIR/HiTrack*.log |awk '{print $2}'|uniq` 
    echo "<tr><td width='100%' bgcolor='#C0C0C0'><B>HITRACK MONITOR <u>$HTVER</u></B></td></tr> " >> $WEBLEFT 2>&1

     echo "#${HITDIR}/rundfmon status" >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
     (${HITDIR}/rundfmon status) >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
     grep -i  "monitor is running" $tmpdir/hitrack/hitrackstatus.txt > /dev/null 2>&1 
      if [ $? = 0 ]; then
       echo $LINE >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       echo "#ps -ef |grep HiTrack |grep -v grep"  >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       ps -ef |grep HiTrack |grep -v grep >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/hitrackstatus.txt'>HiTrack Monitor <b><font color='#008000'>IS Running</b></font></a></td></tr> " >> $WEBLEFT 2>&1
      else
       echo $LINE >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       echo "#ps -ef |grep HiTrack |grep -v grep" >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       ps -ef |grep HiTrack |grep -v grep >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
        echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/hitrackstatus.txt'>HiTrack Monitor <b><font color='#FF0000'>IS <u>NOT</u> Running</b></font></a></td></tr> " >> $WEBLEFT 2>&1
      fi
       echo $LINE >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       echo "#grep Version $HITDIR/HiTrack*.log " >> $tmpdir/hitrack/hitrackstatus.txt 2>&1
       echo "Version = $HTVER"  >> $tmpdir/hitrack/hitrackstatus.txt 2>&1

    if [ -f ${HITDIR}/devices.export ]; then
    cp ${HITDIR}/devices.export  $tmpdir/hitrack/devices.export.txt  2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/devices.export.txt'>HiTrack Devices</a></td></tr> " >> $WEBLEFT 2>&1
    printf "."
    fi
    
    if [ -f ${HITDIR}/HitDFmon.config ]; then
    cp ${HITDIR}/HitDFmon.config  $tmpdir/hitrack/HitDFmon.config.txt  2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/HitDFmon.config.txt'>HiTrack Configuration</a></td></tr> " >> $WEBLEFT 2>&1
    printf "."
    fi

      echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/logs/'>HiTrack Logs</a></td></tr> " >> $WEBLEFT 2>&1
    cd ${HITDIR}; ls *.log |while read filename
     do
      cp ${HITDIR}/$filename $tmpdir/hitrack/logs/${filename}.txt > /dev/null 2>&1
      printf "."
    done
    cp ${HITDIR}HiTrack.errout  $tmpdir/hitrack/logs/HiTrack.errout.txt > /dev/null 2>&1 

    cp ${HITDIR}/HitDFmon.lax $tmpdir/hitrack/HitDFmon.lax.txt > /dev/null 2>&1 
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/HitDFmon.lax.txt'>HiTrack Launch Anywhere</a></td></tr> " >> $WEBLEFT 2>&1
    printf "."

    mkdir $tmpdir/hitrack/java > /dev/null 2>&1
    cp ${HITDIR}/jre/lib/logging.properties $tmpdir/hitrack/java/logging.properties.txt > /dev/null 2>&1 
    cp ${HITDIR}/jre/lib/net.properties $tmpdir/hitrack/java/net.properties.txt > /dev/null 2>&1 
    cp ${HITDIR}/jre/lib/javax.comm.properties $tmpdir/hitrack/java/javax.comm.properties.txt > /dev/null 2>&1 
    cp ${HITDIR}/jre/lib/sound.properties $tmpdir/hitrack/java/sound.properties.txt > /dev/null 2>&1 
    cp ${HITDIR}/jre/lib/content-types.properties $tmpdir/hitrack/java/content-types.properties.txt > /dev/null 2>&1 
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/java '>HiTrack JRE Properties</a></td></tr> " >> $WEBLEFT 2>&1
    printf "."

    echo "# ${HITDIR}/jre/bin/java -version " >> $tmpdir/hitrack/jreversion.txt  2>&1
    ($HITDIR/jre/bin/java -version)  >> $tmpdir/hitrack/jreversion.txt 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/jreversion.txt'>HiTrack JRE Version</a></td></tr> " >> $WEBLEFT 2>&1
    printf "."
    if [ -d ${HITDIR}/FileStore ]; then
     echo "#ls -AL ${HITDIR}/FileStore" >> $tmpdir/hitrack/filestore.txt 2>&1 
     ls -AL ${HITDIR}/FileStore >> $tmpdir/hitrack/filestore.txt 2>&1 
     echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/filestore.txt'>ls /FileStore Directory</a></td></tr> " >> $WEBLEFT 2>&1
     printf "."
    fi

    mkdir $tmpdir/hitrack/ftpdir > /dev/null 2>&1
    cp ${HITDIR}/ftpDir/*  $tmpdir/hitrack/ftpdir > /dev/null 2>&1
    cp ${HITDIR}/ftpDir/logFile  $tmpdir/hitrack/ftpdir/logfile.txt > /dev/null 2>&1
    cp ${HITDIR}/ftpDir/Report.Store  $tmpdir/hitrack/ftpdir/Report.Store.txt > /dev/null 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/ftpdir/logfile.txt'>HiTrack Transmission Log</a></td></tr> " >> $WEBLEFT 2>&1
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/ftpdir'>ftpDir Directory</a></td></tr> " >> $WEBLEFT 2>&1
    cp ${HITDIR}/object.d* $tmpdir/hitrack/data > /dev/null 2>&1 
    cp ${HITDIR}/DFFILE.STORE* $tmpdir/hitrack/data > /dev/null 2>&1 
    echo "<tr><td width='100%' bgcolor='#FFFFFF'><a target='main' href='../txt/hitrack/data'>Data Files</a></td></tr> " >> $WEBLEFT 2>&1
    printf "\n"
fi
done
}
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
#################################################################################
echo "
<p>GetConfig:</p>
<p><b>Solaris Section</b></p>
<p>*note: This section includes information about the solaris commands run. It also includes all main commands that are universal throughout all of the getconfigs. <br></p>
<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' height='517'>
  <tr>
    <td width='25%' height='19'><b>OS/Version[uname]&nbsp; </b></td>
    <td width='75%' height='19'>Displays the OS Version of Sun Solaris</td>
  </tr>
  <tr>
    <td width='25%' height='20'><b>/etc/path_to_inst</b></td>
    <td width='75%' height='20'>Displays the mappings of physical device&nbsp; 
    names to instance numbers.</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/mnttab</b></td>
    <td width='75%' height='19'>Displays all the filesystems that are to be 
    mounted by the OS at boot</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/vfstab</b></td>
    <td width='75%' height='19'>Displays the defaults for each file system</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>sd.conf</b></td>
    <td width='75%' height='19'>Configuration file where all SCSI devices are 
    defined</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ssd.conf</b></td>
    <td width='75%' height='19'>The driver configuration file that displays the 
    SCSI-2 and SUN Sparc Fibre Channel devices</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/init.d</b></td>
    <td width='75%' height='19'>List of all files in /etc/init.d directory</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/rc2.d</b></td>
    <td width='75%' height='19'>List of all files in /etc/rc2.d directory</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/rc3.d</b></td>
    <td width='75%' height='19'>List of all files in /etc/rc3.d directory</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Shell Environment</b></td>
    <td width='75%' height='19'>List of the current shell environment using the<b> 
    env </b>command</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>crontab -l</b></td>
    <td width='75%' height='19'>Displays all of the <b>cron </b>tabs</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>prtconf -vP</b></td>
    <td width='75%' height='19'>Displays a more detailed output of the Solaris 
    hardware configuration using the <b>prtconf</b> command</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>uptime</b></td>
    <td width='75%' height='19'>Displays the server uptime (amount of time 
    server has been up since the last reboot)</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ps -auwwwx</b></td>
    <td width='75%' height='19'>Displays all processes currently running in long 
    format</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ps -aewwx</b></td>
    <td width='75%' height='19'>Displays a detailed listing of all processes 
    running, environment variables/etc.</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Memory</b></td>
    <td width='75%' height='19'>Amount of memory available on the system 
    gathered from <b>prtconf</b></td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ptree -a</b></td>
    <td width='75%' height='19'>Displays the process tree for all processes 
    currently running</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>swap info</b></td>
    <td width='75%' height='19'>Displays the status of the swap file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>nfsstat</b></td>
    <td width='75%' height='19'>Displays the status of NFS, as well as the 
    client/server calls made, and to what version of NFS (v2, v3,/etc)</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>mount</b></td>
    <td width='75%' height='19'>Displays all filesystems currently mounted</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/var/adm/messages</b></td>
    <td width='75%' height='19'>Solaris main error log</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/var/adm/messages.0</b></td>
    <td width='75%' height='19'>First backup of Solaris main error log</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/var/adm/messages.1</b></td>
    <td width='75%' height='19'>Second backup of Solaris main errorlog</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>dmesg</b></td>
    <td width='75%' height='19'>Output of the dmesg system report</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>df -k </b></td>
    <td width='75%' height='19'>Output of the df-k command. Displays the amount 
    of disk space available used on all mounted filesystems</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/dev/dsk</b></td>
    <td width='75%' height='19'>List of all devices in /dev/dsk</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/dev/rdsk</b></td>
    <td width='75%' height='19'>List of all devices in /dev/rdsk</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/dev/fc</b></td>
    <td width='75%' height='19'>List of all devices in /dev/fc</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>pkginfo</b></td>
    <td width='75%' height='19'>List of all software installed on the server 
    using <b>pkginfo</b></td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>pkginfo -l</b></td>
    <td width='75%' height='19'>Detailed list of all software installed on the 
    sever</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>showrev -p</b></td>
    <td width='75%' height='19'>List of all patches on the server</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ls /opt</b></td>
    <td width='75%' height='19'>List of all files in /opt</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Java -version</b></td>
    <td width='75%' height='19'>Displays the active version of java based on the 
    current JAVA_HOME environment variable.</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>gcc -v</b></td>
    <td width='75%' height='19'>Displays the version of the GNU <b>gcc</b> 
    compiler installed</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>perl -v</b></td>
    <td width='75%' height='19'>Displays the version of perl installed</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Lunstat results</b></td>
    <td width='75%' height='19'>Displays the version of Lunstat installed</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>MPXIO Enabled</b></td>
    <td width='75%' height='19'>Displays the contents of the /kernel/mpxio/scsi_vhci.conf 
    file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>MPXIO auto Failback</b></td>
    <td width='75%' height='19'>Search output from /var/adm messages to 
    determine if auto failback is enabled by finding scsi_vhci in the error log.</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>MPXIO stmsboot</b></td>
    <td width='75%' height='19'>output of the stmsboot command</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>MPXIO fp.conf</b></td>
    <td width='75%' height='19'>Contents of the /etc/fp.conf file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>fcaw.conf</b></td>
    <td width='75%' height='19'>JNI HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>jnic.conf</b></td>
    <td width='75%' height='19'>JNI HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>lpfc.conf</b></td>
    <td width='75%' height='19'>Emulex LP8000-LP9000 HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>lpfs.conf</b></td>
    <td width='75%' height='19'>Emulex LP8000S-LP9000S HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Qlogic HBA info</b></td>
    <td width='75%' height='19'>scli commands run using the Qlogic scli and iscli
    utility to check the status of any Qlogic HBA installed</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>qla.conf</b></td>
    <td width='75%' height='19'>Qlogic HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>qlc.conf</b></td>
    <td width='75%' height='19'>Qlogic HBA configuration file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>persistent binding</b></td>
    <td width='75%' height='19'>check made in the HBA configuration files to 
    determine if persistent binding is enabled by searching for def_wwnn and 
    def_wwpn</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/kernel/drv/conf</b></td>
    <td width='75%' height='19'>All files from the /kernel/drv/conf directory 
    and a long list of all files in the drv.list.txt file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>modinfo</b></td>
    <td width='75%' height='19'>Output of the Kernel <b>modinfo</b> command to 
    show what is currently resident in the kernel.</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>sysdef -D</b></td>
    <td width='75%' height='19'>Output of the <b>sysdef</b> command to list all 
    hardware devices, as well as pseudo deviices, system devices, loadable 
    modules, and&nbsp; the&nbsp; values&nbsp; of selected kernel tunable 
    parameters</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Kernel semaphores</b></td>
    <td width='75%' height='19'>List of all kernel semaphores</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/system</b></td>
    <td width='75%' height='19'>/etc/system kernel parameter file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Queue depth</b></td>
    <td width='75%' height='19'>queue depth extracted from the /etc/system file 
    for easy reference</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>DNS lookup info</b></td>
    <td width='75%' height='19'>Forward/Reverse dns lookups as well as the 
    hostname</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>hosts file</b></td>
    <td width='75%' height='19'>/etc/hosts file</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>WWN Info(prtpicl)</b></td>
    <td width='75%' height='19'>
    The prtpicl commands gathers information from the Platform Information and Control Library (PICL). The PICL tree is the repository of all the nodes and properties created by the plug-in modules to represent the platform configuration. Every node in the PICL tree is an instance of a well-defined PICL class</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>prtpicl</b></td>
    <td width='75%' height='19'>World Wide Names on the server from the <b>
    prtpicl</b> command. The prtpicl commands gathers information from the Platform Information and Control Library (PICL). The PICL tree is the repository of all the nodes and properties created by the plug-in modules to represent the platform configuration. Every node in the PICL tree is an instance of a well-defined PICL class</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>boot device</b></td>
    <td width='75%' height='19'>The current active boot device</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>netstat</b></td>
    <td width='75%' height='19'>Output of the netstat command to show all ports 
    that are established, or listening on the system</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>ifconfig -a</b></td>
    <td width='75%' height='19'>listing of all Ethernet card in the system, as 
    well as their associated IP addresses</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>/etc/services</b></td>
    <td width='75%' height='19'>/etc/services file that defines all static ports 
    on the system</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>luxadm</b></td>
    <td width='75%' height='19'>command used to extract disk, hba, and port/node wwn information</td>

  <tr>
    <td width='25%' height='19'><b>performance</b></td>
    <td width='75%' height='19'>output of isainfo -v,&nbsp; pagesize, vmstat, 
    mpstat, iostat, and prstat</td>
  </tr>
  <tr>
    <td width='25%' height='19'><b>Solstice Disk info</b></td>
    <td width='75%' height='19'>Output using various commands to list he 
    solstice disk suite configuration (md.tab) as well as the status using 
    metastat, metadb/etc. Also lists the version.</td>
  </tr>
</table>

<p><b>HP-UX </b></p>
<p>*note: Most of the commands are similar to the Solaris. Below are only the 
differences.</p>
<p>&nbsp;</p>
<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%'>
  <tr>
    <td width='25%'><b>HW Model</b></td>
    <td width='75%'>Hardware Model of the HP server using the <b>model</b> 
    command</td>
  </tr>
  <tr>
    <td width='25%'><b>/stand/system</b></td>
    <td width='75%'>/stand/system file</td>
  </tr>
  <tr>
    <td width='25%'><b>/etc/fstab</b></td>
    <td width='75%'>File that displays all filesystems available for mount </td>
  </tr>
  <tr>
    <td width='25%'><b>/etc/mdtab</b></td>
    <td width='75%'>If the file exists, the /etc/mdtab multi disk driver file</td>
  </tr>
  <tr>
    <td width='25%'><b>Processor architecture</b></td>
    <td width='75%'>process architecture extracted from uname</td>
  </tr>
  <tr>
    <td width='25%'><b>bdf</b></td>
    <td width='75%'>hp-ux equivalent of df command to display filesystems 
    mounted, and the amount of disk space used and available for all mounted 
    volumes</td>
  </tr>
  <tr>
    <td width='25%'><b>ps -eax</b></td>
    <td width='75%'>Display all processes available</td>
  </tr>
  <tr>
    <td width='25%'><b>ps -elf</b></td>
    <td width='75%'>Another view of all processes available</td>
  </tr>
  <tr>
    <td width='25%'><b>Ioscan -fk</b></td>
    <td width='75%'>Ioscan full listing of the kernel structure</td>
  </tr>
  <tr>
    <td width='25%'><b>kmtune</b></td>
    <td width='75%'>output of the kmtune command that lists all kernel 
    parameters in the kernel</td>
  </tr>
  <tr>
    <td width='25%'><b>Queue Depth</b></td>
    <td width='75%'>queue depth gathered from the scsi_max_depth from the kmtune 
    command</td>
  </tr>
  <tr>
    <td width='25%'><b>syslog</b></td>
    <td width='75%'>primary hp-ux error log</td>
  </tr>
  <tr>
    <td width='25%'><b>dmesg</b></td>
    <td width='75%'>output of the dmesg command that displays system diagnostic 
    messages</td>
  </tr>
  <tr>
    <td width='25%'><b>swlist -l product</b></td>
    <td width='75%'>List of all software installed by product</td>
  </tr>
  <tr>
    <td width='25%'><b>swlist -l patch</b></td>
    <td width='75%'>List of all patches installed</td>
  </tr>
  <tr>
    <td width='25%'><b>swlist -l bundle</b></td>
    <td width='75%'>List of all bundled patches installed</td>
  </tr>
  <tr>
    <td width='25%'><b>Ioscan HBA info</b></td>
    <td width='75%'>More detailed info of any hba's installed using ioscan -fkCext_bus</td>
  </tr>
  <tr>
    <td width='25%'><b>fcmsutil detailed</b></td>
    <td width='75%'>Additional HBA information and the corresponding targets 
    assigned using fcmsutil</td>
  </tr>
  <tr>
    <td width='25%'><b>pvdisplay</b></td>
    <td width='75%'>Display of all disk physical volumes</td>
  </tr>
  <tr>
    <td width='25%'><b>ioscan -fknCdisk</b></td>
    <td width='75%'>Detailed examination of each disk/volume on the system</td>
  </tr>
  <tr>
    <td width='25%'><b>disk info -v /rdsk</b></td>
    <td width='75%'>Additional disk information of all disks defined</td>
  </tr>
  <tr>
    <td width='25%'><b>Queue depth</b></td>
    <td width='75%'>Another method of verifying the queue depth by using scsictl 
    -a for each disk</td>
  </tr>
  <tr>
    <td width='25%'><b>vgdisplay</b></td>
    <td width='75%'>Disk volume information</td>
  </tr>
  <tr>
    <td width='25%'><b>lvdislplay on log volumes</b></td>
    <td width='75%'>Lvdisplay command output of all logical volumes defined to 
    the system</td>
  </tr>
  <tr>
    <td width='25%'><b>ls /dev/vg</b></td>
    <td width='75%'>long list of all files on /dev/vg</td>
  </tr>
  <tr>
    <td width='25%'><b>ls -lR /dev</b></td>
    <td width='75%'>long list of all files on /dev</td>
  </tr>
  <tr>
    <td width='25%'>&nbsp;</td>
    <td width='75%'>&nbsp;</td>
  </tr>
</table>
<p><b>AIX</b></p>
<p>*note: Most of the commands are similar to the Solaris. Below are only the 
differences.</p>
<p>&nbsp;</p>
<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%'>
  <tr>
    <td width='22%'><b>ODM Level</b></td>
    <td width='78%'>current level of the AIX Object Data Manager (ODM)</td>
  </tr>
  <tr>
    <td width='22%'><b>Maintenance Levels</b></td>
    <td width='78%'>List of the most current maintenance levels installed</td>
  </tr>
  <tr>
    <td width='22%'><b>instfix -i</b></td>
    <td width='78%'>List of all fixes installed (patches)</td>
  </tr>
  <tr>
    <td width='22%'><b>lscfg</b></td>
    <td width='78%'>List of hardware configuration on the system</td>
  </tr>
  <tr>
    <td width='22%'><b>lsdev -C </b></td>
    <td width='78%'>List of all devices defined to the system</td>
  </tr>
  <tr>
    <td width='22%'><b>lsps</b></td>
    <td width='78%'>Display of the current paging (swap) space</td>
  </tr>
  <tr>
    <td width='22%'><b>df -Ik</b></td>
    <td width='78%'>Filesystem display info that displays all used, and 
    available space for the current mounted volumes.</td>
  </tr>
  <tr>
    <td width='22%'><b>ulimit -a</b></td>
    <td width='78%'>Displays the user process resource limits as defined in the 
    /etc/security/limits file</td>
  </tr>
  <tr>
    <td width='22%'><b>ps -eaf</b></td>
    <td width='78%'>List of all processes active and running on the system</td>
  </tr>
  <tr>
    <td width='22%'><b>svmon -p</b></td>
    <td width='78%'>Displays information about the current state of system 
    memory</td>
  </tr>
  <tr>
    <td width='22%'><b>svmon -uvt</b></td>
    <td width='78%'>Displays a snaphot view of the current system virtual memory</td>
  </tr>
  <tr>
    <td width='22%'><b>pstat -a</b></td>
    <td width='78%'>List all processes in the kernel process table</td>
  </tr>
  <tr>
    <td width='22%'><b>ls /etc/rc.d</b></td>
    <td width='78%'>list of files in /etc/rc.d ( all files started at boot time)</td>
  </tr>
  <tr>
    <td width='22%'><b>lssrc -a</b></td>
    <td width='78%'>Lists the status of the server by subsystem process</td>
  </tr>
  <tr>
    <td width='22%'><b>bootinfo -b</b></td>
    <td width='78%'>Lists the primary boot device </td>
  </tr>
  <tr>
    <td width='22%'><b>lslpp -L</b></td>
    <td width='78%'>List of all software installed on the server</td>
  </tr>
  <tr>
    <td width='22%'><b>HDS Software</b></td>
    <td width='78%'>List of all HDS software installed</td>
  </tr>
  <tr>
    <td width='22%'><b>HDS ODM level</b></td>
    <td width='78%'>Current level of the HDS ODM Patch level if present</td>
  </tr>
  <tr>
    <td width='22%'><b>lslpp driver levels</b></td>
    <td width='78%'>Current driver levels</td>
  </tr>
  <tr>
    <td width='22%'><b>HACMP version</b></td>
    <td width='78%'>Current version of IBM HACMP path failover application</td>
  </tr>
  <tr>
    <td width='22%'><b>HBA summary</b></td>
    <td width='78%'>Summary of all HBAs installed</td>
  </tr>
  <tr>
    <td width='22%'><b>Disk summary</b></td>
    <td width='78%'>Summary of all disks installed</td>
  </tr>
  <tr>
    <td width='22%'><b>HBA FCSTAT</b></td>
    <td width='78%'>List of any HBA adapters statistics</td>
  </tr>
  <tr>
    <td width='22%'><b>HBA Emulex LPFC</b></td>
    <td width='78%'>Info on the Emulex adapters installed</td>
  </tr>
  <tr>
    <td width='22%'><b>HBA Emulex LCS</b></td>
    <td width='78%'>Info on any Emulex FCS adapters</td>
  </tr>
  <tr>
    <td width='22%'><b>lspv</b></td>
    <td width='78%'>List of all physical volumes defined using the <b>lspv</b> 
    command</td>
  </tr>
  <tr>
    <td width='22%'><b>ldev -Cc disk</b></td>
    <td width='78%'>Detailed information on disk devices</td>
  </tr>
  <tr>
    <td width='22%'><b>lsvg rootvg -l</b></td>
    <td width='78%'>Detailed info on the root volumes</td>
  </tr>
  <tr>
    <td width='22%'><b>lsvg -o</b></td>
    <td width='78%'>Volume group information</td>
  </tr>
  <tr>
    <td width='22%'><b>Errpt -a</b></td>
    <td width='78%'>Main error log</td>
  </tr>
  <tr>
    <td width='22%'><b>Kernel version</b></td>
    <td width='78%'>Current version of the AIX kernel</td>
  </tr>
  <tr>
    <td width='22%'>&nbsp;</td>
    <td width='78%'>&nbsp;</td>
  </tr>
</table>
<p>&nbsp;</p>
<p><b>Linux</b></p>
<p>*note: Most of the commands are similar to the Solaris. Below are only the 
differences.</p>
<p>&nbsp;</p>
<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%'>
  <tr>
    <td width='22%'><b>hwconf</b></td>
    <td width='78%'>Linux hardware configuration</td>
  </tr>
  <tr>
    <td width='22%'><b>grub</b></td>
    <td width='78%'>/etc/sysconfig/grub boot file</td>
  </tr>
  <tr>
    <td width='22%'><b>kernel</b></td>
    <td width='78%'>listing of /etc/sysconfig/kernel</td>
  </tr>
  <tr>
    <td width='22%'><b>rawdevices</b></td>
    <td width='78%'>listing of all rawdevices</td>
  </tr>
  <tr>
    <td width='22%'><b>modules</b></td>
    <td width='78%'>/etc/modules.conf file</td>
  </tr>
  <tr>
    <td width='22%'><b>sysctl -a</b></td>
    <td width='78%'>Listing of all kernel parameters</td>
  </tr>
  <tr>
    <td width='22%'><b>inittab</b></td>
    <td width='78%'>/etc/inittab file</td>
  </tr>
  <tr>
    <td width='22%'><b>fstab</b></td>
    <td width='78%'>File that contains all filesystem information for mounted 
    volumes</td>
  </tr>
  <tr>
    <td width='22%'><b>/var/log/messages</b></td>
    <td width='78%'>Linux error logs</td>
  </tr>
  <tr>
    <td width='22%'><b>lilo.conf</b></td>
    <td width='78%'>Linux boot file that specifies which partition you are 
    booting off of.</td>
  </tr>
  <tr>
    <td width='22%'><b>lsmod</b></td>
    <td width='78%'>List all kernel modules defind</td>
  </tr>
  <tr>
    <td width='22%'><b>kernel</b></td>
    <td width='78%'>output of rpm -qa|grep -i kernel</td>
  </tr>
  <tr>
    <td width='22%'><b>proc</b></td>
    <td width='78%'>Listing of /proc</td>
  </tr>
  <tr>
    <td width='22%'><b>rpm -qia</b></td>
    <td width='78%'>List of all software information installed</td>
  </tr>
  <tr>
    <td width='22%'><b>lsraid</b></td>
    <td width='78%'>List of all disk devices installed</td>
  </tr>
  <tr>
    <td width='22%'><b>fdisk</b></td>
    <td width='78%'>List of disk devices</td>
  </tr>
  <tr>
    <td width='22%'>&nbsp;</td>
    <td width='78%'>&nbsp;</td>
  </tr>
</table>
<p><b>TRU64&nbsp;&nbsp;&nbsp; </b></p>
<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%'>
  <tr>
    <td width='22%'><b>syslog</b></td>
    <td width='78%'>Main Error log</td>
  </tr>
  <tr>
    <td width='22%'><b>hwfmgr</b></td>
    <td width='78%'>Output of hwmgr and dsfmgr command</td>
  </tr>
  <tr>
    <td width='22%'><b>ls /devices</b></td>
    <td width='78%'>output of ls /devices</td>
  </tr>
  <tr>
    <td width='22%'>&nbsp;</td>
    <td width='78%'>&nbsp;</td>
  </tr>
</table>

" >> $WEBDIR/faq.htm 2>&1




##########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
#
# MAIN SCRIPT ROUTINE
#
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################

options()
{

	if [ ! -f /tmp/.nohdlm ]
	then
         hdlm;
        else 
         echo "issued nohdlm option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.nohorcm ]
	then
         horcm;
        else 
         echo "issued nohorcm option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.noveritas ]
	then
         veritas;
        else 
         echo "issued noveritas option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.norapidx ]
        then
         rapidx;
        else 
         echo "issued norapidx option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.nohdvm ]
	then
         hdvm;
        else 
         echo "issued nohdvm option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.nohtnm ]
	then
         htnm;
        else 
         echo "issued nohtnm option" >> $tmpdir/options.txt 2>&1
        fi

        if [ ! -f /tmp/.nohssm ]
	then
         hssm;
        else 
         echo "issued nohssm option" >> $tmpdir/options.txt 2>&1
        fi


        if [ ! -f /tmp/.nohitrack ]
	then
         hitrack;
        else 
         echo "issued nohitrack option" >> $tmpdir/options.txt 2>&1
        fi
}

case $SYSOS in
sun)
 	sun;options 
  	;;
hpux)
	hpux;options 
 	;;
aix)
 	aix;options 

 	;;
linux)
	linux;options 

 	;;
tru64)
	tru64;options 

 	;;
vmware)
	vmware;options 

 	;;
esac 

###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
# Doing some web processing
###########################################################################################
###########################################################################################
###########################################################################################
echo "</tr></table><br><font size='-2' color='#288EF0'><i>yet another Bennovation ...</i></body></html>" >>$WEBLEFT 2>&1
echo "</body</html>" >>$WEBTOP 2>&1
rm -f $TMPVAR > /dev/null 2>&1
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
# Doing some final analysis
###########################################################################################
###########################################################################################
###########################################################################################

###  This section does preliminary basic analysis of the collected data

echo ""
printf "Analyzing data..."

for i in $tmpdir/messages/*
do
printf "."
 tail -1000 $i  >> $tmpdir/messages/mesg_$OUTDIR_file 2>&1
done

printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "firmware" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "SCSI Transport" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "Memory parity port" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "failed" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "disabled" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "requested block" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "error" >> $tmpdir/quick_analysis.txt
printf "."
cat $tmpdir/messages/mesg_$OUTDIR_file |grep -i "unable" >> $tmpdir/quick_analysis.txt
printf "."
rm $tmpdir/messages/mesg_$OUTDIR_file > /dev/null 2>&1
printf "\n"
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###  Now to create the tar file, zip it, then clean up
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################

gz=0
ZIPFILE=getconfig.${SYSOS}.${case_number}.${HOSTNAME}.`date +%m%d%y.%H%M%S`
gzip -V > /dev/null 2>&1
if [ $? = 0 ]; then 
gz=1
printf "Creating $OUTDIR/$ZIPFILE.tar.gz"
cd $OUTDIR; tar cf ${ZIPFILE}.tar getconfig > /dev/null 2>&1  &

i=0;
while [ $i = 0 ]
do
 ps -ef |grep "$ZIPFILE.tar" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done

printf "."
gzip $OUTDIR/${ZIPFILE}.tar &

i=0;
while [ $i = 0 ]
do
 ps -ef |grep "gzip $OUTDIR/$ZIPFILE.tar" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done

 rm -rf $OUTDIR/getconfig
 printf "."
 printf "\n\n"
 echo "Created $OUTDIR/$ZIPFILE.tar.gz" 
fi

#-------------------------------------------

if [ $gz = 0 ] && [ /usr/bin/compress ]; then
 printf "Creating $OUTDIR/$ZIPFILE.tar.Z"
 cd $OUTDIR; tar cf ${ZIPFILE}.tar getconfig  > /dev/null 2>&1 &

i=0;
while [ $i = 0 ]
do
 ps -ef |grep "$ZIPFILE.tar" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done


 printf "."
 compress $OUTDIR/${ZIPFILE}.tar &

i=0;
while [ $i = 0 ]
do
 ps -ef |grep "compress $OUTDIR/$ZIPFILE.tar" |grep -v grep > /dev/null 2>&1
 if [ $? = 0 ]; then
  printf "."
  i=0;
 else
  i=1;
 fi
sleep 1
done
rm -rf $OUTDIR/getconfig
#-------------------------------------------
 printf "."
 printf "\n\n"
 echo "Created $OUTDIR/$ZIPFILE.tar.Z"
fi

for i in hdvm htnm hssm hdlm veritas hitrack horcm rapidx
do
if [ -f /tmp/.no${i} ]; then
 rm -f /tmp/.no${i} >/dev/null 2>&1
fi
done
rm -f /tmp/.setx >/dev/null 2>&1
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###  And finally inform the user to send us the information
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
sleep 1
cd $OUTDIR
echo ""
echo ""
echo "##################################################################"
echo "##################################################################"
echo "###########   GETCONFIG EXECUTION HAS COMPLETED    ###############"
echo "##################################################################"
echo "##################################################################"
printf "\n\n"
echo "##################################################################"
echo "Please Upload the following results of the getconfig:"
if [ $gz = 1  ]; then
 printf "\n$OUTDIR/${ZIPFILE}.tar.gz \n\n"
else
 printf "\n$OUTDIR/${ZIPFILE}.tar.Z \n\n"
fi

echo "to the GSC FTP Site "TUF":	https://tuf.hds.com "
echo ""
echo "login password =		truenorth"
echo ""
echo "*note: GSC Support prefers this method as it places an entry in "
echo "our case management system and an email notification is sent to "
echo "the entire support team when your upload is complete."
echo "##################################################################"
echo ""
exit 0
##############################################################################################
##############################################################################################
########################  END OF SCRIPT ######################################################
##############################################################################################
##############################################################################################

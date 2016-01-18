#!/usr/bin/bash

#########Constants
tempfile=/tmp/temp.txt
a8amffile=
a8fwfile=
slot=
a8num=
result=
loadamcmd="/dataflash/loadam"
laecmd=$(which lae)
scriptname=$(basename $0)
logfile=/tmp/${scriptname}.out


#######Functions
function usage
{
cat << EOF
This script check a8amf file loading on scm module and test a8fw booting on A8 
Requires /dataflash/loadam command file

Usage: $0 [OPTIONS...]

OPTIONS:(optional)
   -h      Show this message
   -x      a8amf*.bit file path.  Default will use latest file in /usr/scm/fpga 
   -y      a8fw*.bin file path.  Default will use latest file in /usr/scm/fpga
   -s      scm slot number.  Default will detected and test all scm modules
   -a      a8 nymber to test.  Default will test on all 8 A8(s)
   -c	   loadam command file path.  Default=/dataflash/loadam
   -l	   output log file.  Default=$logfile

Examples:
    $0 
	   Automatically detect all installed scm boards and test all A8s using /usr/scm/fpga/a8* files
    $0 -s 1 
	   Run check on all 8 A8s on scm slot 1
    $0 -s 1 -a 1
	   Run check on A8 [1] on scm slot 1
    $0 -s 1,2 -a 1,6,8
	   Run check on A8 [1], [6], [8] on scm slot 1 and 2
EOF
exit 0
}

function rotate_logfile
{
	$(mv $logfile ${logfile}.old)
}


#printstr text logfile 1/0
function printstr
{
	#$1 text to print
	#$2 destination
	#$3 new/append
	echo $1

	if [ "${3}" = "1" ]; then
		echo $1 >> $2	
	else
		echo $1 > $2	
	fi
}
 
function file_exists
{
	if [ ! -f $1 ]; then
		printstr "Failed: $1 not found..." $logfile 1
		exit 1
	else
		echo "File $1 found ..."
	fi
}

function check_files
{
	printstr "" $logfile 1
	printstr "Checking firmware files..." $logfile 1
	#Checking a8amf file
	if [ "$a8amffile" = "" ]; then
	        printstr "a8amf file not provided.  Searching for latest file from /usr/scm/fpga" $logfile 1
	        a8amffile=$(ls -dt /usr/scm/fpga/a8amf*.bit | head -1)
	fi
	file_exists $a8amffile


	#Checking a8fw file
	if [ "$a8fwfile" = "" ]; then
       		printstr "a8fw file not provided.  Searching for latest file from /usr/scm/fpga" $logfile 1
        	a8fwfile=$(ls -dt /usr/scm/fpga/a8fw*.bin | head -1)
	fi
	file_exists $a8fwfile
	

	printstr "" $logfile 1
	printstr "Checking required executable files..." $logfile 1
	file_exists "${loadamcmd}"
	file_exists $(which "${laecmd}")
}


function check_scm_modules
{
	#Path to scm modules /proc/neo/scm
	printstr "" $logfile 1
        printstr "Searching for scm slot $slot ..." $logfile 1

	if [ "${slot}" = "" ]; then
		#searching for all installed scm board
		for i in 1 2 3
		do
			#checking for each slot
			scmfile=$(ls -dt /proc/neo/scm/s${i} | head -1)
			if [ "$scmfile" != "" ]; then
				#scm installed
				printstr "Found scm module in slot ${i}..." $logfile 1
				if [ "${slot}" = "" ]; then
					slot=$i
				else
					slot="${slot},$i"
				fi
			fi
		done 
	else
		#check if entered slot is installed in the system or not	
	        IFS=, SLOT_LIST="${slot}"
        	for i in ${SLOT_LIST[@]}; do
			scmfile=$(ls -dt /proc/neo/scm/s${i} | head -1)
                      	if [ "$scmfile" = "" ]; then
                                #scm not installed
                                printstr "Failed: Cannot find scm slot ${i}..." $logfile 1
				exit 1	
			else
				printstr "Found scm slot ${i}..." $logfile 1
                        fi
        	done
	fi

	#Prepare for A8 numbers
	if [ "${a8num}" = "" ]; then
		a8num="1,2,3,4,5,6,7,8"
	fi
}

function run_loadam
{
        mycmd="${loadamcmd} $1 $a8amffile"
	printstr "" $logfile 1
	printstr "#########Start testing slot $1..." $logfile 1
        printstr $mycmd $logfile 1
	myoutput=$($loadamcmd $1 $a8amffile > $tempfile)	
	myoutput=$(tail -n 1 /tmp/temp.txt | grep "Done" | wc -l)
	if [ "${myoutput}" = "1" ]; then
		printstr "Passed: a8amf file loaded successfully on slot $1..." $logfile 1
	else
		printstr "Failed: a8amf file failed to load on slot $1..." $logfile 1
		exit 1
	fi
}

function run_lae
{
	mycmd="$laecmd -s $1 -f $a8fwfile -a $2"
	printstr $mycmd $logfile 1 
	myoutput=$($laecmd -s $1 -f $a8fwfile -a $2 > $tempfile)
	myoutput=$(tail -n 1 /tmp/temp.txt | grep "failed" | wc -l)
	if [ "${myoutput}" = "1" ]; then
                printstr "Failed: A8 [$2] failed to boot..." $logfile 1
		result="A8(s) failed to boot"
        else
                printstr "Passed: A8 [$2] booted successfully..." $logfile 1
        fi
}

function run_fw_check
{
	IFS=, SLOT_LIST="${slot}"
	for i in ${SLOT_LIST[@]}; do
		run_loadam $i
		#Once loadam is loaded sucessfully, lae command can be executed
		IFS=, A8NUM_LIST="${a8num}"
		for n in ${A8NUM_LIST[@]}; do
			run_lae $i $n
		done	
	done
}

function print_results
{
	printstr "" $logfile 1
	if [ "$result" = "" ]; then
		printstr "Passed: All A8(s) loaded sucessfully..." $logfile 1
		exit 0
	else
		printstr "Failed: $result" $logfile 1
		exit 1
	fi
}


#########Main
#./loadam 1 a8amf_01_03_05_0D.bit
#this loadam binary does not come with the software.  Needs to manually copy into the system /dataflash
#this f8amf file is located under /usr/scm/fpga/a8amf*.bit

#How to load a8fw file
#lae -s 1 -f a8fw_0.150122.bin -a 6
# -s 1 = slot 1
# -f a8fw_*.bin
#this file is located under /usr/scm/fpga/s8fw_*.bin
# -a 6 = A8 #6

#Parse arguments
while [[ $# -ge 1 ]]
do
key="$1"
case $key in
    -x|--extension)
    a8amffile="$2"
    shift
    ;;
    -y|--searchpath)
    a8fwfile="$2"
    shift
    ;;
    -s|--lib)
    slot="$2"
    shift
    ;;
    -a|--lib)
    a8num="$2"
    shift
    ;;
    -h|--help)
    usage
    break
    ;;
    *)
    usage
            # unknown option
    ;;
esac
shift
done

check_files
check_scm_modules
echo $slot
echo $a8num
run_fw_check
print_results

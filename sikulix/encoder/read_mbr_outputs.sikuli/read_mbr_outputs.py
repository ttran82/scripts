#Read the first output of mbr group from ME7000 front-end
#This routine assume the main gui is alread launch and will click on Output Groups tab and read the output info
#inputs: optional: outputGroup=[1..] Output Group Number.  Default will be 1, the first output group
#inputs: optional: outputsInfoFile=[name of the file containing multicast output file]
#Usage: read_outputs.sikuli

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
import re
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for optional arguments
    if not Get_arg('outputGroup'):
        Set_arg('outputGroup', '1')
        Print_debug('outputGroup is not defined.  Will use 1 as default.')
    if not Get_arg('outputsInfoFile'):
        outputsInfoFile = os.getcwd() + '\\' + 'outputs.info'
        Set_arg('outputsInfoFile', outputsInfoFile)
        Print_debug('outputsInfoFile is not defined.  Will use default: ' + outputsInfoFile )
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

    
#Any definitions are here
def Read_Outputs():

    #first need to select Output group tabs
    Set_arg('tabName', 'Groups')
    Set_arg('tabSubName', 'mbr')
    RunSikuli('nav_tabs')

    #define region 
    findtext = find("Mux_bar-1.png").below(20).text()
    Print_debug('Raw read: ' + findtext)
    my_match = re.search(r'.+\((.+)\)', findtext)
    if not my_match:
        Exit_program('Failed to read multicast output.', 1)
    else:
        mydest = my_match.group(1).replace(' ', '')
        myaddr = re.search(r'(.+).(\d\d\d\d)', mydest) 
        if myaddr:
            my_udpip = myaddr.group(1)
            my_udpport = myaddr.group(2)
            Print_debug('Found multicast address: ' + my_udpip + ':' + my_udpport)
        else:
            Exit_program('Read multicast output seemed invalid: ' + my_match, 1)
    #Write outputs to file
    my_outputfile = Get_arg('outputsInfoFile')
    target = open(my_outputfile, 'w')
    target.write('udpIp=' + my_udpip + '\n')
    target.write('udpPort=' + my_udpport + '\n')
    target.close()

#######################################################
#Main program flow
Read_Outputs()
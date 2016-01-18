#Check if the current telnet session is running.  If not running, it is failed.
#input: getLogOnFailure = 0/1.  Default = 0
#input: fileList = list of files on remote machine separated by semicolon.  If copy the whole directory put -r in front of the path
#input: outputDir = which folder to copy the files to.  If only a name is given, it will put under current dir/name folder.  If empty, it will be current dir.
#Usage: check_telnet_6010.sikuli
#Usage: check_telnet_6010.sikuli getLogOnFailure=1 fileList="/var/log/messages;-r /usr/cp/lib/mibs" outputDir=Logs

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    Check_arg('encIp')
    if not Get_arg('getLogOnFailure'):
        Set_arg('getLogOnFailure', '0')
        Print_debug('getLogOnFailure is not defined.  Will use default: 0')

    if int(Get_arg('getLogOnFailure')) == 1:
        if not Get_arg('fileList'):
            Print_text('getLogOnFailure enabled, but fileList is empty', 1)
            
    if not Get_arg('outputDir'):
        mydir = os.getcwd()
        Set_arg('outputDir', mydir)
        Print_debug('outputDir is not defined.  Will use default: ' + mydir )
    
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here


#Any definitions are here
def Check_Telnet():
    telnetWinTitle = 'Telnet - ' + Get_arg('encIp')
    mycmd = 'auto_windows_manager.exe windows_title=\"' + telnetWinTitle + '\" windows_action=0'
    find_telnet = Run_cmd(mycmd)
    if int(find_telnet) == 0:
        Print_debug('Telnet 6010 session found.')
    else:
        if Get_arg('getLogOnFailure'):
            if int(Get_arg('getLogOnFailure')) == 1:
            mycmd = 'auto_pscp.exe fileList=\"' + Get_arg('fileList') + '\" outputDir=' + Get_arg('outputDir')   
            Print_debug('Getting log files from remote device')
        Print_text('Telnet 6010 session not found.  Core is restarted.', 1)

#######################################################
#Main program flow
Check_Telnet()

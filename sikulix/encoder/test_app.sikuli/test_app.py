#Run Navigate the Main menu 
#This script assume that the Java GUI is already running.
#inputs: encIP=[] encGuiLogin encGuiPassword encLogFile
#Usage: template.sikuli required_arg1=value1 required_arg2=value2 optional_arg3=value2 

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #If these arguments are not provided, script will terminate with error status
    Print_debug('Testing')
 
Check_args()            
###############################################################
#Main flow of your script
openApp('putty')
find("1437175473715.png")
click(Pattern("1437175473715.png").targetOffset(-25,4))
type("10.77.240.108"); type(Key.ENTER)

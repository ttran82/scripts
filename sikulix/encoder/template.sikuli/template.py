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
    """This function will always need to be run in the beginning to read in any command line arguments"""
    #If these arguments are not provided, script will terminate with error status
    Check_arg('required_arg1')
    Check_arg('required_arg2')

    #Assign default for optional arguments
    if not os.getenv('optinal_arg3'):
        Set_arg('optional_arg3', 'My default value')
 
Check_args()            
###############################################################
#Main program definitions
def my_func():
    '''This is your function where you get to do your actions'''

    my_var1 = Get_arg('required_arg1')
    my_var2 = Get_arg('required_arg2')
    my_var3 = Get_arg('optional_arg3')

    if my_var1 == my_var2:
        #Print text with timestamp
        Print_text('Pass. exit with zero.')
        #Same as Print_text but only when verbosity = 2 or greater
        Print_debug('var1 is equal to var2')
        exit(0)
    else:
        #Print text with timestamp
        Print_text('Failed.  exit with one.')
        #Same as Print_text but only when verbosity = 2 or greater
        Print_debug('var1 is not equal to var2')
        exit(1)

    if int(my_var3) < 0:
        Print_text('User entered invalid/erroed value.  exit with two.')
        #Same as Print_text but only when verbosity = 2 or greater
        Print_debug('Expecting var3 is a non-negative integer')
        exit(2)

    #if you need to run another sikuli script within this script
    #returnCode = runScript(sikuliScriptDir + 'sikuli script name without .sikuli extension')
    #then decide what to do base on the returnCode.
    
################################################################
#Main program flow
my_func()

#Apply groom changes from ME7000 front-end
#This routine assume only will detect the Discard and Apply button and react according to user option
#inputs: optional: changeAction=[Apply (default), Discard], waitTime=[in seconds, default = 30]
#Usage: apply_groom_changes.sikuli

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for optional arguments
    if not Get_arg('changeAction'):
        Set_arg('changeAction', 'Apply')
        Print_debug('changeAction is not defined.  Will use Apply as default.')
    if not Get_arg('waitTime'):
        Set_arg('waitTime', '30')
        Print_debug('waitTime is not defined.  Will use 30 as default.')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
    
#Any definitions are here
def Change_Action():
    find("Discard_Apply_buttons.png")
    hover("Discard_Apply_buttons.png")

    myaction = Get_arg('changeAction')
    if myaction == 'Apply':
        click(Pattern("Discard_Apply_buttons.png").targetOffset(37,1))
    elif myaction == 'Discard':
        click(Pattern("Discard_Apply_buttons.png").targetOffset(-31,1))
    else:
        Exit_program('Invalid changeAction enter not in range [Apply, Discard]: ' + myaction)
    if exists("1437554922325.png"): find("1437554942804.png"); click(Pattern("1437554942804.png").targetOffset(-34,3)); 
    my_time = int(Get_arg('waitTime'))
    wait("1437540468208.png",my_time)
    
    
#######################################################
#Main program flow
Change_Action()
#Apply or discard changes
#This routine assume the main screen is on and it's looking for Discard Apply changes
#inputs: changeAction = Apply (default)/Discard
#Usage: apply_changes.sikuli  changeAction=Discard

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    if not Get_arg('changeAction'):
        Set_arg('changeAction', 'Apply')
        Print_debug('changeAction is not defined.  Will use default: Apply.')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
#Any definitions are here
def Apply_Video_Changes():
    myaction = Get_arg('changeAction')
    if myaction == 'Apply':
        if exists("changes_icon-1.png") or exists("Discard_Apply_buttons.png"):
            Print_debug('There are changes to video page.  Apply needed.')     
            find("Discard_Apply_buttons.png")
            hover(Pattern("Discard_Apply_buttons.png").targetOffset(37,0))
            click(Pattern("Discard_Apply_buttons.png").targetOffset(37,1)); sleep(1)
            if exists("1437554922325.png"):
                find("1437554942804.png")
                click(Pattern("1437554942804.png").targetOffset(-34,3)); sleep(5)
        else:
             Print_text('Apply action is requested but changes are not detected on current page.')
             Capture_screen()
    elif myaction == 'Discard':
        find("Discard_Apply_buttons.png")
        hover(Pattern("Discard_Apply_buttons.png").targetOffset(-34,0))
        click(Pattern("Discard_Apply_buttons.png").targetOffset(-34,0)); sleep(1)
        Print_debug('Discard changes.')
    else:
        Print_text('Invalid changeAction no in (Apply, Discard): ' + myaction)
        
#######################################################
#Main program flow
Apply_Video_Changes()
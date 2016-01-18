#Groom SDI input port number to the very first output mux group
#This routine assume the main gui is alread launch and is currently in Process tab
#inputs: required: boardNum=<1..3> sdiPort=<1..8> programTarget=[Primary (default), Backup1, Backup2]
#inputs: resolution=[720x480p59.94...352x480p59.94]
#Usage: groom_sdi_input.sikuli  boardNum=<1..3> sdiPort=<1..8>
#Usage: groom_sdi_input.sikuli  boardNum=<1..3> sdiPort=<1..8> programTarget=Backup1 applyChanges=0

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
import re
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    Check_arg('boardNum')
    Check_arg('sdiPort')
    if not Get_arg('programTarget'):
        Set_arg('programTarget', 'Primary')
        Print_debug('programTarget is not defined.  Will use default: Primary.')
    Set_default_arg('applyChanges', '1')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

#Any definitions are here
my_boardnum = int(Get_arg('boardNum'))
def Nav_Board(boardnum):
    Main_gui(2)
    find("Processing_selected.png")
    #First reset everything to collapse tree
    find("1437545116814.png")
    click(Pattern("1437545116814.png").targetOffset(-1,-1)); sleep(1)
    click(Pattern("1437545116814.png").targetOffset(21,1)); sleep(1)
    #clicking on the correct board
    if boardnum == 1:
        find("1437467581935.png")
        click("1437467581935.png"); sleep(1)
    elif boardnum == 2:
        find("1437467683872.png")
        click("1437467683872.png"); sleep(1)
    elif boardnum == 3:
        find("1437467850488.png")
        click("1437467850488.png"); sleep(1)
    elif boardnum == 4:
        find("1437467898341.png")
        click("1437467898341.png"); sleep(1)
    else:
        Print_text('Invalid board range provided outside of (1..4): ' + my_boardnum)
        exit(1)

my_sdiport = int(Get_arg('sdiPort'))
def Groom_SDI_Port(sdiport):
    if sdiport == 1:
        find("1437468655400.png"); click("1437468655400.png"); sleep(1)
        dragDrop(Pattern("1SDI_selected.png").exact().targetOffset(0,37), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 2:
        find("1437468623934.png"); click("1437468623934.png"); sleep(1)
        dragDrop(Pattern("2SDI_selected.png").exact().targetOffset(0,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 3:
        find(Pattern("1437468574569.png").exact()); click(Pattern("1437468574569.png").exact()); sleep(1)
        dragDrop(Pattern("3SDI_selected.png").exact().targetOffset(0,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 4:
        find(Pattern("1437468708286.png").exact()); click(Pattern("1437468708286.png").exact()); sleep(1)
        dragDrop(Pattern("4SDI_selected.png").exact().targetOffset(0,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 5:
        find(Pattern("1437468839990.png").exact()); click(Pattern("1437468839990.png").exact()); sleep(1)
        dragDrop(Pattern("5SDI_selected.png").exact().targetOffset(0,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 6:
        find(Pattern("1437468869433.png").exact()); click(Pattern("1437468869433.png").exact()); sleep(1)
        dragDrop(Pattern("6SDI_selected.png").exact().targetOffset(0,37), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2) 
    elif sdiport == 7:
        find(Pattern("1437468893307.png").exact()); click(Pattern("1437468893307.png").exact()); sleep(1)
        dragDrop(Pattern("1437593359293.png").exact().targetOffset(-7,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2)
    elif sdiport == 8:
        find(Pattern("1437468934637.png").exact()); click(Pattern("1437468934637.png").exact()); sleep(1)
        dragDrop(Pattern("1437553918782.png").exact().targetOffset(-7,36), Pattern("1437553963025.png").targetOffset(-52,17)); sleep(2)
    else:
        Print_text('Invalid sdi port range provided outside of (1..8): ' + my_sdiport)

def Apply_Changes():
    myaction = Get_arg('applyChanges')
    if myaction:
        if myaction == '1':
            RunSikuli('apply_groom_changes')
    
#######################################################
#Main program flow
Nav_Board(my_boardnum)
Groom_SDI_Port(my_sdiport)
Apply_Changes()
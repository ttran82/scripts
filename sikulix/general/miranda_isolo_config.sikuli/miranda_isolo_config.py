#Change Miranda Isolo Control
#This script assume that the Java GUI is already running.
#inputs: slotNumber=[] videoStandard=sd/hd afdEnable=0/1 wssEnable=0/1 vliEnable=0/1  aspectRatio=[4:3, 16:9, Auto] afdValue=[2,3,4,8,9,10,11,13,14,15]
#afdValue is a little tricky  [2,3,4,8,9,10,11,13,14,15]
#afdValue: 4:3_2, 4:3_3, 4:3_4, 4:3_8, 4:3_9, 4:3_10, 4:3_11, 4:3_13, 4:3_14, 4:3_15
#afdValue: 16:9_2, 16:9_3, 16:9_4, 16:9_8, 16:9_9, 16:9_10, 16:9_11, 16:9_13, 16:9_14, 16:9_15
#Usage: miranda_isolo.sikuli afdEnable=1 wssEnable=0 vliEnable=0 aspectRatio=Auto afdValue=2

###############################################################
#common code for every sikuli code.  Do not remove this section
from commonlib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    if not Get_arg('slotNumber'):
        Set_arg('slotNumber', '7')
        Print_debug('Miranda slot number is not given.  Will use default 7')
    if not Get_arg('videoStandard'):
        Set_arg('videoStandard', 'sd')
        Print_debug('Video standard is not given.  Will use default sd')
        
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
my_slotnumber = Get_arg('slotNumber')
MirandaJavaTitle = 'XVP-3901 [ SLOT : ' + my_slotnumber + ']'
#Any definitions are here
def Select_AFD_Tab():
    mycmd = 'auto_windows_manager.exe windows_title=\"' + MirandaAFDTitle + '\" windows_action=-1'
    Print_debug(Run_cmd(mycmd))
    mycmd = 'auto_windows_manager.exe windows_title=\"' + MirandaJavaTitle + '\" windows_action=2'
    if int(Run_cmd(mycmd)) == 0: 
        find("XVP3901SLOT.png")
        #click on video outputs tab
        click(Pattern("XVP3901SLOT.png").targetOffset(5,69))
        wait("1437595593511.png")
        #click on AFD tab
        click(Pattern("1437595593511.png").targetOffset(295,224))
        wait("AFDInsertion_selection.png")
    else:
        Exit_program(MirandaJavaTitle + ' is not running.')

def Enable_AFD():
    if Get_arg('afdEnable'):
        afd_enable = Get_arg('afdEnable')
        #turn off AFD
        if int(afd_enable) == 0:
            find("AFDInsertion_selection.png")
            #check if AFD is already enable or not
            if exists(Pattern("1437595797239.png").exact()):
                Print_debug('AFD is already disabled.')
            if exists(Pattern("1437595901303.png").exact()):
                #now need to turn it off.
                click(Pattern("AFDInsertion_selection.png").targetOffset(-62,-1))
                wait(Pattern("1437595797239.png").exact())
                Print_debug('Disabling AFD')
        #turn on AFD
        elif int(afd_enable) == 1:
             find("AFDInsertion_selection.png")
             if exists(Pattern("1437595797239.png").exact()):
                 click(Pattern("AFDInsertion_selection.png").targetOffset(-61,-2))
                 wait(Pattern("1437595901303.png").exact())
                 Print_debug('Enabling AFD')
             if exists(Pattern("1437595901303.png").exact()):
                 Print_debug('AFD is already enabled.')
        else:
             Exit_program('Invalid afdEnable value 0/1: ' + afd_enable, 2)   

def Enable_VLI():
    if Get_arg('vliEnable'):
        vli_enable = Get_arg('vliEnable')
        #turn off VLI
        if int(vli_enable) == 0:
            find("1437595687470.png")
            #check if VLI is already enable or not
            if exists(Pattern("1437635731449.png").exact()):
                Print_debug('VLI is already disabled.')
            if exists(Pattern("1437635785595.png").exact()):
                #now need to turn it off.
                click(Pattern("AFDInsertion_VLI_Selection.png").targetOffset(-60,10))
                wait(Pattern("1437635731449.png").exact())
                Print_debug('Disabling VLI')
        #turn on VLI
        elif int(vli_enable) == 1:
             find(Pattern("AFDInsertion_VLI_Selection.png").targetOffset(-60,10))
             if exists(Pattern("1437635731449.png").exact()):
                 click(Pattern("AFDInsertion_VLI_Selection.png").targetOffset(-60,10))
                 wait(Pattern("1437635785595.png").exact())
                 Print_debug('Enabling VLI')
             if exists(Pattern("1437635785595.png").exact()):
                 Print_debug('VLI is already enabled.')
        else:
             Print_text('Invalid vliEnable value 0/1: ' + vli_enable)
             exit(2)

def Enable_WSS():
    if Get_arg('wssEnable'):
        wss_enable = Get_arg('wssEnable')
        #turn off WSS
        if int(wss_enable) == 0:
            find("1437595687470.png")
            #check if WSS is already enable or not
            if exists(Pattern("1437636688676.png").exact()):
                Print_debug('WSS is already disabled.')
            if exists(Pattern("1437636720691.png").exact()):
                #now need to turn it off.
                click(Pattern("1437595687470.png").exact().targetOffset(-23,21))
                wait(Pattern("1437636688676.png").exact())
                Print_debug('Disabling WSS')
        #turn on WSS
        elif int(wss_enable) == 1:
             find("1437595687470.png")
             if exists(Pattern("1437636688676.png").exact()):
                 click(Pattern("1437595687470.png").exact().targetOffset(-24,20))
                 wait(Pattern("1437636720691.png").exact())
                 Print_debug('Enabling WSS')
             if exists(Pattern("1437636688676.png").exact()):
                 Print_debug('WSS is already enabled.')
        else:
             Print_text('Invalid wssEnable value 0/1: ' + wss_enable)
             exit(2)

def Set_Aspect_Ratio():
    if Get_arg('aspectRatio'):
        aspectratio = Get_arg('aspectRatio')
        find("1437637523448.png")
        click(Pattern("1437637523448.png").targetOffset(85,0))
        find("1437637638039.png")
        if aspectratio == '4:3':
            click(Pattern("1437637638039.png").targetOffset(-29,47))
            wait(Pattern("1437638734838.png").exact())
        elif aspectratio == '16:9':
            click(Pattern("1437637638039.png").targetOffset(-30,67))
            wait(Pattern("1437638769870.png").exact())
        elif aspectratio == 'auto':
            click(Pattern("1437637638039.png").targetOffset(-27,76))
            wait(Pattern("1437638818974.png").exact())
        else:
            Print_text('Invalid aspect ratio specified from 4:3, 16:9, or auto: ' + aspectratio)
            exit(2)

MirandaAFDTitle = 'Select AFD'

def Set_AFD_Value():      
    if Get_arg('afdValue'): 
        find("1437597488360.png")
        click(Pattern("1437597488360.png").targetOffset(-17,21))
        wait("1437597544881.png", 10)
        mycmd = 'auto_windows_manager.exe windows_title=\"' + MirandaAFDTitle + '\" windows_action=2'
        Print_debug(Run_cmd(mycmd))

        videostandard = Get_arg('videoStandard')
        if videostandard == 'sd':
            afdvalue = Get_arg('afdValue')
            #split and find out if it is valid
            afdvalues = afdvalue.split('_')
            if len(afdvalues) < 2:
                Exit_program('Invalid afdValue entered. (must in the formst 4:3_x or 16:9_x): ' + afdvalue, 2)
            else:
                ar = afdvalues[0]
                afd = afdvalues[1]
                Print_debug('afd = ' + afd)
              
                if ar == '4:3':
                    if afd == '2':
                        find(Pattern("1437685293343.png").similar(0.90)); doubleClick(Pattern("1437685293343.png").similar(0.90).targetOffset(-143,-8))
                    elif afd == '3':
                        find(Pattern("1437683114104.png").similar(0.90)); doubleClick(Pattern("1437683114104.png").similar(0.90).targetOffset(-141,-16))
                    elif afd == '4':
                        find("1437683187125.png"); doubleClick(Pattern("1437683187125.png").targetOffset(-142,-11))
                    elif afd == '8':
                        find("1437683232422.png"); doubleClick(Pattern("1437683232422.png").targetOffset(-132,-13))
                    elif afd == '9':
                        find("1437683563445.png"); doubleClick(Pattern("1437683563445.png").targetOffset(-141,-14))
                    elif afd == '10':
                        find("1437683622613.png"); doubleClick(Pattern("1437683622613.png").targetOffset(-140,-8))
                    elif afd == '11':
                        find(Pattern("1437683682653.png").similar(0.90)); doubleClick(Pattern("1437683682653.png").similar(0.90).targetOffset(-135,-11))
                    elif afd == '13':
                        find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                        find(Pattern("1437686037047.png").exact()); doubleClick(Pattern("1437686037047.png").exact().targetOffset(-142,-16))
                    elif afd == '14':
                         find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                         find(Pattern("1437686152135.png").exact()); doubleClick(Pattern("1437686152135.png").exact().targetOffset(-141,-16))
                    elif afd == '15':
                         find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                         find(Pattern("1437686224162.png").exact()); doubleClick(Pattern("1437686224162.png").exact().targetOffset(-141,-11))
                    else:
                        Exit_program('Cannot find correct AFD value screen', 1, 1)
     
                elif ar == '16:9':
                    if afd == '2':
                        find(Pattern("1437685293343.png").similar(0.90)); doubleClick(Pattern("1437685293343.png").similar(0.90).targetOffset(96,-3))
                    elif afd == '3':
                        find(Pattern("1437683114104.png").similar(0.90)); doubleClick(Pattern("1437683114104.png").similar(0.90).targetOffset(80,-11))
                    elif afd == '4':
                        find("1437683187125.png"); doubleClick(Pattern("1437683187125.png").targetOffset(78,-8))
                    elif afd == '8':
                        find("1437683232422.png"); doubleClick(Pattern("1437683232422.png").targetOffset(90,-11))
                    elif afd == '9':
                        find("1437683563445.png"); doubleClick(Pattern("1437683563445.png").targetOffset(85,-11))
                    elif afd == '10':
                        find("1437683622613.png"); doubleClick(Pattern("1437683622613.png").targetOffset(79,-14))
                    elif afd == '11':
                        find(Pattern("1437683682653.png").similar(0.90)); doubleClick(Pattern("1437683682653.png").similar(0.90).targetOffset(85,-17))
                    elif afd == '13':
                        find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                        find(Pattern("1437686037047.png").exact()); doubleClick(Pattern("1437686037047.png").exact().targetOffset(84,-11))
                    elif afd == '14':
                         find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                         find(Pattern("1437686152135.png").exact()); doubleClick(Pattern("1437686152135.png").exact().targetOffset(80,-13))
                    elif afd == '15':
                         find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                         find(Pattern("1437686224162.png").exact()); doubleClick(Pattern("1437686224162.png").exact().targetOffset(85,-14))
                    else:
                        Exit_program('Cannot find correct AFD value screen', 1, 1)
                else:
                    Exit_program('Invalid afdValue entered. (must in the formst 4:3_x or 16:9_x): ' + afdvalue, 2)
        elif videostandard == 'hd':
            afdvalue = Get_arg('afdValue')
            if afdvalue == '16:9_2':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-3,64));
            elif afdvalue == '16:9_3':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-1,184));
            elif afdvalue == '16:9_4':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-5,305));
            elif afdvalue == '16:9_8':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-5,422));
            elif afdvalue == '16:9_9':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-4,541));
            elif afdvalue == '16:9_10':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-4,660));
            elif afdvalue == '16:9_11':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-4,780));
            elif afdvalue == '16:9_13':
                find("Miranda_AFD_Select_Header.png"); doubleClick(Pattern("Miranda_AFD_Select_Header.png").targetOffset(-4,900));
            elif afdvalue == '16:9_14':
                find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                find("Miranda_Select_OK_Cancel_Apply.png"); doubleClick(Pattern("Miranda_Select_OK_Cancel_Apply.png").targetOffset(-6,-207));
            elif afdvalue == '16:9_15':
                find("1437685926431.png"); click(Pattern("1437685926431.png").targetOffset(19,68))
                find("Miranda_Select_OK_Cancel_Apply.png"); doubleClick(Pattern("Miranda_Select_OK_Cancel_Apply.png").targetOffset(-8,-87));
            else:
                Exit_program('Invalid afdValue entered. (must in the format 16:9_x): ' + afdvalue, 2)            
        else:
            Exit_program('Invalid videoStandard entered.  (must be either sd/hd): ' + videostandard, 2)
        #closing any afd window
        mycmd = 'auto_windows_manager.exe windows_title=\"' + MirandaAFDTitle + '\" windows_action=-1'
        Print_debug(Run_cmd(mycmd))      
    
    

#######################################################
#Main program flow
Select_AFD_Tab()
Enable_AFD()
Enable_VLI()
Enable_WSS()
Set_Aspect_Ratio()
Set_AFD_Value()

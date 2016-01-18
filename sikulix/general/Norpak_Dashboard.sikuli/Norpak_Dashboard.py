#Launch Norpak Signal Generator Dashboard application with the option to load sd/hd metadata
#This script assume that the Java GUI is already running.
#"C:\Program Files (x86)\DashBoard\DashBoard.exe"
#inputs: norpakCmd=[] norpakMetaFile=[] norpakMetaDir=[] norpakWaitTime=[default=60]
#input: norpakMetaFile = [SD_MetaData.bin, HD_MetaData.bin, etc]
#input: videoFormat = [480i59.94 576i50 720p59.94 720p50 1080i59.94 1080i50]
#Usage: norpak_launcher.sikuli norpakCmd=[] norpakMetaFile=[] norpakMetaDir=
#Usage: norpak_dashboard.sikuli videoFormat=[] afdValue=[0..15 or 0..F]

###############################################################
#common code for every sikuli code.  Do not remove this section
from commonlib import *
import re
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    if Get_arg('norpakMetaFile'):
        my_metafile = Get_arg('norpakMetaFile')
        if not re.search(r'\\', my_metafile):
            if not Get_arg('norpakMetaDir'):
                my_metadir = getBundlePath()
                Set_arg('norpakMetaDir', my_metadir)             
            my_metafile = Get_arg('norpakMetaDir') + '\\' + my_metafile                
        if os.path.exists(my_metafile):
            Set_arg('norpakMetaFile', my_metafile)
        else:
            Exit_program(my_metafile + ' is not existed.', 2)
    if Get_arg('videoFormat'):
        Check_arg('afdValue')
    if not Get_arg('norpakWaitTime'):
        Set_arg('norpakWaitTime', '60')
        Print_debug('Dashboard software wait time is not given.  Will use default 60.')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
NorpakDashboardTitle = 'DashBoard'
my_waittime = Get_arg('norpakWaitTime')
start_from_fresh = False
#Any definitions are here
      
def Launch_Dashboard():
    '''Start Norpak Dashboard 
    '''   
    #First check if the app is already running
    mycmd = 'auto_windows_manager.exe windows_title=\"' + NorpakDashboardTitle + '\" windows_action=2'
    my_status = Run_cmd(mycmd)
    Print_debug(my_status)
    
    if int(my_status) == 0:
        Print_debug(NorpakDashboardTitle + ' is already running.  Use current session.')
    else:
        if Get_arg('norpakCmd'):
            my_app = openApp(Get_arg('norpakCmd'))
        else:            
            type(Key.ESC, KeyModifier.CTRL); sleep(1)
            wait("search.png")
            type('Dashboard');sleep(1); type(Key.ENTER)  
        global start_from_fresh
        start_from_fresh = True
        Print_debug('Waiting for Norpak Dashboard software to come up... ' + my_waittime)
        wait("DashBoard_title-2.png", int(my_waittime))
        mycmd = 'auto_windows_manager.exe windows_title=\"' + NorpakDashboardTitle + '\" windows_action=2'
        my_status = Run_cmd(mycmd)
        if int(my_status) == 0:
            Print_debug(NorpakDashboardTitle + ' launched successfully.')
        else:
            Exit_program(NorpakDashboardTitle + ' failed to launch successfully.')   
                
    wait("FrameSlollCM-100.png");click("FrameSlollCM-100.png")

    if not exists(Pattern("vertical_bar_2.png").similar(0.90)): find("vertical_bar_bottom.png"); dragDrop("vertical_bar_bottom.png", Pattern("left_corner.png").targetOffset(400,0))
    
    find("setup_tabs.png")
    click(Pattern("setup_tabs.png").targetOffset(170,1))
    find(Pattern("OutgoingService.png").similar(0.90)); click(Pattern("OutgoingService.png").similar(0.90))

    
    

    #if Get_arg('videoFormat'):
    #    Settings.OcrTextSearch=True
    #    Settings.OcrTextRead=True
    #    myformat = Get_arg('videoFormat')
    #    "Incomingvideo-1.png"
    #    mytext = find("1440483869681.png").right(80).text()
    #    if re.search(myformat, mytext):
    #        Print_debug('Video input matched expecting format: ' + myformat)
    #    else:
    #        Exit_program('Video input ' + mytext + ' did not matching expecting format ' + myformat, 2)

#launch the main Norpak Dashboard software
def Load_MetaFile():     
    if Get_arg('norpakMetaFile'):
        my_metafile = Get_arg('norpakMetaFile')
        find(Pattern("RefreshUnloapReboot_buttons.png").exact()); click(Pattern("RefreshUnloapReboot_buttons.png").exact())
        wait("Open_window.png"); click(Pattern("Filename.png").similar(0.90).targetOffset(165,-13)); type("a", KEY_CTRL); type(my_metafile); type(Key.ENTER)
        wait("Confirm_upload_window.png"); click(Pattern("Continuecancel.png").targetOffset(-38,-1)); waitVanish("Uploadingfile_window.png")

def Set_AFD_Value():
    if Get_arg('afdValue'):
        
        videoformat = Get_arg('videoFormat')
        videotarget = ''
        scanrate = ''
        if videoformat == '480i59.94': 
            videotarget=("480i59.94-1.png")
            scanrate = 'interlaced'
        elif videoformat == '576i50': 
            videotarget=(Pattern("576i50.png").exact())
            scanrate = 'interlaced'
        elif videoformat == '1080i59.94':
            videotarget=(Pattern("1080i59.94.png").exact())
            scanrate = 'interlaced'
        elif videoformat == '1080i50':
            videotarget=(Pattern("1080i50.png").exact())
            scanrate = 'interlaced'
        elif videoformat == '720p59.94':
            videotarget=(Pattern("720p5994.png").exact())
            scanrate = 'progressive'
        elif videoformat == '720p50':
            videotarget=(Pattern("720p50.png").exact())
            scanrate = 'progressive'
        else:
            Exit_program('Invalid video format entered: ' + videoformat, 2)

        if start_from_fresh:
            click(Pattern(videotarget).exact().targetOffset(213,0))
            find("arrow_up_2.png")
            click(Pattern(videotarget).exact().targetOffset(128,55))
            #find("arrow_up_2-1.png"); dragDrop(Pattern("middle_bar-2.png").exact(),Pattern("down_arrow_2-1.png").exact()); dragDrop(Pattern("middle_bar-2.png").exact(),Pattern("arrow_up_2-1.png").exact())
            #click(Pattern("default-3.png").exact().targetOffset(128,35))
            click(Pattern("EncodeServer_start.png").similar(0.90).targetOffset(49,-1))

        #click dropdown menu and move bar all the way to the top)
        click(Pattern(videotarget).exact().targetOffset(213,0))

        find("arrow_up_2.png")
        dragDrop(Pattern("middle_bar-1.png").exact(),Pattern("arrow_up_2.png").exact())
        
        afdvalue = Get_arg('afdValue')
        afdtarget = ''

        if scanrate == 'interlaced':
            if afdvalue == '0':
                click(Pattern(videotarget).exact().targetOffset(128,55))
            elif afdvalue == '1':
                click(Pattern(videotarget).exact().targetOffset(128,75))
            elif afdvalue == '2':
                click(Pattern(videotarget).exact().targetOffset(128,95))
            elif afdvalue == '3':
                click(Pattern(videotarget).exact().targetOffset(128,115))
            elif afdvalue == '4':
                click(Pattern(videotarget).exact().targetOffset(128,135))
            elif afdvalue == '5':
                click(Pattern(videotarget).exact().targetOffset(128,155))
            elif afdvalue == '6':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,35))
            elif afdvalue == '7':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,55))
            elif afdvalue == '8':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,75))
            elif afdvalue == '9':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,95))
            elif afdvalue == '10' or afdvalue == 'A':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,115))
            elif afdvalue == '11' or afdvalue == 'B':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,135))
            elif afdvalue == '12' or afdvalue == 'C':
                click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,155))
            elif afdvalue == '13' or afdvalue == 'D':
                click("arrow_down-1.png");click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,35))
            elif afdvalue == '14' or afdvalue == 'E':
                click("arrow_down-1.png");click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,55))
            elif afdvalue == '15' or afdvalue == 'F':
                click("arrow_down-1.png");click("arrow_down-1.png");click(Pattern(videotarget).exact().targetOffset(128,75))
            else:
                Exit_program('Invalid afdValue entered not in range [0..15]: ' + afdvalue)
        elif scanrate == 'progressive':
            if afdvalue == '0':
                click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,95))
            elif afdvalue == '1':
                click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,115))
            elif afdvalue == '2':
                click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,135))
            elif afdvalue == '3':
                click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,155))
            elif afdvalue == '4':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,35))
            elif afdvalue == '5':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,55))
            elif afdvalue == '6':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,75))
            elif afdvalue == '7':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,95))
            elif afdvalue == '8':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,115))
            elif afdvalue == '9':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,135))
            elif afdvalue == '10' or afdvalue == 'A':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,155))
            elif afdvalue == '11' or afdvalue == 'B':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,75))
            elif afdvalue == '12' or afdvalue == 'C':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,95))
            elif afdvalue == '13' or afdvalue == 'D':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,115))
            elif afdvalue == '14' or afdvalue == 'E':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,135))
            elif afdvalue == '15' or afdvalue == 'F':
                click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");click("arrow_down-1.png");sleep(1);click(Pattern(videotarget).exact().targetOffset(128,155))
            else:
                Exit_program('Invalid afdValue entered not in range [0..15]: ' + afdvalue)
        else:
            Exit_program('Wrong scanrate: ' + scanrate)

        click(Pattern("EncodeServer_start.png").similar(0.90).targetOffset(49,-1))
        if find("Cardstate.png"):
            Print_debug('Set AFD value successfully.')
        else:
            Exit_program('Set AFD value faild.  Card is in bad state.')

            

#######################################################
#Main program flow
Launch_Dashboard()
Load_MetaFile()
Set_AFD_Value()
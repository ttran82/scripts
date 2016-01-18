#Create mbr group
#This script will navigate to Group tab and start creating an mbr group
#This script assume that the Java GUI is already running.
#inputs: mbrGroupName=[] selectConfigFile=[] selectLine=[] channelName=[] destinationIp=[] destinationPort=[] totalRate
#    mbrGroupName=[default=MBR_Group_1]
#    selectConfigFile = [default=SPTS_ATSC_ENCODER, SPTS_DVB_ENCODER, SPTS_PROXY_ENCODER]
#    selectLine = [4/1 - 4/9] currently does not support ethernet on different board
#    channelName = [default=CH1]
#    destinationIp=[default = 236.x.x.x from selectLine]
#    destinationPort=[default = 8433]
#    totalRate=[default=5.0]
#    mbrInfoOutput=[name of the file containing information about the created mbr group]
#Usage: create_mbr_group.sikuli selectLine=[] #default will create MBR_Group_1 with Ch1 @ 5Mbps with output 236.x.x.x:8433

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
    Check_arg('selectLine')
    Set_default_arg('mbrGroupName', 'MBR_Group_1')
    Set_default_arg('selectConfigFile', 'SPTS_ATSC_ENCODER')
    Set_default_arg('channelName', 'CH1')
    Set_default_arg('destinationIp', '236.x.x.x')
    Set_default_arg('destinationPort', '8433')
    Set_default_arg('totalRate', '5.0')
    Set_default_arg('mbrInfoOutput', os.getcwd() + '\\' + 'mbr_outputs.info')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

#Any definitions are here
def Create_MBR_Group():
    #First need to navigate to the right tab
    #auto_sikuli.exe sikuliScriptName=nav_tabs.sikuli tabName=Groups tabSubname=mbr
    Set_arg('tabName', 'Groups')
    Set_arg('tabSubName', 'mbr')
    RunSikuli('nav_tabs')

    #Create MBR Group if it is empty
    if exists("empty_mbr_groups.png"):
        find("CreateNewMBRGroup_button.png"); click("CreateNewMBRGroup_button.png"); wait("CreateOutputMuxes_windows.png")
        #Entering mbrGroupName
        mygroupname = Get_arg('mbrGroupName')
        click("AddGroup_button.png"); wait("SelectCongFile_selection.png")
        #Group name is not edited in build5
        #type(mygroupname); click(Pattern("MBRGroupName_label-1.png").targetOffset(188,2))
        #Select Config file
        myconfigfile = Get_arg('selectConfigFile')
        find("SelectCongFile_selection.png"); doubleClick("SelectCongFile_selection.png")
        if myconfigfile.upper() == 'SPTS_ATSC_ENCODER': click("SPTS_ATSC_ENCODER_Config.png")
        elif myconfigfile.upper() == 'SPTS_DVB_ENCODER': click("SPTS_DVB_ENCODER_Config.png")
        elif myconfigfile.upper() == 'SPTS_PROXY_ENCODER': click("SPTS_PROXY_ENCODER_Config.png") 
        else: Exit_program('Invalid selectConfigFile entered: ' + myconfigfile, 2)
        #Select line
        myline = Get_arg('selectLine')
        find("Line_selection.png"); doubleClick(Pattern("Line_selection.png").targetOffset(0,30))
        if myline == '4/3': click(Pattern("43_line.png").similar(0.80))
        elif myline == '4/4': click(Pattern("44_line.png").similar(0.80))
        elif myline == '4/5': click(Pattern("45_line.png").similar(0.80))
        elif myline == '4/6': click(Pattern("46_line.png").similar(0.80))
        elif myline == '4/7': click(Pattern("47_line.png").similar(0.80))
        elif myline == '4/8': click(Pattern("48_line.png").similar(0.80))
        elif myline == '4/9': click(Pattern("49_line.png").similar(0.80))
        elif myline == '4/10': click(Pattern("410_line.png").similar(0.80))
        else: Exit_program('Invalid selectLine entered: ' + myline, 2)
        #Entering channel name
        mych = Get_arg('channelName')
        find(Pattern("Name_selection.png").similar(0.80)); doubleClick(Pattern("Name_selection.png").similar(0.80).targetOffset(0,30)); doubleClick(Pattern("Name_selection.png").similar(0.80).targetOffset(0,30)); type(mych); type(Key.ENTER)
        #Entering destination ip
        #First find out what is the ip of the current ethernet line
        findtext = find("Line_selection_long-1.png").below(40).text()
        my_match = re.search(r'.+\((.+)\)', findtext)
        if not my_match:
            Exit_program('Failed to read ethernet line.', 1)
        else:
            myeth = my_match.group(1).replace(' ', '')
            Print_debug('Found ethernet line address: ' + myeth )
            #extracting the octets
            myoctets = myeth.split('.')
            if len(myoctets) != 4: Exit_program('Ethernet line is read wrong.')
        #Second, get destination address
        mydest = Get_arg('destinationIp')
        destoctets = mydest.split('.')
        if len(destoctets) != 4: Exit_program('destinationIp is not valid: ' + mydest)
        if not (int(destoctets[0]) < 255 and int(destoctets[0]) > 224): Exit_program('Invalid destinationIp range is entered: ' + mydest)
        for i in xrange(1, len(destoctets)):
            destoctets[i] = destoctets[i].replace('x', myoctets[i])
        mydest = destoctets[0]+ '.' + destoctets[1] + '.' + destoctets[2] + '.' + destoctets[3]
        Print_debug('Final destinationIp: ' + mydest)
        find("DestinationIp_selection.png"); doubleClick(Pattern("DestinationIp_selection.png").targetOffset(-60,30)); doubleClick(Pattern("DestinationIp_selection.png").targetOffset(-60,30)); type(mydest); type(Key.ENTER)
        #Entering destination port
        myport = Get_arg('destinationPort')
        find("UDPPort_selection.png"); doubleClick(Pattern("UDPPort_selection.png").targetOffset(0,30)); type(myport); type(Key.ENTER)
        #Entering total rate
        myrate = Get_arg('totalRate')
        find("TotalRate_selection.png"); doubleClick(Pattern("TotalRate_selection.png").targetOffset(0,30)); doubleClick(Pattern("TotalRate_selection.png").targetOffset(0,30)); type(myrate); type(Key.ENTER)
        #Apply changes
        find("mbr_ok_cancel_buttons.png"); click(Pattern("mbr_ok_cancel_buttons.png").targetOffset(-36,3))
        if exists("mbr_warning.png"):
            Capture_screen()
            find(Pattern("warning_ok_button.png").similar(0.80)); click(Pattern("warning_ok_button.png").similar(0.80))
            find("mbr_ok_cancel_buttons.png"); click(Pattern("mbr_ok_cancel_buttons.png").targetOffset(39,1))
            Exit_program('Failed to create MBR Group: ' + mygroupname)
        else:
            Print_debug('MBR Group created successfully: ' + mygroupname)
            #Creating mbr_outputs.info file
            mbrfile = Get_arg('mbrInfoOutput')
            target = open(mbrfile, 'w')
            target.write('mbrGroupName=' + mygroupname + '\n')
            target.write('destinationIp=' + mydest + '\n')
            target.write('destinationPort=' + myport + '\n')
            target.close()
            
        
    

            
        
#######################################################
#Main program flow
Create_MBR_Group()


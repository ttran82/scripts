#Run Navigate the tab menu 
#This script assume that the Java GUI is already running.
#inputs: tabName=<> tabSubName=[] tabSubNameItem=[]
#    tabName = Setup, Mux, Output Groups, Processing, Alarms, Analysis, Thumbnails
#    tabSubName = Setup->System, Redundancy, Files, SNMP
#                 Mux-> no subtabs
#                 Groups-> no subtabs
#                 Processing-> no subtabs
#                     processingView->map, statmux, mbr
#                 Alarms->Alarms, Settings
#                 Analysis-> no subtabs
#                 Thumbnails-> no subtabs
#    tabSubNameItem = Setup->System->Device, Network, Software Update
#                     Setup->Rundundancy->no subtabs
#                     Setup->Files->no subtabs
#                     Setup->SNMP->no subtabs
#
#                     Alarms->Alarms->no subtabs
#                     Alarms->Settings->no subtabs
#
#Usage: nav_menu.sikuli tabName=<> tabSubName=[] tabSubNameItem=[]
#Usage: nav_menu.sikuli tabName=Setup tabSubName=System tabSubNameItem=Device

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    Check_arg('tabName')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
    
#Any definitions are here
def Nav_Tabs():
    Main_gui(2)
    my_tab = Get_arg('tabName')
    my_subtab = Get_arg('tabSubName')     
    my_subtabitem = Get_arg('tabSubNameItem')
    
    wait("1437001195717.png") 
    if find("1437001195717.png"):
        #found main menu
        #This is for Setup tab
        if my_tab.lower() == 'setup':
            Print_debug('Selecting Setup tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); wait("Setup_selected.png")
            #Now walks thru the Sub tabs 
            if my_subtab:
                if my_subtab == 'System':
                    click(Pattern("Setup_selected-1.png").targetOffset(22,26)); wait("Setup_System_selected-2.png")
                    if my_subtabitem:
                        if my_subtabitem == 'Device':
                            click(Pattern("Setup_System_selected-2.png").targetOffset(-2,186)); wait("Device_selected-2.png")
                        elif my_subtabitem == 'Network':
                            click(Pattern("Setup_System_selected-2.png").targetOffset(-2,186)); click(Pattern("Network_select-1.png").similar(0.80)); wait("Network_selected-1.png")
                        elif my_subtabitem == 'Software Update':
                            click(Pattern("Setup_System_selected-2.png").targetOffset(-2,186)); click(Pattern("SoftwareUpdate_select-1.png").similar(0.80)); wait("SoftwareUpdate_selected-1.png")
                        else: Exit_program('Invalid sub tab item: ' + str(my_subtabitem), 2)
                elif my_subtab == 'Redundancy': 
                    click(Pattern("Setup_selected-1.png").targetOffset(22,26)); click("Redundancy_select-1.png"); wait("Redundancy_selected-1.png")
                elif my_subtab == 'Files':
                    click(Pattern("Setup_selected-1.png").targetOffset(22,26)); click(Pattern("Files_select-1.png").similar(0.80)); wait("Files_selected-1.png")
                elif my_subtab == 'SNMP':
                    click(Pattern("Setup_selected-1.png").targetOffset(22,26)); click(Pattern("SNMP_select-1.png").similar(0.80)); wait("SNMP_selected-1.png")
                else: 
                    Exit_program('Invalid Setup sub tab: ' + str(my_subtab), 2)
        #This is for Mux tab
        elif my_tab.lower() == 'mux': 
            Print_debug('Selecting Mux tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click(Pattern("Mux_select.png").similar(0.80)); wait("Mux_selected.png"); find(Pattern("min_max.png").similar(0.80)); click(Pattern("min_max.png").similar(0.80).targetOffset(8,0)); click(Pattern("min_max.png").similar(0.80).targetOffset(-14,1))
            #check if the vertical bar is in correct position
            if not exists(Pattern("Processing_Alarm_vertical_bar.png").exact()): find(Pattern("min_max.png").similar(0.80).targetOffset(-14,1)); dragDrop(Pattern("min_max.png").similar(0.80).targetOffset(24,5), Pattern("1437001195717.png").targetOffset(307,50))
        #This is for Output Groups tab
        elif my_tab.lower() == 'groups':
            Print_debug('Selecting Groups tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click("Groups_select.png"); wait("Groups_selected.png"); find(Pattern("min_max.png").similar(0.80)); click(Pattern("min_max.png").similar(0.80).targetOffset(8,0)); click(Pattern("min_max.png").similar(0.80).targetOffset(-14,1))
            if not exists(Pattern("ProcessingLB.png").similar(0.90)): find(Pattern("min_max.png").targetOffset(-14,1)); dragDrop(Pattern("min_max.png").targetOffset(24,5), Pattern("1437001195717.png").targetOffset(307,50))
            if my_subtab:
                if my_subtab.upper() == 'OUTPUT': click(Pattern("1437001195717.png").targetOffset(-46,62)); wait("OUTPUT_selected.png")
                elif my_subtab.upper() == 'MBR': click(Pattern("1437001195717.png").targetOffset(-46,62)); click("MBR_select.png"); wait("MBR_selected.png")
                else: Exit_program('Invalid Groups sub tab: ' + my_subtab, 2)                       
        #This is for Processing tab
        elif my_tab.lower() == 'processing':
            Print_debug('Selecting Processing tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click("Process_select.png"); wait("Processing_selected.png"); find(Pattern("min_max.png").similar(0.80)); click(Pattern("min_max.png").similar(0.80).targetOffset(8,0)); click(Pattern("min_max.png").similar(0.80).targetOffset(-14,1))
            #check if the vertical bar is in correct position
            if not exists(Pattern("Processing_Alarm_fromProcessing.png").similar(0.90)): find(Pattern("min_max.png").targetOffset(-14,1)); dragDrop(Pattern("min_max.png").targetOffset(24,5), Pattern("1437001195717.png").targetOffset(307,50))
            myview = Get_arg('processingView')
            if myview:
                find(Pattern("View_under_process.png").similar(0.80))
                if myview.lower() == 'map': click(Pattern("View_under_process.png").similar(0.80).targetOffset(123,3)); click(Pattern("View_under_process.png").similar(0.80).targetOffset(70,20))
                elif myview.lower() == 'statmux': click(Pattern("View_under_process.png").similar(0.80).targetOffset(123,3)); click(Pattern("View_under_process.png").similar(0.80).targetOffset(70,32)) 
                elif myview.lower() == 'mbr': click(Pattern("View_under_process.png").similar(0.80).targetOffset(123,3)); click(Pattern("View_under_process.png").similar(0.80).targetOffset(70,50))
                else: Exit_program('Invalid processingView: ' + myview, 2)      
        elif my_tab == 'Alarms':
            Print_debug('Selecting Alarms tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click("Alarms_select.png"); wait(Pattern("Alarms_selected-1.png").similar(0.80))
            #Now walks thru the sub tabs
            if my_subtab:
                if my_subtab == 'Alarms': 
                    click(Pattern("Alarms_selected-1.png").similar(0.80).targetOffset(-402,33)); wait("AlarmsSettings.png")
                    if not exists(Pattern("Alarm_vertical-1.png").exact()): find("StateSeverity_vertoca;.png"); dragDrop(Pattern("StateSeverity_vertoca;.png").targetOffset(-73,2), Pattern("1437001195717.png").targetOffset(271,80))
                elif my_subtab == 'Settings':
                    click(Pattern("Alarms_selected-1.png").similar(0.80).targetOffset(-402,33)); click(Pattern("AlarmsSettings.png").targetOffset(34,0)); wait(Pattern("AlarmsSettings-1.png").similar(0.80))
                else:
                    Exit_program('Invalid Alarm sub tab: ' + my_subtab, 2)
        elif my_tab == 'Analysis':
            Print_debug('Selecting Analysis tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click("Analysis_select.png"); wait("Analysis_selected.png")
        elif my_tab == 'Thumbnails':
            Print_debug('Selecting Thumbnails tab')
            click(Pattern("1437001195717.png").targetOffset(-37,37)); click("Thumbnail_select.png"); wait("Thumbnails_selected.png")
        else:
            Print_text('Invalid tab name: ' + my_tab)
            exit(1)
    #wrong menu name    
    else:
        Exit_program('Failed to look for main gui page.', 1, 1)

#######################################################
#Main program flow
Nav_Tabs()


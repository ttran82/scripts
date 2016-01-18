#This script assume that the Java GUI is already running.
#This script will select Mux tab and proceed to create an udp input mux
#Input: boardNum = [1..4]
#Input: portNum = [1..10]
#Input: muxAction = [delete create]
#Input: muxName = [InputMux001 .. InputMux100]
#Input: muxAddr = [x.x.x.x], muxPort = [xxxx]
#Input: portIncrement = 1/0, will enable when set 
#Input: octetIncrement = 1/0, will enable when set
#Input: bulkNum = [1..20]
#Input: muxActiveCheck = If set, will check if input mux is active or not
#Usage: manage_input_mux.sikuli boardNum=4 portNum=7 muxAction=Create muxName=InputMux1 muxAddr=2xx.xxx.xx.x muxPort=xxxx muxActiveCheck=1
#Usage: manage_input_mux.sikuli muxAction=delete muxName=InputMux1

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    Check_arg('boardNum')
    Check_arg('portNum')
    Check_arg('muxName') 
    if not Get_arg('muxAction'):
        Set_arg('muxAction', 'delete')
        Print_debug('muxAction is not defined.  Will use create as default.')
    if Get_arg('muxAction').lower() == 'create':
        Check_arg('muxAddr')
        Check_arg('muxPort')

Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
my_board = Get_arg('boardNum')     
my_port = Get_arg('portNum')
eth_port = my_board.lower() + '/' + my_port.lower()

inputmuxNameDict = {
    'InputMux001':"InputMux001_label.png", 'InputMux002':"lnputMux002_select.png", 'InputMux003':"nputMux003_select.png", 'InputMux004':"nputMux004_select.png", 'InputMux005':"InputMux005_select.png",
    'InputMux006':"InputMux006_select.png", 'InputMux007':"InputMux007_select.png", 'InputMux008':"InputMux008_select.png", 'InputMux009':"InputMux009_select.png", 'InputMux010':"InputMux010_select.png",
    'InputMux_1':"lnputMux_1_selected-1.png", 'InputMux_2':"InputMux2_selected.png", 'InputMux_3':"InputMux3_selected.png", 'InputMux_4':"InputMux4_selected.png", 'InputMux_5':Pattern("InputMux5_selected.png").exact(),
    'InputMux_6':"InputMux6_selected.png", 'InputMux_7':"InputMux7_selected.png", 'InputMux_8':"InputMux8_selected.png", 'InputMux_9':"lnputMux_9_selected.png", 'InputMux_10':"lnputMux_10_selected.png"
    }

#Any definitions are here
def Verify_Mux_Status():
    pass

def Create_Input_Mux():
    #first select the Mux tab and select the right port       
    Set_arg('tabName', 'Mux')
    Set_arg('portClick', '2')
    RunSikuli('nav_tabs')
    #Now create the input mux
    find("create_input_icons.png"); click(Pattern("create_input_icons.png").targetOffset(-34,1)); wait("CreateInputMux_window.png")
    #Enter muxName
    muxname = Get_arg('muxName')
    find("MuxName_label.png"); doubleClick(Pattern("MuxName_label.png").targetOffset(80,0)); type(muxname)
    #Enter multicast adress
    muxaddr = Get_arg('muxAddr')
    find("IPAddress_label.png"); doubleClick(Pattern("IPAddress_label.png").targetOffset(40,0)); type(muxaddr)
    #Enter multicast port
    muxport = Get_arg('muxPort')
    find("UDPPort_label.png"); doubleClick(Pattern("UDPPort_label.png").targetOffset(40,0)); type(muxport)
    if Get_arg('portIncrement'): 
        find("PortInaement_checkbox.png"); click(Pattern("PortInaement_checkbox.png").targetOffset(-40,0))
        bulknum = Get_arg('bulkNum')
        if bulknum: find("NumberofMux_label.png"); doubleClick(Pattern("NumberofMux_label.png").targetOffset(60,0)); type(bulknum)
    if Get_arg('octetIncrement'): 
        find("LastOctetInc_checkbox.png"); click(Pattern("LastOctetInc_checkbox.png").targetOffset(-53,0))
        bulknum = Get_arg('bulkNum')
        if bulknum: find("NumberofMux_label.png"); doubleClick(Pattern("NumberofMux_label.png").targetOffset(60,0)); type(bulknum)
    #Hit enter
    find("inputmux_ok_cancel_buttons.png"); click(Pattern("inputmux_ok_cancel_buttons.png").targetOffset(-35,0))
    if exists("ErrorCreatingMux_window.png"): Capture_screen(); Exit_program('Error creating mux: ' + muxname, 1, 1)
    if exists("create_mux_Warning.png"): Capture_screen(); click("warning_ok_button.png"); click(Pattern("inputmux_ok_cancel_buttons.png").targetOffset(40,0)); Exit_program('Error creating mux: ' + muxname, 1)
    Print_debug('Mux created successfully: ' + muxname)

def Delete_input_mux():
    Nav_Port('double')
    
    

def Manage_input_mux():
    my_action = Get_arg('muxAction')
    if my_action.lower() == 'create':
        Create_input_mux()
    elif my_action.lower() == 'delete':
        Delete_input_mux()
    else:
        Exit_program('Invalid muxAction entered: ' + my_action, 2)

#######################################################
#Main program flow
Nav_Port()
Create_Input_Mux()



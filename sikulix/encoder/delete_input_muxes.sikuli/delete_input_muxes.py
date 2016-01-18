#This script assume that the Java GUI is already running.
#This script is meant to run after nav_ports assuming the right boards and port is already select
#This script will run delete the input mux base on muxName
#Input: muxName = [InputMux001 .. InputMux100] If muxName is not given, it will delete the first input mux in the list
#Input: muxPosition = [1..] will delete the input mux base on its position on the list.  If set to all, it will delete all input muxes
#Usage: delete_input_mux.sikuli muxName=InputMux1 muxAddr=2xx.xxx.xx.x muxPort=xxxx bulkNum=10 octetIncrement=1

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    pass

Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here  
mymux = Get_arg('muxName')
mypos = Get_arg('muxPosition')

inputmuxNameDict = {
    'InputMux001':"nputMux0O1_selected-1.png", 'InputMux002':"InputMux0O2_selected-1.png", 'InputMux003':"lnputMuxOO3_selected.png", 'InputMux004':"lnputMuxOO4_selected.png", 'InputMux005':"nputMux005_selected.png",
    'InputMux006':"nputMux006_selected-1.png", 'InputMux007':"nputMux0O7_selected.png", 'InputMux008':"noutMux0O8_selected.png", 'InputMux009':"nputMux0O9_selected.png", 'InputMux010':"nputMux010_selected.png",
    'InputMux_1':"lnputMux_1_selected-1.png", 'InputMux_2':"InputMux2_selected.png", 'InputMux_3':"InputMux3_selected.png", 'InputMux_4':"InputMux4_selected.png", 'InputMux_5':"InputMux5_selected.png",
    'InputMux_6':"InputMux6_selected.png", 'InputMux_7':"InputMux7_selected.png", 'InputMux_8':"InputMux8_selected.png", 'InputMux_9':"lnputMux_9_selected.png", 'InputMux_10':"lnputMux_10_selected.png"
    }

def Delete_By_Name():
    if mymux:
        find("Input_mux_list_header.png")
        if inputmuxNameDict.has_key(mymux):   
            mymuximage = inputmuxNameDict.get(mymux)
            if exists(Pattern(mymuximage).exact()):
                rightClick(Pattern(mymuximage).exact()); wait("DeleteDelete_popup.png"); click(Pattern("DeleteDelete_popup.png").targetOffset(-36,-13))
                #Now apply
                if exists("mbr_warning.png"): find("delete_yes_no.png"); click(Pattern("delete_yes_no.png").targetOffset(-25,0))
                RunSikuli(apply_changes)
                
            else:
                Exit_program('muxName not found: ' + mymux, 2)
        else:
            Exit_program('Invalid muxName entered: ' + mymux, 2)


#######################################################
#Main program flow
Delete_By_Name()



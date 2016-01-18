#Run Navigate ports from tabs: Mux, Groups, Processing;
#Will support all boards it is XCD (Main) or ENC (SDI) 
#This script assume that the Java GUI is already running.
#Input: boardNum = [1..4]
#Input: portNum = [1..10]
#Input: ethPortType = [in, out]
#Input: portClick = [1..2] 1 = single click, 2 = double click
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
    Check_arg('tabName')
    Check_arg('boardNum')
    Check_arg('portNum')
    if not Get_arg('portClick'):
        Set_arg('portClick', '1')
        Print_debug('portClick is not defined.  Will use 1 as default.')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
my_tab = Get_arg('tabName')
my_board = Get_arg('boardNum')     
my_port = Get_arg('portNum')

clicktype = Get_arg('portClick')
eth_port = my_board.lower() + '/' + my_port.lower()

ethPortDict = {
    '4/1':"eth_4.1_select.png", '4/2':"eth_4.2_select.png", '4/3':"eth_4.3_select-1.png", '4/4':"eth_4.4_select.png", '4/5':"eth_4.5_select.png", '4/6':"eth_4.6_select.png", '4/7':"eth_4.7_select.png", '4/8':"eth_4.8_select.png", '4/9':"eth_4.9_select.png", '4/10':Pattern("eth_4.10_select.png").targetOffset(0,-8)
    }

boardDict = {
    '1': "board1_select.png", '2':"1437467683872-1.png", '3':"1437467850488-1.png", '4':"Board4_select.png"
    }

boardSelectedDict = {
    '1': "board1_selected.png", '2':"board2_selected.png", '3':"board3_selected.png", '4':"Board4_selected.png"
    }

#Any definitions are here
def Nav_Boards():
    Set_arg('tabName', my_tab)
    RunSikuli('nav_tabs')
    if exists(Pattern("me_indicator_1-1.png").exact()): doubleClick(Pattern("me_indicator_1-1.png").exact()); wait("allboards.png")
    if boardDict.has_key(my_board):
        #select board
        myboardimg = boardDict.get(my_board)
        find(Pattern(myboardimg).exact()); click(Pattern(myboardimg).exact())
        myselectedimg = boardSelectedDict.get(my_board)
        wait(Pattern(myselectedimg).exact())
        if my_tab.lower() == 'mux' or my_tab.lower() == 'processing':
            doubleClick(Pattern(myselectedimg).exact())
    else:
        Exit_program('Invalid board range provided outside of (1..4): ' + my_board, 2)
        
def Nav_Ports():
    if my_tab.lower() == 'mux':
        #select port
        if ethPortDict.has_key(eth_port):
            #find and click on the correct port
            Check_arg('ethPortType')
            my_eth_type = Get_arg('ethPortType')
            if my_eth_type.lower() == 'in':
                eth_input_offset = -8
            elif my_eth_type.lower() == 'out':
                eth_input_offset = 10
            else:
                Exit_program('Invalid ethPortType entered not in range [in/out]: ' + eth_input_offset, 2)
                
            myethimg = ethPortDict.get(eth_port)
            find(Pattern(myethimg).exact())
            if clicktype == '1':
                click(Pattern(myethimg).exact().targetOffset(0,eth_input_offset)); wait("create_input_icons.png")
            elif clicktype == '2':
                doubleClick(Pattern(myethimg).exact().targetOffset(0,eth_input_offset)); wait("create_input_icons.png")
            else:
                Exit_program('Invalid portClick entered not in range [1..2]: ' + clicktype, 2)
            if exists("create_input_icons.png"):
                Print_debug('Selected eth port: ' + eth_port)
            else:
                Exit_program('Failed to select eth port: ' + eth_port)
        else:
            Exit_program('Invalid ethernet port: ' + eth_port, 2)
    elif my_tab.lower() == 'processing' or my_tab.lower() == 'groups':
        if boardSelectedDict.has_key(my_board):
            myboardimg = boardSelectedDict.get(my_board)
            eth_input_offset = int(my_port)*18
            find(Pattern(myboardimg).exact())
            if clicktype == '1':
                click(Pattern(myboardimg).exact().targetOffset(0,eth_input_offset))
            elif clicktype == '2':
                doubleClick(Pattern(myboardimg).exact().targetOffset(0,eth_input_offset))
            else:
                Exit_program('Invalid portClick entered not in range [1..2]: ' + clicktype, 2)
            
#######################################################
#Main program flow
Nav_Boards()
Nav_Ports()


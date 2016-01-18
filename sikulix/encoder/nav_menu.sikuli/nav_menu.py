#Run Navigate the Main menu 
#This script assume that the Java GUI is already running.
#inputs: menuName menuSubName
#    menuName = User:Admin, Tools, Help
#    menuSubName =
#        User:Admin->Permissions, Preferences, Logout
#        Tools->Licenses, Reboot, Refresh
#        Help->Logs, Help, About, Sessions
#Usage: nav_menu.sikuli menuName=[] menuSubName=[]

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    Check_arg('menuName')
    Check_arg('menuSubName')
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here

#Any definitions are here
def Nav_MainMenu():
    Main_gui(2)
    if find("1437001195717.png"):
        #found main menu
        my_menu = Get_arg('menuName')
        my_submenu = Get_arg('menuSubName')
        #This is for User:Admin menu
        if my_menu == 'User\:Admin':
            click(Pattern("1437001195717.png").targetOffset(-51,0))
        #This is for Tools menu
        elif my_menu == 'Tools': 
            click(Pattern("1437001195717.png").targetOffset(18,-1))
        #This is for Help menu
        elif my_menu == 'Help':
            click(Pattern("1437001195717.png").targetOffset(65,-1)); sleep(1)
            wait("1437001280269.png")
            if my_submenu == 'Logs':
                click(Pattern("1437001280269.png").targetOffset(-8,-25)); sleep(1)
            elif my_submenu == 'Help':
                click(Pattern("1437001280269.png").targetOffset(-8,0)); sleep(1)
            elif my_submenu == 'About':
                click(Pattern("1437001280269.png").targetOffset(-4,25)); sleep(1)
            elif my_submenu == 'Sessions':
                click(Pattern("1437001280269.png").targetOffset(-1,51)); sleep(1)
            else:
                Print_text('Wrong submenu: ' + my_submenu)  
        else:
            Print_text('Wong menu: ' + my_menu)
    #wrong menu name    
    else:
        Print_text('Failed to look for main menu.')

#######################################################
#Main program flow
Nav_MainMenu()

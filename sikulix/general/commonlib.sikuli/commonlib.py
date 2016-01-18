from sikuli import *
import sys
import os
import shutil

#Common exit status
#0 = Passed, 1 = Failed, 2 = Errored
program_status = 0

#This routine parse all command line argument into environment table
def Sikuli_parse_args():   
    for arg in sys.argv[1:]:
        i = arg.partition('=')
        a = i[0]
        b = i[1]
        c = i[2]
        c = c.strip(' ')
        if b != '=':
            print "User enter invalid arguments: " + arg
            exit(1)
        if c == '':
            print "User enter invalid arguments: " + arg 
            exit(1)
        os.putenv(a, c)
        
Sikuli_parse_args()

#Get formated current time
def Get_time():
    from time import gmtime, strftime
    mytime = strftime("%Y-%m-%d %H:%M:%S")
    return mytime

#Get formated current time
def Get_time_string():
    from time import gmtime, strftime
    mytime = strftime("%Y%m%d_%H%M%S")
    return mytime

#Run command with options to print out debugging logs
def Run_cmd(cmd):
    Print_text('--> ' + cmd)
    return_status = run(cmd)
    Print_debug('Return status: ' + str(return_status)) 
    return return_status

#This is your check for the inputs that you are expecting.
def Print_env():
    for key in os.environ.keys():
        Print_text(key + ' = ' + os.getenv(key))

#Check for missing arguments.  Exit(1) if it is not found.
def Check_arg(arg):
    if not os.getenv(arg):
        Print_text(arg + ' is missing.')
        exit(2)
    else:
        Print_debug(arg + ' = ' + str(os.getenv(arg)))

#Print with leading timestamp information
def Print_text(text):
    current_time = Get_time()
    print current_time + ' : ' + text
    
#Print with leading timestamp information only if verbosity is greater than 1

def Print_debug(text):
    current_time = Get_time()
    if os.getenv('verbosity'):
        if int(os.getenv('verbosity')) > 1:
            print current_time + ' : ' + text

#Set an argument into environment variable
def Set_arg(myarg, myvalue):
    os.putenv(myarg, myvalue)
    Print_debug('Setting argument: ' + str(myarg) + ' = ' + str(myvalue))
        
def Get_arg(myarg):
    mystatus = os.getenv(myarg)
    Print_debug('Getting argument: ' + str(myarg) + ' = ' + str(mystatus))
    return mystatus

def Capture_screen_old():
    my_capfile = capture(0,0,1920,1080) 
    my_errorname = 'capture_' + Get_time_string() + '.png'   
    if Get_arg('kleverCurrentDir'):
        my_currentdir = Get_arg('kleverCurrentDir')
    else:
        my_currentdir = os.getcwd()
    my_targetname = my_currentdir + '\\' + my_errorname   
    shutil.move(my_capfile, my_targetname)
    Print_text('Screen captured: ' + my_targetname)

def Capture_screen(x=0,y=0,w=1920,h=1080,tofile=False):
    my_capfile = capture(x,y,w,h) 
    if not tofile:
        my_errorname = 'capture_' + Get_time_string() + '.png'
        my_errorname = os.getcwd() + '\\' + my_errorname  
    else:
        my_errorname = tofile
    shutil.move(my_capfile, my_errorname)
    Print_text('Screen captured: ' + my_errorname)

def Exit_capture(exitcode):
    Capture_screen() 
    exit(exitcode)

#Exit program with option to turn on screen capture or not
def Exit_program(mytext, exitcode=1, capturescreen = 0):
    Print_debug(mytext)
    if capturescreen == 1:
        Exit_capture(exitcode)
    else:
        exit(exitcode)

#action = -1 (close), 0 (show), 1 (minimize), 2 (maximize)
def Main_gui(action):
    javaME7000MainTitle = 'ME-7000 - ' + str(Get_arg('encIp')) + ' - ' + str(Get_arg('encGuiLogin'))
    mycmd = 'auto_windows_manager.exe windows_title=\"' + javaME7000MainTitle + '\" windows_action=' + str(action)
    return int(Run_cmd(mycmd))

def Log_gui(action):
    javaME7000LogTitle = 'Log Collector'
    my_cmd = 'auto_windows_manager.exe windows_title=\"' + javaME7000LogTitle + '\" windows_action=' + str(action)
    return int(Run_cmd(my_cmd))

sikuliScriptDir = getParentFolder()
Print_debug('Current sikuli script dir: ' + sikuliScriptDir)

#Set environment showSikuli to see sikuli in actions
if Get_arg('showSikuli'):
    if Get_arg('showSikuli').lower() == 'yes':
        Print_debug('Detecting showSikuli to show Sikuli in actions.')
        setShowActions(True)

#Set to have additional Sikuli debug when setting verbosity =3 or higher
if Get_arg('verbosity'):
    debugLevel = Get_arg('verbosity')
    if int(debugLevel) > 1:
        Debug.on(int(debugLevel))

def RunSikuli(scriptname, scriptdir=sikuliScriptDir):
    runScript(scriptdir + scriptname)

def Print_to_file(myfile, mytext):
    if os.path.exists(myfile):
        myfh = open(myfile, 'a')
    else:
        myfh = open(myfile, 'w')
    if myfh:
        myfh.write(mytext + '\n')
        myfh.close()
    else:
        Exit_program('Problem open file: ' + myfile, 2)

def Control_C():
    type('c', KeyModifier.CTRL)

def Get_Clipboard():
    read_value = Env.getClipboard()
    read_value = read_value.strip()
    return read_value
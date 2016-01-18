#Run DP568 Dolby Reference Decoder 
#inputs: browser=[IE, FireFox, Chrome] dp568Ip=<ip address>
#input: dp568Input = [IP, SDI, ASI, AES, NONE]
#input: dp568IPBookmarkSetup = 0/1, udpIp=[], udpPort=[], udpMode=[Multicast, Unicast]
#Usage: DP568.sikuli browser=Chrome dp568ip=10.77.165.15
#Usage to set SDI input: sikuliScriptName=DP568.sikuli dp568Input=SDI
#Usage to set IP input: sikuliScriptName=DP568.sikuli dp568Input=IP
#Usage to add multicast address: DP568.sikuli dp568IPBookmarkSetup=1 udpIp=236.9.108.1 udpPort=8433
#Usage to add unicast address: DP568.sikuli dp568IPBookmarkSetup=1 udpPort=8433 udpMode=unicast
#Usage to check video format: DP568.sikuli  dp568Input=SDI checkVideo=1 outputFile=[]
#Usage to check video format: DP568.sikuli  dp568Input=SDI checkAudio=1 outputFile=[]

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
    if not Get_arg('browser'):
        Set_arg('browser', 'chrome')
        Print_debug('browser is not given.  Use default value: Chrome')
    Check_arg('dp568Ip')
    #Set name for IP bookmark
    if Get_arg('dp568IPBookmarkSetup'):
        my_bookmarksetup = Get_arg('dp568IPBookmarkSetup')
        if my_bookmarksetup == '1':
            Set_arg('dp568Input', 'IP')
            if not Get_arg('udpMode'):
                Set_arg('udpMode', 'multicast')
                Print_debug('udpMode is not given.  Will use default: multicast.')
            Check_arg('udpPort')
            Set_arg('dp568IPBookmarkName', 'SikuliX')
            Print_debug('Will always use SikuliX as IP bookmark for detecting IP inputs.')
        else:
            Print_debug('dp568IPBookmarkSetup is disabled.')
    if Get_arg('checkVideo'):
        checkvideo = Get_arg('checkVideo')
        if checkvideo == '1':
            Print_debug('Check video is enabled.')
        else:
            Print_debug('Check video is disabled.')

    if Get_arg('checkAudio'):
        checkaudio = Get_arg('checkAudio')
        if checkaudio == '1':
            Print_debug('Check audio is enabled.')
        else:
            Print_debug('Check audio is disabled.')   
            
    if Get_arg('outputFile'):
        myoutputfile = Get_arg('outputFile')
        if not re.search(r'\\', myoutputfile):
            myoutputfile = os.getcwd() + '\\' + myoutputfile
            Set_arg('outputFile', myoutputfile) 
    
Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

dp568Title = 'Dolby Reference Decoder'
outputfile = Get_arg('outputFile')

#Let have a hash table of what to look for
videoDict = {'xoffsetdragend': 220,
             'videoformat':"videoFormat_label-1.png"
            }
#This is the value to click from group audio channel to bring out bitstream info
OffsetY_ForAudio = 26
#This is the information you see when clicking on the main audio codec.
#this will have AC3 Descriptor and etc
audioCodecDict = {'xoffsetdragend': 220,
            'language':"Language_label.png",
            'audiotype':"AudioType_label.png",
            'streamtype':"StreamType_label.png",
            'continuityerrors':"ContinuityErrors_label.png"
            }               
#This is information you see when clicking the specific bitrate of the audio
#This give you more about the bistream, downmixing, and copyright, etc
audioBitstreamDict = {'xoffsetdragend': 130,
                 'group1ch1/2':"Group1Ch12_label-1.png",
                 'group1ch3/4':"Group1Ch34_label-1.png",
                 'group2ch5/6':"Group2Ch56_label-1.png",
                 'group2ch7/8':"Group2Ch78_label-1.png",
                 'group3ch9/10':"Group3Ch910_label-1.png",
                 'group3ch11/12':"Group4Ch1314_label-2.png",
                 'group4ch13/14':"Group4Ch1314_label-3.png",
                 'group4ch15/16':"Group4Ch1516_label-1.png",
                 'codec':"Codec_label-1.png",
                 'bitstreamid':"BitstreamID_label-1.png",
                 'dialnorm':"Dialnorm_label-1.png",
                 'channelmode':"ChannelMode_label-1.png",
                }

#Any definitions are here
def Read_TextFromLabel(labeltext, mydict):
    '''Read text to the right with optional offset'''
    if mydict.has_key(labeltext.lower()):
        labelimg = mydict.get(labeltext.lower())
        myLabel = Region(find(Pattern(labelimg).exact())) 
        if not myLabel:
            Exit_program('Cannot find label text matching ' + labelimg, 2)
        else:
            myXoffsetDragStart = int(myLabel.getW()) / 2
            myXoffsetDragEnd = mydict.get('xoffsetdragend')
            dragDrop(Pattern(labelimg).exact().targetOffset(myXoffsetDragStart, 0), Pattern(labelimg).exact().targetOffset(myXoffsetDragStart+myXoffsetDragEnd, 0))
            Control_C()
            myvalue = Env.getClipboard()
            myvalue = myvalue.strip()
            return myvalue   
    else:
        Exit_program('Unregconized parameter: ' + labeltext, 2)

def Zoom_Chrome():
    #First reset the zoom to default
    type('+', KeyModifier.CTRL)
    find("Resettodefault.png"); click("Resettodefault.png")

def Zoom_Firefox():
    #First reset the zoom to default
    find(Pattern("firefox_setting.png").similar(0.80)); click(Pattern("firefox_setting.png").similar(0.80)); find("firefox_setting_open.png"); doubleClick(Pattern("firefox_setting_open.png").targetOffset(2,37))
    find(Pattern("firefox_setting.png").similar(0.80)); click(Pattern("firefox_setting.png").similar(0.80))

def Launch_DP568():
    new_chrome_title = 'New Tab'
    new_firefox_title = 'Mozilla Firefox Start Page'
    mybrowser = Get_arg('browser')
    mydp568ip = Get_arg('dp568Ip')

    Set_arg('browser', mybrowser)
    RunSikuli('browser_launcher')
    
    if mybrowser.lower() == 'chrome':
        wait("chrome_search_bar.png"); click("chrome_search_bar.png"); type('http://' + mydp568ip); type(Key.ENTER) 
    elif mybrowser.lower() == 'firefox':
        wait("firefox_search.png"); click("firefox_search.png"); type('http://' + mydp568ip); type(Key.ENTER)
    else:
        Exit_program('Unsupported browser enter: ' + mybrowser, 2)

    wait("DolbyReferenceDecoder_title.png")

    if not exists("DP568Reference_title.png"):
        if mybrowser.lower() == 'chrome': Zoom_Chrome()
        if mybrowser.lower() == 'firefox': Zoom_Firefox()
        Print_debug('Adjusting browser zoom')

    if exists("DP568Reference_title.png"):
        Print_debug('dp568 sesssion launched successfully.')
    else:
        Exit_program('Failed to connect to dp568: ' + mydp568ip, 2)

def Run_DP568():
    mycmd = 'auto_windows_manager.exe windows_title=\"' + dp568Title + '\" windows_action=2'
    my_status = Run_cmd(mycmd)
  
    if int(my_status) == 0:
        Print_debug(dp568Title + ' is already running.  Use current session.')
    else:
        Print_debug('Need to launch a new browser session to control DP568.')
        Launch_DP568()
        

def Select_Input():
    if Get_arg('dp568Input'):
        find("dp568_menu.png"); click(Pattern("dp568_menu.png").targetOffset(-25,-167)); wait("Input_label.png")
        my_input = Get_arg('dp568Input')
        if my_input.upper() == 'ASI' or my_input == 'SDI':
            if not exists("InputASISDI_label.png"): click(Pattern("Input_label.png").targetOffset(110,0)); click(Pattern("ASISDI_select.png").similar(0.90)); wait("InputASISDI_label.png")
        elif my_input.upper() == 'IP':
            if not exists("InputIP_label.png"): click(Pattern("Input_label.png").targetOffset(110,0)); click(Pattern("IP_select.png").similar(0.90)); wait("InputIP_label.png")
        elif my_input.upper() == 'AES':
            if not exists("InputAES_label.png"): click(Pattern("Input_label.png").targetOffset(110,0)); click(Pattern("AES_select.png").similar(0.90)); wait("InputAES_label.png")
        elif my_input.upper() == 'NONE':
            if not exists("InputNone_label.png"): click(Pattern("Input_label.png").targetOffset(110,0)); click(Pattern("None_select.png").similar(0.90)); wait("InputNone_label.png")
        else:
            Exit_program('Invalid dp568Input given not in range [ASI, SDI, IP, AES, NONE]: ' + my_input, 2)

def Setup_IP_Bookmarks():
    if Get_arg('dp568IPBookmarkSetup'):
        my_bookmark = Get_arg('dp568IPBookmarkName')
        #Before deleting label, has to select input to none first
        find("dp568_menu.png"); click(Pattern("dp568_menu.png").targetOffset(-26,-167)); click(Pattern("InputIP_label.png").targetOffset(341,0)); click(Pattern("None_select.png").similar(0.90))
        #delete existing label if it is already there
        find("dp568_menu.png"); click(Pattern("dp568_menu.png").targetOffset(-1,-18)); wait("AddBookmarkName_setting.png")
        if exists("SikuliX_label.png"): click("SikuliX_label.png"); find(Pattern("delete_button.png").exact()); click(Pattern("delete_button.png").exact())
        #creating ip book mark base on given information
        
        outputport = Get_arg('udpPort')
        outputmode = Get_arg('udpMode')
        #Entering bookmark name
        doubleClick(Pattern("AddBookmarkName_setting.png").targetOffset(-267,17)); type(my_bookmark)
        if outputmode.lower() == 'multicast':
            Check_arg('udpIp')
            outputip = Get_arg('udpIp')
            #Selecting mode type
            click(Pattern("AddBookmarkName_setting.png").targetOffset(-92,16))
            click(Pattern("AddBookmarkName_setting.png").targetOffset(-123,42))
            #Entering multicast group
            doubleClick(Pattern("AddBookmarkName_setting.png").targetOffset(5,17)); type(outputip)
            #Entering multicast port
            doubleClick(Pattern("AddBookmarkName_setting.png").targetOffset(131,18)); type(outputport)
            
        elif outputmode.lower() == 'unicast':
            #Selecting mode type
            click(Pattern("AddBookmarkName_setting.png").targetOffset(-92,16))
            click(Pattern("AddBookmarkName_setting.png").targetOffset(-126,53))
             #Entering multicast port
            doubleClick(click(Pattern("AddBookmarkName_setting.png").targetOffset(131,18))); type(outputport)
        else:
            Exit_program('Invalid udpMode entered not in range [multicast/unicast]: ' + outputmode, 2) 
        
        #Hitting save
        find(Pattern("save_button.png").exact()); click(Pattern("save_button.png").exact())
        if exists("SikuliX_label.png"): Print_debug('SikuliX ip bookmark created successfully.')
        else: Exit_program('SikuliX ip bookmark failed to create.', 1)

def Read_SDI_Video_Format():
    if exists("video_status.png"):
        Print_debug('Video status is good.')
        read_video_format = Read_TextFromLabel('videoFormat', videoDict)
        #strip off any trailing fps
        read_video_format = read_video_format.replace('fps', '')
        read_video_format = read_video_format.replace(' ', '')
        read_video_format = read_video_format.strip()
        mystr = 'videoformat=' + read_video_format
        Print_text(mystr)
        Print_to_file(outputfile, mystr)
        click(Pattern("InputASISDI_label.png").targetOffset(-26,46))
    else:
        Exit_program('Video signal is not good.', 1, 1)

def Read_SDI_Audio_Format():
    if Get_arg('checkAudio'):
        dragDrop(Pattern("SDI_detection.png").similar(0.90).targetOffset(-26,23),Pattern("SDI_detection.png").similar(0.90).targetOffset(240,453))   
        Control_C() 
        read_audio_format = Env.getClipboard()
        mylist = read_audio_format.split('\n')
        print len(mylist)
        for key in mylist:
            eachkey = key.split('-')
            if len(eachkey) == 2:
                audioch = eachkey[0]
                audioch = audioch.replace(' ', '')
                audiovalue = eachkey[1]
                audioch = audioch.strip()
                audiovalue = audiovalue.strip()
                mystr = audioch.lower() + '=' + audiovalue
                Print_text(mystr) 
                Print_to_file(outputfile, mystr)
        click(Pattern("InputASISDI_label.png").targetOffset(-26,46))

def Check_Video_Format():
    if Get_arg('checkVideo'):
        checkvideo = Get_arg('checkVideo')
        if checkvideo == '1':
            #Depends on if we're in SDI/IP selection
            click(Pattern("dp568_menu.png").targetOffset(-27,-167));
            #detecting what is the input
            if exists("InputIP_label.png"):
                if not exists(Pattern("SourceIPISikuli_label.png").similar(0.80)):
                    #Need to select SikuliX
                    click(Pattern("InputIP_label.png").targetOffset(339,-1)); click("Sikulix_select.png")
                    

            if exists("InputASISDI_label.png"):
                click(Pattern("InputASISDI_label.png").targetOffset(-26,46))
                if exists(Pattern("asi_detection.png").similar(0.90)):
                    mystr = 'inputtype=ASI'
                    Print_text(mystr) 
                    Print_to_file(outputfile, mystr)
                elif exists(Pattern("SDI_detection.png").similar(0.90)):
                    mystr = 'inputtype=SDI'
                    Print_text(mystr) 
                    Print_to_file(outputfile, mystr)
                    Read_SDI_Video_Format()
                    Read_SDI_Audio_Format()
                else:
                    mystr = 'inputtype=unknown'
                    Print_text(mystr) 
                    Print_to_file(outputfile, mystr)


#######################################################
#Main program flow
Run_DP568()
Select_Input()
Setup_IP_Bookmarks()
Check_Video_Format()

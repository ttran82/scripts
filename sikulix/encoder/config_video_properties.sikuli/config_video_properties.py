#Configure video properties page
#This routine assume the program you want is already selected.
#inputs: mctfStrength=[]: passthrough, weakest, weak, medium, strong, strongest
#inputs: resolution=[] all the valid video output resolution: 720x576i25, 720x480i29.97, 1280x720p50, 1280x720p59.94, 1920x1080i29.97, 720x480p59.94
#inputs: apsectRatio=4:3, 16:9, Auto-Passthrough
#inputs: afdType=Off, Manual, Passthrough
#inputs: afdValue=[2,3,4,8,9,10,11,13,14,15]
#    2 == 'Letterbox 16:9 top':
#    3 == 'Letterbox 14:9 top':
#    4 == 'Letterbox > 16:9 Center':
#    8 == 'Full frame':
#    9 == 'Pillarbox 4:3 Center':
#    10 == '16:9 Center with Image Protection':
#    11 == '14:9 Center':
#    13 == '4:3 with Alternative 14:9 Center':
#    14 == '16:9 with Alternative 14:9 Center':
#    15 == '16:9 with Alternative 4:3 Center':
#input: applyChanges=[1/0, default = 1] To apply changes at the end of operation or not
#Usage: config_video_properties.sikuli resolution=[]
#Usage: config_video_properties.sikuli resolution=[] applyChanges=0


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
    Set_default_arg('applyChanges', '1')

Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

videoPropertiesTitle = 'Configure Video Encoding Properties'

#Any definitions are here
def Open_VideoProperties():
    
    find("OutputInfo.png")
    doubleClick(Pattern("OutputInfo.png").similar(0.90).targetOffset(-4,20))
    wait("CongureVideo_MainPage.png")
    

def Cancel_VideoProperties():
    find("ok_cancel_buttons.png")
    click(Pattern("ok_cancel_buttons.png").similar(0.80).targetOffset(27,1))

def Close_VideoProperties():
    find("ok_cancel_buttons.png")
    click(Pattern("ok_cancel_buttons.png").similar(0.80).targetOffset(-37,2))

def Configure_MCTF():
    if Get_arg('mctfStrength'):
        mctf = Get_arg('mctfStrength')
        find("MCFStrength_lablel.png")
        #click on the drop down
        click(Pattern("MCFStrength_lablel.png").targetOffset(118,0));sleep(1)
        #click strength base on strength value
        if mctf == 'passthrough':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,20)); sleep(1)
        elif mctf == 'weakest':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,35)); sleep(1)
        elif mctf == 'weak':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,50)); sleep(1)
        elif mctf == 'medium':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,65)); sleep(1)
        elif mctf == 'strong':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,80)); sleep(1)
        elif mctf == 'strongest':
            click(Pattern("MCFStrength_lablel.png").targetOffset(78,95)); sleep(1)
        else:
            Cancel_VideoProperties()
            Exit_program('Invalid mctf strength not in list (passthrough, weakest, weak, medium, strong, strongest): ' + mctf, 2)

def Configure_Resolution():
    outputResolutionDict = {
    #50Hz
    '1920x1080i25':"1920x1080i25_select-2.png", '1440x1080i25':"1440x1080i25_select-1.png", '1280x1080i25':"1280x1080i25_select.png", '960x1080i25':"960x1080i25_select-1.png",
    '1280x720p50':"1280x720p50_select-1.png", '960x720p50':"1442123106003-1.png",
    '720x576i25':"720x576i25_select-1.png",'704x576i25':"704x576i25_select-1.png",'640x576i25':"640x576i25_select-1.png",'544x576i25':"544x576i25_select-1.png",'528x576i25':"528x576i25_select-1.png",'480x576i25':"480x576i25_select-1.png",'352x576i25':"352x576i25_select-1.png",
    #50Hz MBR exclusive
    '1920x1080p50':"1920x1080p50_select.png", '1440x1080p50':"1440x1080p50_select.png", '1280x1080p50':"1280x1080p50_select.png", '960x1080p50':"960x1080p50_select.png",
    '720x576p50':"720x576p50_select-1.png", '704x576p50':"704x576p50_select-1.png", '640x576p50':"640x576p50_select-1.png", '544x576p50':"544x576p50_select-1.png", '528x576p50':"528x576p50_select-1.png", '480x576p50':"480x576p50_select-1.png", '352x576p50':"352x576p50_select-1.png",
    '1920x1080p25':"1920x1080p25_select.png", '1440x1080p25':"1440x1080p25_select.png", '1280x1080p25':"1280x1080p25_select.png", '960x1080p25':"960x1080p25_select.png",
    '1280x720p25':"1280x720p25_select.png", '1024x576p25':"1024x576p25_select.png", '720x576p25':"720x576p25_select.png", '704x576p25':"704x576p25_select.png", 
    '960x544p25':"960x544p25_select.png", '720x544p25':"720x544p25_select.png", '960x540p25':"960x540p25_select.png", '720x540p25':"720x540p2S_select.png", 
    '854x480p25':"854x480p25_select.png", '720x480p25':"720x480p25_select.png", '704x480p25':"704x480p25_select.png", '640x480p25':"640x480p25_select.png", '544x480p25':"544x480p2S_select.png", '528x480p25':"528x480p25_select.png",
    '800x450p25':"800x450p25_select.png", '768x432p25':"768x432p25_select.png", '720x408p25':"720x408p25_select.png", '544x408p25':"544x408p25_select.png", '720x404p25':"720x404p25_select.png", '704x396p25':"704x396p25_select.png",
    '640x360p25':"540x360p25_select.png", '480x360p25':"480x360p25_select.png", '448x336p25':"448x336p25_select.png", '480x320p25':"480x320p25_select.png", '352x320p25':"352x320p25_select.png", '400x300p25':"400x300p25_select.png", 
    '512x288p25':"512x288p25_select.png", '384x288p25':"384x288p25_select.png", '480x272p25':"480x272p25_select.png", '480x270p25':"480x270p25_select.png", '480x244p25':"480x244p25_select.png", 
    '360x240p25':"360x240p25_select.png", '320x240p25':"320x240p25_select.png", '400x224p25':"400x224p25_select.png", '384x216p25':"384x216p25_select.png", 
    '720x576p12.5':"720x576p125_select.png", '720x544p12.5':"720x544p125_select.png", '720x540p12.5':"720x540p125_select.png", 
    '720x480p12.5':"720x480p125_select.png", '704x480p12.5':"704x480p125_select.png", '640x480p12.5':"640x480p125_select.png", '544x480p12.5':"544x480p125_select.png", '528x480p12.5':"528x480p125_select.png",
    '720x408p12.5':"720x408p125_select.png", '544x408p12.5':"544x408p125_select.png", '720x404p12.5':"720x404p125_select.png", '704x396p12.5':"704x396p125_select.png", '640x360p12.5':"640x360p125_select.png", '480x360p12.5':"480x360p125_select.png",
    '448x336p12.5':"448x336p125_select.png", '480x320p12.5':"480x320p125_select.png", '352x320p12.5':"352x320p125_select.png", '400x300p12.5':"400x300p125_select.png", '512x288p12.5':"512x288p125_select.png", '384x288p12.5':"384x288p125_select.png",
    '480x272p12.5':"480x272p125_select.png", '480x270p12.5':"480x270p125_select.png", '480x244p12.5':"480x244p125_select.png", '360x240p12.5':"360x240p125_select.png", '320x240p12.5':"320x240p125_select.png", 
    '400x224p12.5':"400x224p125_select.png", '384x216p12.5':"384x216p125_select.png", 
    #60Hz
    '1920x1080i29.97':"1920x1080i2997_select-1.png",'1440x1080i29.97':"1440x1080i2997_select-1.png",'1280x1080i29.97':"1280x1080i2997_select-1.png",'960x1080i29.97':"960x1080i2997_select-1.png",
    '1280x720p59.94':"1280x720pS994_select-1.png", '960x720p59.94':"960x720p5994_select-1.png",
    '720x480i29.97':"720x480i2997_sel2-2.png",'704x480i29.97':"704x480i2997_select-1.png",'640x480i29.97':"640x480i2997_select-1.png",'544x480i29.97':"544x480i2997_select-1.png",'528x480i29.97':"528x480i2997_sel-2.png",'480x480i29.97':"480x480i2997_select-1.png",'352x480i29.97':"352x480i2997_select-1.png",
    #60Hz MBR exclusive
    '1920x1080p59.94':"1920x1080p59_select.png", '1440x1080p59.94':"1440x1080p59_select.png", '1280x1080p59.94':"1280x1080p59_select.png", '960x1080p59.94':"960x1080p59_select.png",
    '720x480p59.94':"720x480p5994_select-2.png",'704x480p59.94':"704x480p5994_select-2.png",'640x480p59.94':"640x480p5994_select-2.png",'544x480p59.94':"544x480p5994_select-2.png",'528x480p59.94':"528x480p5994_select-2.png",'480x480p59.94':"480x480p5994_select-2.png",'352x480p59.94':"352x480p5994_select-2.png", 
    '1920x1080p29.97':"1920x1080p29_select.png", '1440x1080p29.97':"1440x1080p29_select.png", '1280x1080p29.97':"1280x1080p29_select.png", '960x1080p29.97':"960x1080p29_select.png",
    '1280x720p29.97':"1280x720p29_select.png", '720x576p29.97':"720x576p29_select.png", '960x544p29.97':"960x544p29_select.png", '720x544p29.97':"720x544p29_select.png", '960x540p29.97':"960x540p29_select.png", 
    '854x480p29.97':"854x480p2997_select.png", '720x480p29.97':"720x480p2997_select-1.png", '704x480p29.97':"704x480p2997_select-1.png", '640x480p29.97':"640x480p2997_select-1.png", '544x480p29.97':"544x480p2997_select-1.png", '528x480p29.97':"528x480p2997_select-1.png",
    '800x450p29.97':"800x450p2997_select.png", '768x432p29.97':"768x432p2997_select.png", 
    '720x408p29.97':"720x408p2997_select-1.png", '704x396p29.97':"704x396p2997_select-1.png", '640x360p29.97':"640x360p2997_select-1.png", '480x360p29.97':"480x360p2997_select.png", '448x336p29.97':"448x336p2997_select.png", '480x320p29.97':"480x320p2997_select.png",
    '352x320p29.97':"352x320p2997_select.png", '512x288p29.97':"512x288p2997_select.png", '384x288p29.97':"384x288p2997_select.png", '480x272p29.97':"480x272p2997_select.png", '480x270p29.97':"480x270p2997_select.png", '480x244p29.97':"480x244p2997_select.png",
    '360x240p29.97':"360x240p2997_select.png", '320x240p29.97':"320x240p2997_select.png", '384x216p29.97':"384x216p2997_select.png", 
    '720x480p14.98':"720x480p1498_select.png", '704x480p14.98':"704x480p1498_select.png", '640x480p14.98':"640x480p1498_select.png", '544x480p14.98':"544x480p1498_select.png", '528x480p14.98':"528x480p1498_select.png", '720x408p14.98':"720x408p1498_select.png",
    '704x396p14.98':"704x396p1498_select.png", '640x360p14.98':"640x360p1498_select.png", '480x360p14.98':"480x360p1498_select.png", '448x336p14.98':"448x336p1498_select.png", '480x320p14.98':"480x320p1498_select.png", '352x320p14.98':"352x320p1498_select.png",
    '512x288p14.98':"512x288p1498_select.png", '384x288p14.98':"384x288p1498_select.png", '480x272p14.98':"480x272p1498_select.png", '480x270p14.98':"480x270p1498_select.png", '480x244p14.98':"480x244p1498_select.png", '360x240p14.98':"360x240p1498_select.png",
    '320x240p14.98':"320x240p1498_select.png", '384x216p14.98':"384x216p1498_select.png", 
    }
    myres = Get_arg('resolution')
    myres = myres.lower()
    if myres:    
        if outputResolutionDict.has_key(myres):
            myArea = Region(find("ConfigureVideo_window.png"))
            myArea = Region(myArea.getX(), myArea.getY(), myArea.getW(), myArea.getH()+500)
    
            myArea.find("Resolution_label-2.png"); myArea.click(Pattern("Resolution_label-2.png").targetOffset(66,-1))
            myresimg = outputResolutionDict.get(myres)
            findresimg =  myArea.exists(Pattern(myresimg).exact())
            #try to find 4 more times
            if not findresimg:
                #If selection span more than a whole selection, put it back on top
                if myArea.exists(Pattern("expand_bar-1.png").similar(0.90)): 
                    myArea.dragDrop("middle_bar_for_drag-1.png", Pattern("expand_bar-2.png").similar(0.90))
                    findresimg =  exists(Pattern(myresimg).exact())
                    while not findresimg:
                        if myArea.exists(Pattern("down_arrow_for_clicking.png").exact()): myArea.click(Pattern("down_arrow_for_clicking.png").exact().targetOffset(0,-7)); findresimg = exists(Pattern(myresimg).exact())                       
                        else: break;
                    if findresimg:
                        Print_debug('Found resolution: ' + myres)
                        myArea.click(Pattern(myresimg).exact())
                    else:
                        Cancel_VideoProperties()
                        Exit_program('Failed to find resolution: ' + myres, 1) 
                            
                else:
                    Cancel_VideoProperties()
                    Exit_program('Failed to set resolution: ' + myres, 1)
            else:
                Print_debug('Found resolution: ' + myres)
                myArea.click(Pattern(myresimg).similar(0.80))
        else:
            Cancel_VideoProperties()
            Exit_program('Unregconized output resolution enter: ' + myres, 2)

def Configure_Resolution_Old():
    if Get_arg('resolution'):
        myres = Get_arg('resolution')
        find("Resolution_label-1.png")
        click(Pattern("Resolution_label-1.png").targetOffset(66,-1))
        if myres == '1920x1080i29.97': find("1920x1080i29_selection-1.png"); click("1920x1080i29_selection-1.png"); sleep(1)
        elif myres == '1440x1080i29.97': find("1440x1080i29_selection.png"); click("1440x1080i29_selection.png"); sleep(1)
        elif myres == '1280x1080i29.97': find("1280x1080i29_selection.png"); click("1280x1080i29_selection.png"); sleep(1)
        elif myres == '960x1080i29.97': find("960x1080i2997_selection.png"); click("960x1080i2997_selection.png"); sleep(1)
        elif myres == '1280x720p59.94': find("1280x720p5994_selection.png"); click("1280x720p5994_selection.png"); sleep(1)
        elif myres == '960x720p59.94': find("960x720p5994_selection.png"); click("960x720p5994_selection.png"); sleep(1)
        elif myres == '720x480i29.97': 
            if exists(Pattern("720x480i2997_sel.png").similar(0.90)): click(Pattern("720x480i2997_sel.png").similar(0.90)); sleep(1)
            if exists(Pattern("720x480i2997_sel2.png").similar(0.90)): click(Pattern("720x480i2997_sel2.png").similar(0.90)); sleep(1)
        elif myres == '704x480i29.97': find("704x480i2997_selection.png"); click(Pattern("704x480i2997_selection.png").similar(0.90)); sleep(1)
        elif myres == '640x480i29.97': find(Pattern("640x480i2997_selection.png").similar(0.90)); click(Pattern("640x480i2997_selection.png").similar(0.90)); sleep(1)
        elif myres == '544x480i29.97': find(Pattern("544x480i2997_selection-1.png").similar(0.90)); click(Pattern("544x480i2997_selection-1.png").similar(0.90)); sleep(1)
        elif myres == '528x480i29.97':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("528x480i2997_sel.png").exact()); click(Pattern("528x480i2997_sel.png").exact()); sleep(1)  
        elif myres == '480x480i29.97':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("480x480i2997_selection.png").similar(0.90)); click(Pattern("480x480i2997_selection.png").similar(0.90)); sleep(1)
        elif myres == '352x480i29.97':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("352x480i2997_selection.png").similar(0.90)); click(Pattern("352x480i2997_selection.png").similar(0.90)); sleep(1)
        elif myres == '1920x1080i25': find("1920x1080i25_selection.png"); click("1920x1080i25_selection.png"); sleep(1)
        elif myres == '1440x1080i25': find("1440x1080i25_selection.png"); click("1440x1080i25_selection.png"); sleep(1)
        elif myres == '1280x1080i25': find("1280x1080i25_selection.png"); click("1280x1080i25_selection.png"); sleep(1)
        elif myres == '960x1080i25': find("960x1080i25_selection.png"); click("960x1080i25_selection.png"); sleep(1)
        elif myres == '1280x720p50': find("1280x720p50_selection.png"); click("1280x720p50_selection.png"); sleep(1)
        elif myres == '960x720p50': find("960x720p50_selection.png"); click("960x720p50_selection.png"); sleep(1)
        elif myres == '720x576i25': 
            if exists(Pattern("720x576i25_sel.png").similar(0.90)): click(Pattern("720x576i25_sel.png").similar(0.90)); sleep(1)
            if exists(Pattern("720x576i25_sel2.png").similar(0.90)): click(Pattern("720x576i25_sel2.png").similar(0.90)); sleep(1)
        elif myres == '704x576i25': find(Pattern("704x576i25_selection.png").similar(0.90)); click(Pattern("704x576i25_selection.png").similar(0.90)); sleep(1)
        elif myres == '640x576i25': find(Pattern("640x576i25_selection.png").similar(0.90)); click(Pattern("640x576i25_selection.png").similar(0.90)); sleep(1)
        elif myres == '544x576i25': find(Pattern("544x576i25_selection.png").similar(0.90)); click(Pattern("544x576i25_selection.png").similar(0.90)); sleep(1)
        elif myres == '528x576i25':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("528x576i25_selection.png").exact()); click(Pattern("528x576i25_selection.png").exact()); sleep(1)  
        elif myres == '480x576i25':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("480x576i25_selection.png").similar(0.90)); click(Pattern("480x576i25_selection.png").similar(0.90)); sleep(1)
        elif myres == '352x576i25':
            if exists(Pattern("res_drop_down.png").similar(0.90)): click(Pattern("res_drop_down.png").exact().targetOffset(0,-16))
            find(Pattern("352x576i25_selection.png").similar(0.90)); click(Pattern("352x576i25_selection.png").similar(0.90)); sleep(1)    
        elif myres == '720x480p59.94': click(Pattern("720x480p5994_select.png").similar(0.80)); sleep(1)
        elif myres == '704x480p59.94': click(Pattern("704x480p5994_select.png").similar(0.80)); sleep(1)
        elif myres == '640x480p59.94': click(Pattern("640x480p5994_select.png").similar(0.80)); sleep(1)
        elif myres == '544x480p59.94': click(Pattern("544x480p5994_select.png").similar(0.80)); sleep(1)
        elif myres == '528x480p59.94': click(Pattern("528x480p5994_select.png").exact()); sleep(1)
        elif myres == '480x480p59.94': click(Pattern("480x480p5994_select.png").similar(0.90)); sleep(1)
        elif myres == '352x480p59.94': click(Pattern("3S2x480p5994_select.png").similar(0.90)); sleep(1)
        else:
            Cancel_VideoProperties()
            Exit_program('Invalid resolution entered: ' + myres, 2)

def Configure_AspectRatio():
    if Get_arg('aspectRatio'):
        myar = Get_arg('aspectRatio')
        find("AFDAspectRatio_section.png")
        find(Pattern("AspectRatio_selection.png").exact()); click(Pattern("AspectRatio_selection.png").exact().targetOffset(49,1)); sleep(1)
        if myar == '4:3':
            find(Pattern("4x3_ar.png").exact()); click(Pattern("4x3_ar.png").exact()); sleep(1)
        elif myar == '16:9':
            find("169_ar.png"); click("169_ar.png"); sleep(1)
        elif myar == 'Auto-Passthrough':
            find("AutoPassthrough_ar.png"); click("AutoPassthrough_ar.png"); sleep(1)
        else:
            Exit_program('Invalid aspect ratio entered not in range of (Auto-Passthrough, 4:3, 16:9): ' + myar, 2)

def Configure_AFDType():
    if Get_arg('afdType'):
        myafdtype = Get_arg('afdType')
        find("AFDAspectRatio_section.png")
        find(Pattern("afd_selection.png").similar(0.90)); click(Pattern("afd_selection.png").similar(0.90).targetOffset(116,1)); sleep(1)
        if myafdtype == 'Off':
            find("AFDOff_sel.png"); click("AFDOff_sel.png"); sleep(1)
        elif myafdtype == 'Manual':
            find("AFDManual_sel.png"); click("AFDManual_sel.png"); sleep(1)
        elif myafdtype == 'Passthrough':
            find("AFDPassthrough_sel.png"); click("AFDPassthrough_sel.png"); sleep(1)
        else:
            Exit_program('Invalid afd type entered not in range of (Off, Passthrough, Manual): ' + myafdtype, 2)

def Configure_AFDValue():
    if Get_arg('afdValue'):
        myafdvalue = Get_arg('afdValue')
        find("AFDAspectRatio_section.png")
        find(Pattern("afd_selection.png").similar(0.90)); click(Pattern("afd_selection.png").similar(0.90).targetOffset(195,24)); sleep(1); find(Pattern("up_arrow.png").targetOffset(1,-4)); click(Pattern("up_arrow.png").targetOffset(1,-4)) ; sleep(1) 
        if myafdvalue == '2':
            find(Pattern("Letterbox169_sel.png").similar(0.80)); click(Pattern("Letterbox169_sel.png").similar(0.80)); sleep(1)
        elif myafdvalue == '3':
            find(Pattern("Letterbox149_sel.png").similar(0.90)); click(Pattern("Letterbox149_sel.png").similar(0.90)); sleep(1)
        elif myafdvalue == '4':
            find(Pattern("Letterbox169_afd4.png").similar(0.80)); click(Pattern("Letterbox169_afd4.png").similar(0.80)); sleep(1)
        elif myafdvalue == '8':
            find(Pattern("FullFrame_afd8.png").similar(0.80)); click(Pattern("FullFrame_afd8.png").similar(0.80)); sleep(1)
        elif myafdvalue == '9':
            find("Piillarbox43_afd9.png"); click("Piillarbox43_afd9.png"); sleep(1)
        elif myafdvalue == '10':
            find("169Centerwith_afd10.png"); click("169Centerwith_afd10.png"); sleep(1)
        elif myafdvalue == '11':
            find(Pattern("149Center_afd11.png").similar(0.90)); click(Pattern("149Center_afd11.png").similar(0.90)); sleep(1)
        elif myafdvalue == '13':
            find("43withAltern_afd13.png"); click("43withAltern_afd13.png"); sleep(1)
        elif myafdvalue == '14':
            find(Pattern("down_bar.png").targetOffset(0,2)); click(Pattern("down_bar.png").targetOffset(0,2)); sleep(1); find(Pattern("169withAlter_afd14.png").similar(0.90)); click(Pattern("169withAlter_afd14.png").similar(0.90)); sleep(1)
        elif myafdvalue == '15':
            find(Pattern("down_bar.png").targetOffset(0,2)); click(Pattern("down_bar.png").targetOffset(0,2)); sleep(1); find(Pattern("169withAlter_afd15.png").similar(0.90)); click(Pattern("169withAlter_afd15.png").similar(0.90)); sleep(1)
        else:
            Exit_program('Invalid afd value entered not in range of (2,3,4,8,9,10,11,13,14,15): ' + myafdvalue, 2)

def Configure_AFD():
    Configure_AFDType()
    Configure_AFDValue()

def Apply_Changes():
    myaction = Get_arg('applyChanges')
    if myaction:
        if myaction == '1':
            RunSikuli('apply_groom_changes')
            
#######################################################
#Main program flow
Open_VideoProperties()
Configure_MCTF()
Configure_AspectRatio()
Configure_Resolution()
Configure_AFD()
Close_VideoProperties()
Apply_Changes()
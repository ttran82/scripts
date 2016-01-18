#Configure audio properties page
#This assume the correct output group is already selected and it will select the desired audio channel 
#inputs: audioChannel=[1..8] choosing which audio channel to configure
#Usage: config_audio_properties.sikuli audioOutputType audioOutputBitrate audioChannel

###############################################################
#common code for every sikuli code.  Do not remove this section
from me7klib import *
###############################################################

#YOUR code start here
###############################################################
#This is your check for the inputs that you are expecting.
def Check_args():
    #checking for required arguments
    if not Get_arg('audioChannel'):
        Set_arg('audioChannel', '1')
        Print_debug('audioChannel is not defined.  Will use 1 as default.')

Check_args()            

############################################################
#Main program definitions code start from this point
#Any global variables here
Settings.OcrTextSearch=True
Settings.OcrTextRead=True

#Any definitions are here
def Open_AudioProperties():
    
    find("OutputInfo.png") 
    my_audioch = Get_arg('audioChannel')
    my_offset_const = 18
    my_offset = 17
    doubleClick(Pattern("OutputInfo.png").similar(0.90).targetOffset(0,my_offset_const + int(my_audioch)*my_offset))
    wait("AudioEncoding_main_page.png")

def Cancel_AudioProperties():
    find("ok_cancel_buttons.png"); click(Pattern("ok_cancel_buttons.png").targetOffset(35,0))

def Close_AudioProperties():
    find("ok_cancel_buttons.png"); click(Pattern("ok_cancel_buttons.png").targetOffset(-35,0))

def Configure_OutputType():
    if Get_arg('audioOutputType'):
        find(Pattern("OutputTYPE_label.png").similar(0.90))
        my_audiotype = Get_arg('audioOutputType')
        if exists(Pattern("InputTypeDDP.png").similar(0.90)):   
            Print_debug('Detecting DD Pro audio input.')
            click(Pattern("OutputTYPE_label.png").similar(0.90).targetOffset(149,1))
            if my_audiotype == 'PassThrough': find("PassThrough_audio-1.png"); click("PassThrough_audio-1.png")
            elif my_audiotype == 'Downmix DD Pro': find("DownmixDDPro_audio.png"); click("DownmixDDPro_audio.png")
            elif my_audiotype == 'Transcode DD+ Pro': find("TranscodeDDP_audio.png"); click("TranscodeDDP_audio.png")
            elif my_audiotype == 'Downmix HE-AAC': find(Pattern("DownmixHEAAC.png").similar(0.80)); click(Pattern("DownmixHEAAC.png").similar(0.80))
            else: 
                Cancel_AudioProperties()
                Exit_program('Invalid audioOutputType entered: ' + my_audiotype + ' while input is DD Pro.', 2)
        elif exists(Pattern("InputTypePCM.png").similar(0.90)):
            Print_debug('Detecting PCM audio input.')
            click(Pattern("OutputTYPE_label.png").similar(0.90).targetOffset(166,1))
            if my_audiotype == 'Encode MPEG1 LayerII': find("EncodeMpeg1L2-1.png"); click("EncodeMpeg1L2-1.png")
            elif my_audiotype == 'Encode DD Pro': find("EncodeDDPro.png"); click("EncodeDDPro.png")
            elif my_audiotype == 'Encode DD+ Pro': find("EncodeDDPro-1.png"); click("EncodeDDPro-1.png")
            elif my_audiotype == 'Encode HE-AAC': find("EncodeHEAAC.png"); click("EncodeHEAAC.png")
            else: 
                Cancel_AudioProperties()
                Exit_program('Invalid audioOutputType entered: ' + my_audiotype + ' while input is PCM.', 2)
        elif exists(Pattern("InputTypeDDP-1.png").similar(0.90)):
            Print_debug('Detecting DD+ Pro audio input.')
            click(Pattern("OutputTYPE_label.png").similar(0.90).targetOffset(116,0))
            if my_audiotype == 'Passthrough': find("PassThrough.png"); click("PassThrough.png")
            else: 
                Cancel_AudioProperties()
                Exit_program('Invalid audioOutputType entered: ' + my_audiotype + ' while input is DD+ Pro.', 2)
        else:
            Exit_program('Unknown input type.  Please see attached screen shot for more information.', 1, 1)     

def Configure_Bitrate():
    if Get_arg('audioOutputBitrate'):
        my_bitrate = Get_arg('audioOutputBitrate')
        my_audiotype = Get_arg('audioOutputType')
        find(Pattern("audioBitrate.png").similar(0.90)); click(Pattern("audioBitrate.png").similar(0.90).targetOffset(70,0))
        if my_audiotype == 'Passthrough':
            if my_bitrate == '32': click("32kbps.png")
            elif my_birate == '40': click("40kbps.png")
            else: Exit_program('Invalid audioOutputBitrate entered: ' + my_bitrate + ' while audioOutputType is Passthrough.', 2)
        elif my_audiotype == 'Downmix DD Pro':
            if my_bitrate == '96': click("96kbps.png")
            elif my_bitrate == '128': click("128kbps.png")
            elif my_bitrate == '160': click("160kbps.png")
            elif my_bitrate == '192': click("192kbps.png")
            elif my_bitrate == '224': click("224kbps.png")
            elif my_bitrate == '256': click("256kbps.png")
            else: Exit_program('Invalid audioOutputBitrate entered: ' + my_bitrate + ' while audioOutputType is Downmix DD Pro.', 2)
        elif my_audiotype == 'Transcode DD+ Pro':
            if my_bitrate == '96st': click("96stkbps.png")
            elif my_bitrate == '128st': click("128stkbps.png")
            elif my_bitrate == '160st': click("160stkbps.png")
            elif my_bitrate == '192': click("192kbps.png")
            elif my_bitrate == '224': click("224kbps.png")
            elif my_bitrate == '256': click("256kbps.png")
            elif my_bitrate == '320': click("320kbps.png")
            elif my_bitrate == '384': click("384kbps.png")
            elif my_bitrate == '448': click("448kbps.png")
            else: Exit_program('Invalid audioOutputBitrate entered: ' + my_bitrate + ' while audioOutputType is Downmix DD+ Pro.', 2)
        elif my_audiotype == 'Downmix HE-AAC':
            if my_bitrate == '64': click("64kbps.png")
            elif my_bitrate == '80': click("80kbps-1.png")
            elif my_bitrate == '96': click("96kbps.png")
            elif my_bitrate == '128': click("128kbps-1.png")
            else: Exit_program('Invalid audioOutputBitrate entered: ' + my_bitrate + ' while audioOutputType is Downmix HE-AAC.', 2)
        else: 
            Cancel_AudioProperties()
            Exit_program('Invalid audioOutputType entered: ' + my_audiotype)
        
#######################################################
#Main program flow
Open_AudioProperties()
Configure_OutputType()
Configure_Bitrate()
Close_AudioProperties()
RunSikuli('apply_changes')
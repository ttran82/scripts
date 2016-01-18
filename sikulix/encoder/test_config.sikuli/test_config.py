def Configure_Resolution():
    outputResolutionDict = {
    #50Hz
    '1920x1080i25':"1920x1080i25_select-1.png", '1440x1080i25':"1440x1080i25_select.png", '1280x1080i25':"1280x1080i25_selection-1.png", '960x1080i25':"960x1080i25_select.png",
    '1280x720p50':"1280x720p50_select.png", '960x720p50':"1442123106003.png",
    '720x576i25':"720x576i25_select.png",'704x576i25':"704x576i25_select.png",'640x576i25':"640x576i25_select.png",'544x576i25':"544x576i25_select.png",'528x576i25':"528x576i25_select.png",'480x576i25':"480x576i25_select.png",'352x576i25':"352x576i25_select.png",
    #50Hz MBR exclusive
    '1920x1080p50':"1920x1080p50_select.png", '1440x1080p50':"1440x1080p50_select.png", '1280x1080p50':"1280x1080p50_select.png", '960x1080p50':"960x1080p50_select.png",
    '720x576p50':"720x576p50_select.png", '704x576p50':"704x576p50_select.png", '640x576p50':"640x576p50_select.png", '544x576p50':"544x576p50_select.png", '528x576p50':"528x576p50_select.png", '480x576p50':"480x576p50_select.png", '352x576p50':"352x576p50_select.png",
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
    '1920x1080i29.97':"1920x1080i2997_select.png",'1440x1080i29.97':"1440x1080i2997_select.png",'1280x1080i29.97':"1280x1080i2997_select.png",'960x1080i29.97':"960x1080i2997_select.png",
    '1280x720p59.94':"1280x720pS994_select.png", '960x720p59.94':"960x720p5994_select.png",
    '720x480i29.97':"720x480i2997_sel2-1.png",'704x480i29.97':"704x480i2997_select.png",'640x480i29.97':"640x480i2997_select.png",'544x480i29.97':"544x480i2997_select.png",'528x480i29.97':"528x480i2997_sel-1.png",'480x480i29.97':"480x480i2997_select.png",'352x480i29.97':"352x480i2997_select.png",
    #60Hz MBR exclusive
    '1920x1080p59.94':"1920x1080p59_select.png", '1440x1080p59.94':"1440x1080p59_select.png", '1280x1080p59.94':"1280x1080p59_select.png", '960x1080p59.94':"960x1080p59_select.png",
    '720x480p59.94':"720x480p5994_select-1.png",'704x480p59.94':"704x480p5994_select-1.png",'640x480p59.94':"640x480p5994_select-1.png",'544x480p59.94':"544x480p5994_select-1.png",'528x480p59.94':"528x480p5994_select-1.png",'480x480p59.94':"480x480p5994_select-1.png",'352x480p59.94':"352x480p5994_select-1.png", 
    '1920x1080p29.97':"1920x1080p29_select.png", '1440x1080p29.97':"1440x1080p29_select.png", '1280x1080p29.97':"1280x1080p29_select.png", '960x1080p29.97':"960x1080p29_select.png",
    '1280x720p29.97':"1280x720p29_select.png", '720x576p29.97':"720x576p29_select.png", '960x544p29.97':"960x544p29_select.png", '720x544p29.97':"720x544p29_select.png", '960x540p29.97':"960x540p29_select.png", 
    '854x480p29.97':"854x480p2997_select.png", '720x480p29.97':"720x480p2997_select.png", '704x480p29.97':"704x480p2997_select.png", '640x480p29.97':"640x480p2997_select.png", '544x480p29.97':"544x480p2997_select.png", '528x480p29.97':"528x480p2997_select.png",
    '800x450p29.97':"800x450p2997_select.png", '768x432p29.97':"768x432p2997_select.png", 
    '720x408p29.97':"720x408p2997_select.png", '704x396p29.97':"704x396p2997_select.png", '640x360p29.97':"640x360p2997_select.png", '480x360p29.97':"480x360p2997_select.png", '448x336p29.97':"448x336p2997_select.png", '480x320p29.97':"480x320p2997_select.png",
    '352x320p29.97':"352x320p2997_select.png", '512x288p29.97':"512x288p2997_select.png", '384x288p29.97':"384x288p2997_select.png", '480x272p29.97':"480x272p2997_select.png", '480x270p29.97':"480x270p2997_select.png", '480x244p29.97':"480x244p2997_select.png",
    '360x240p29.97':"360x240p2997_select.png", '320x240p29.97':"320x240p2997_select.png", '384x216p29.97':"384x216p2997_select.png", 
    '720x480p14.98':"720x480p1498_select.png", '704x480p14.98':"704x480p1498_select.png", '640x480p14.98':"640x480p1498_select.png", '544x480p14.98':"544x480p1498_select.png", '528x480p14.98':"528x480p1498_select.png", '720x408p14.98':"720x408p1498_select.png",
    '704x396p14.98':"704x396p1498_select.png", '640x360p14.98':"640x360p1498_select.png", '480x360p14.98':"480x360p1498_select.png", '448x336p14.98':"448x336p1498_select.png", '480x320p14.98':"480x320p1498_select.png", '352x320p14.98':"352x320p1498_select.png",
    '512x288p14.98':"512x288p1498_select.png", '384x288p14.98':"384x288p1498_select.png", '480x272p14.98':"480x272p1498_select.png", '480x270p14.98':"480x270p1498_select.png", '480x244p14.98':"480x244p1498_select.png", '360x240p14.98':"360x240p1498_select.png",
    '320x240p14.98':"320x240p1498_select.png", '384x216p14.98':"384x216p1498_select.png", 
    }
    #myres = Get_arg('resolution')
    myres = '384x216p12.5'
    #myres = '352x480i29.97'
    if myres:    
        if outputResolutionDict.has_key(myres):
            find("Resolution_label-2.png"); click(Pattern("Resolution_label-2.png").targetOffset(66,-1))
            myresimg = outputResolutionDict.get(myres)
            findresimg =  exists(Pattern(myresimg).exact())
            #try to find 4 more times
            if not findresimg:
                #If selection span more than a whole selection, put it back on top
                if exists(Pattern("expand_bar-1.png").similar(0.90)): 
                    print('I am right here')
                    dragDrop("middle_bar_for_drag-1.png", Pattern("expand_bar-1.png").similar(0.90))
                    findresimg =  exists(Pattern(myresimg).exact())
                    while not findresimg:
                        #if exists(Pattern("bar_down-1.png").exact()): click(Pattern("bar_down-1.png").exact().targetOffset(0,-12)); findresimg =  exists(Pattern(myresimg).exact())   
                        if exists(Pattern("down_arrow_for_clicking.png").exact()): click(Pattern("down_arrow_for_clicking.png").exact().targetOffset(0,-7)); findresimg =  exists(Pattern(myresimg).exact())   
                        else: break;
                    if findresimg:
                        print('Found resolution: ' + myres)
                        click(Pattern(myresimg).exact())
                    else:
                        #Cancel_VideoProperties()
                        print('Failed to find resolution: ' + myres, 1) 
                            
                else:
                    #Cancel_VideoProperties()
                    print('Failed to set resolution: ' + myres, 1)
            else:
                print('Found resolution: ' + myres)
                click(Pattern(myresimg).similar(0.80))
        else:
            #Cancel_VideoProperties()
            print('Unregconized output resolution enter: ' + myres, 2)

Configure_Resolution()

#!/bin/bash
    if [ $# != 1 ] ; then
      echo "Parameter error"
      echo "Usage : $0 you | you1 | you2 | aka | akamai | ustream"
      exit
    fi

    ################### YouTube Settings ###################
    # These data are available to you when you create a Live event in YouTube
    # First Camera - INSERT YOUR OWN DATA
    youtube_auth1='myname.a1b2-c3d4-e5f6-g7h8'
    # Second Camera - Optional
    youtube_auth2=''
    youtube_app='live2'
    serverurl='rtmp://INSERT_YOUTUBE_SERVER_HERE/'$youtube_app
    ################### UStream Settings ###################
    # RTMP URL from your UStream Account : See www.ustream.tv -> Channel -> Remote
#    rtmpurl='rtmp://1.17758740.fme.ustream.tv/ustreamVideo/17758740'
#    rtmpurl='rtmp://eu-london.restream.io/live'
    rtmpurl=$RTMPURL
    # This is your Stream Key : See www.ustream.tv -> Channel -> Remote
#    streamkey='uwYvFgPtmwxbqS7EwLEWYS7HRHrYtUur'
#    streamkey='re_922795_faab96b091e28b98cb33'
    streamkey=$STREAMKEY
    ################### Akamai Settings ###################
    akamai_server='INSERT_YOUR_AKAMAI_SERVER_NAME_HERE'
    akamai_user='INSERT_YOUR_AKAMAI_USER_NAME_HERE'
    akamai_pass='INSERT_YOUR_AKAMAI_PASSWORD_NAME_HERE'
    ########################################################
    # You can change the settings below to suit your needs
    ###################### Settings ########################
    width=1280
    height=720
    audiorate=16000
    channels=1
    framerate='25/1'
    vbitrate=4000
    abitrate=128000
    GST_DEBUG="--gst-debug=flvmux:0,rtmpsink:0"
    ###################### Settings ########################
    ########################################################
    # THe following settings should not be changed
    h264_level=4.1
    h264_profile=main
    h264_bframes=0
    keyint=`echo "2 * $framerate" |bc`
    datarate=`echo "$vbitrate + $abitrate / 1000" |bc`
    flashver='FME/3.0%20(compatible;%20FMSc%201.0)'
    akamai_flashver="flashver=FMLE/3.0(compatible;FMSc/1.0) playpath=I4Ckpath_12@44448"
    ########################################################

    # This will detect gstreamer-1.0 over gstreamer-0.10
    gstlaunch=`which gst-launch-1.0`
    if [ X$gstlaunch != X ] ; then
      VIDEOCONVERT=videoconvert
      VIDEO='video/x-raw, format=(string)BGRA, pixel-aspect-ratio=(fraction)1/1, interlace-mode=(string)progressive'
      AUDIO=audio/x-raw
      # VIDEO=video/x-raw-yuv
      vfid=string
      afid="format=(string)S16LE, "
    else
      gstlaunch=`which gst-launch-0.10`
      if [ X$gstlaunch != X ] ; then
        VIDEOCONVERT=ffmpegcolorspace
        VIDEO='video/x-raw-rgb, bpp=(int)32, depth=(int)32, endianness=(int)4321, red_mask=(int)65280, green_mask=(int)16711680, blue_mask=(int)-16777216, pixel-aspect-ratio=(fraction)1/1, interlaced=(boolean)false'
        AUDIO=audio/x-raw-int
        vfid=fourcc
        afid=""
      else
        echo "Could not find gst-launch-1.0 or gst-launch-0.10. Stopping"
        exit
      fi
    fi

    case $1 in
      you|you1|you2|youtube|youtube1|youtube2)
            if [ $1 = you2 -o $1 = youtube2 ] ; then
              auth="$youtube_auth2"
            else
              auth="$youtube_auth1"
            fi
            if [ X$auth = X ] ; then
              echo "auth was not set YouTube"
              exit 1
            fi
            ENCAUDIOFORMAT='aacparse ! audio/mpeg,mpegversion=4,stream-format=raw'
            videoencoder="x264enc bitrate=$vbitrate key-int-max=$keyint bframes=$h264_bframes byte-stream=false aud=true tune=zerolatency"
            audioencoder="faac bitrate=$abitrate"
            location=$serverurl'/x/'$auth'?videoKeyframeFrequency=1&totalDatarate='$datarate' app='$youtube_app' flashVer='$flashver' swfUrl='$serverurl
            ;;
  ustream)
#            videoencoder="x264enc bitrate=$vbitrate bframes=0 key-int-max=2"
            videoencoder="omxh264enc"
            #ENCAUDIOFORMAT='audio/mpeg'
            #ENCAUDIOFORMAT=mpegaudioparse
            ENCAUDIOFORMAT='aacparse ! audio/mpeg,mpegversion=4,stream-format=raw'
            abitrate=`echo "$abitrate / 1000" | bc`
#            audioencoder="lamemp3enc bitrate=$abitrate ! mpegaudioparse"
            audioencoder="voaacenc bitrate=$abitrate"
            location="$rtmpurl/$streamkey live=1 flashver=$flashver"
            ;;
      aka | akamai)
            videoencoder="x264enc bitrate=$vbitrate bframes=0"
            audioencoder="faac bitrate=$abitrate"
            ENCAUDIOFORMAT='aacparse ! audio/mpeg,mpegversion=4,stream-format=raw'
            stream_key="live=true pubUser=$akamai_user pubPasswd=$akamai_pass"
            location="rtmp://$akamai_server/EntryPoint $stream_key $akamai_flashver"
            ;;
      *)    echo 'Use youtube, akamai or ustream'
            exit
    esac

    ENCVIDEOFORMAT='h264parse ! video/x-h264,level=(string)'$h264_level',profile='$h264_profile
    VIDEOFORMAT=$VIDEO', framerate='$framerate', width='$width', height='$height
    AUDIOFORMAT=$AUDIO', '$afid' endianness=(int)1234, signed=(boolean)true, width=(int)16, depth=(int)16, rate=(int)'$audiorate', channels=(int)'$channels
    TIMEOLPARMS='halignment=left valignment=bottom text="Stream time:" shaded-background=true'
#    VIDEOSRC="videotestsrc pattern=0 is-live=true ! timeoverlay $TIMEOLPARMS"
#    VIDEOSRC="videotestsrc pattern=0 is-live=true"
#    VIDEOSRC="v4l2src device=/dev/video0 ! videoconvert"
    VIDEOSRC="rpicamsrc"
    AUDIOSRC="audiotestsrc is-live=true"
#    AUDIOSRC="alsasrc device=hw:1"

    # ctrsocket must match system socket in running Snowmix
#    ctrsocket=/tmp/live-mixer
    # audiosink must match audio sink in running SNowmix
#    audiosink=1
#    MIXERFORMAT=$VIDEO', bpp=(int)32, depth=(int)32, endianness=(int)4321, format=('$vfid')BGRA, red_mask=(int)65280, green_mask=(int)16711680, blue_mask=(int)-16777216, width=(int)'$width', height=(int)'$height', framerate=(fraction)'$framerate', pixel-aspect-ratio=(fraction)1/1, interlaced=(boolean)false'
#    VIDEOSRC='shmsrc socket-path='$ctrsocket' do-timestamp=true is-live=true'
#    AUDIOSRC="fdsrc fd=0"

    echo $gstlaunch -v $GST_DEBUG                         \
            $AUDIOSRC                          !\
            $AUDIOFORMAT                            !\
            queue                                   !\
            $audioencoder                           !\
            $ENCAUDIOFORMAT                         !\
            queue                                   !\
            mux. $VIDEOSRC                               !\
            $VIDEOFORMAT                            !\
            queue                                   !\
            $VIDEOCONVERT                           !\
            $videoencoder                           !\
            $ENCVIDEOFORMAT                         !\
            queue                                   !\
            flvmux streamable=true name=mux         !\
            queue                                   !\
            rtmpsink location="$location"

    (echo audio sink ctr isaudio 1 ; sleep 10000000 ) | \
        nc 127.0.0.1 9998 | \
    (head -1
     $gstlaunch -v $GST_DEBUG                         \
            $AUDIOSRC                          !\
            $AUDIOFORMAT                            !\
            queue                                   !\
            $audioencoder                           !\
            $ENCAUDIOFORMAT                         !\
            queue                                   !\
            mux. $VIDEOSRC                               !\
            'video/x-h264,width=1280,height=720,framerate=25/1' !\
            'h264parse' !\
            flvmux streamable=true name=mux         !\
            queue                                   !\
            rtmpsink location="$location"
    )

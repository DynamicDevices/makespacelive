#!/usr/bin/python3

import sys
import gi
gi.require_version('Gst', '1.0')
from gi.repository import GObject, Gst

def bus_call(bus, msg, *args):
    # print("BUSCALL", msg, msg.type, *args)
    if msg.type == Gst.MessageType.EOS:
        print("End-of-stream")
        loop.quit()
        return
    elif msg.type == Gst.MessageType.ERROR:
        print("GST ERROR", msg.parse_error())
        loop.quit()
        return
    return True

saturation = -100
def set_saturation(pipeline):
    global saturation
    if saturation <= 100:
      print("Setting saturation to {0}".format(saturation))
      videosrc.set_property("saturation", saturation)
      videosrc.set_property("annotation-text", "Saturation %d" % (saturation))
    else:
      pipeline.send_event (Gst.Event.new_eos())
      return False
    saturation += 10
    return True

# Alex Replayer stream
#STREAM_URL='rtmp://eu-london.restream.io'
#STREAM_KEY='re_929843_ff06cc0803dbf2b80d0d'

# Matt box stream
STREAM_URL='rtmp://10.0.31.212'
STREAM_KEY=''

if len(sys.argv) == 1:
    STREAM_URL += "/" + sys.argv[1]
else:
    STREAM_URL += "/live"

AUDIO_SAMPLING_RATE=16000
#AUDIO_SAMPLING_RATE=44100

# Set to empty if the v4l2src supports h.264 output, otherwise use h/w accelerated encoding
#H264_ENCODER='omxh264enc !'
H264_ENCODER=''

AUDIO_DEVICE=1
AUDIO_BITRATE=128

VIDEO_WIDTH=1280
VIDEO_HEIGHT=720
VIDEO_FRAMERATE=30

if __name__ == "__main__":
    GObject.threads_init()
    # initialization
    loop = GObject.MainLoop()
    Gst.init(None)

    audiostr = "alsasrc device=hw:" + str(AUDIO_DEVICE) + " ! audio/x-raw, format=(string)S16LE, endianness=(int)1234, signed=(boolean)true, width=(int)16, depth=(int)16, rate=(int)" + str(AUDIO_SAMPLING_RATE) + " ! queue ! voaacenc bitrate=" + str(AUDIO_BITRATE) + " ! aacparse ! audio/mpeg,mpegversion=4,stream-format=raw ! queue ! mux. "
    videostr = "v4l2src ! " + H264_ENCODER + " video/x-h264,width=" +str(VIDEO_WIDTH) + ",height=" + str(VIDEO_HEIGHT) + ",framerate=" + str(VIDEO_FRAMERATE) + "/1 ! h264parse ! "
    muxstr = "flvmux streamable=true name=mux ! queue ! "
    sinkstr = "rtmpsink location='" + STREAM_URL + "/" + STREAM_KEY + " live=1 flashver=FME/3.0%20(compatible;%20FMSc%201.0)'"

    # Video -> Restream.io
#    pipelinestr = videostr + muxstr + sinkstr

    # Audio + Video -> Restream.io
    pipelinestr = audiostr + videostr + muxstr + sinkstr

    print("Pipeline stream:")
    print(pipelinestr)

    pipeline = Gst.parse_launch(pipelinestr)

    if pipeline == None:
      print ("Failed to create pipeline")
      sys.exit(0)

    # watch for messages on the pipeline's bus (note that this will only
    # work like this when a GLib main loop is running)
    bus = pipeline.get_bus()
    bus.add_watch(0, bus_call, loop)

# TODO: Changing parameters
#    videosrc = pipeline.get_by_name ("src")
#    videosrc.set_property("saturation", saturation)
#    videosrc.set_property("annotation-mode", 1)

#    sink = pipeline.get_by_name ("s")
#    sink.set_property ("location", "test.mp4")

    # this will call set_saturation every 1s
#    GObject.timeout_add(1000, set_saturation, pipeline)

    # Run the pipeline
    pipeline.set_state(Gst.State.PLAYING)
    try:
        loop.run()
    except Exception as e:
        print(e)

    # All done - cleanup
    pipeline.set_state(Gst.State.NULL)



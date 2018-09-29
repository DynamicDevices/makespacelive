# Alex Replayer stream
export STREAM_URL=rtmp://eu-london.restream.io/live
export STREAM_KEY=re_929843_ff06cc0803dbf2b80d0d

# Matt box stream
#export STREAM_URL=rtmp://10.0.31.212/live
#export STREAM_KEY=

# Try to work around flicker
v4l2-ctl --set-ctrl power_line_frequency=1

export AUDIO_SAMPLING_RATE=16000
#export AUDIO_SAMPLING_RATE=44100

#export H264_ENCODER=omxh264enc !
export H264_ENCODER=

# Cam which outputs in h.264 format (e.g. Logitech c920)
gst-launch-1.0  alsasrc device=hw:2 ! audio/x-raw, format=\(string\)S16LE, endianness=\(int\)1234, signed=\(boolean\)true, width=\(int\)16, \
                depth=\(int\)16, rate=\(int\)$AUDIO_SAMPLING_RATE  ! \
                queue ! voaacenc bitrate=128 ! aacparse ! audio/mpeg,mpegversion=4,stream-format=raw ! \
                queue ! mux. \
                v4l2src ! $H264_ENCODER video/x-h264,width=1280,height=720,framerate=30/1 ! \
                h264parse ! flvmux streamable=true name=mux ! queue ! rtmpsink location=${STREAM_URL}/${STREAM_KEY}' live=1 flashver=FME/3.0%20(compatible;%20FMSc%201.0)'



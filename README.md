# Overview

We host a variety of events at the [DoES Liverpool](https://doesliverpool.com) MakerSpace/Tech. Hub in Liverpool and have been thinking for some time of how we might live stream these.

Being a community of makers it seemed appropriate that we should look at what can be achieved with OpenSource / OpenHardware platforms for live streaming

This would then give us the options of

- streaming events at DoES Liverpool to the wider world (via Twitch, Facebook, Youtube Live, other)
- working with other groups to live stream their events to DoES Liverpool and elsewhere
- other use cases such as video conferencing, monitoring 3D print builds, building security etc.

Such a project may also help to foster links with other Makerspaces to create a "Federation of Makerspaces" where we interact with each other, are aware of each others' capabilities and events

The needs for such an infrastructure are

- very easy to live stream an event
- low cost hardware for live streaming
- easy to remotely access and update firmware on the hardware device
- has to look reasonably professional to viewers (minimal "buffering", options for cuts between multiple video sources.
- accessible to all on the internet
- potential for monetisation of events

## News
 
For a discussion of what we've been up to in the initial stages of the project please see the demonstration we did for the Liverpool Linux User Group (LivLUG) - https://youtu.be/lT5uTzIM5s8

## Device - Hardware

On the device side we are testing with the Raspberry Pi v3 which has Wifi and a GPU core for video encoding acceleration.
We are also testing out whether a Raspberry Pi Zero W is capable enough for livestreaming.

With this platform we can use either a PiCam or a webcam. We've been testing with a Logitech C270, Logitech C920, and PiCams.
Audio is supported from the Logitech webcams and we've successfully tested USB audio adaptors for use with PiCam-based systems

## Device - Firmware

We are using the [Resin.io](https://resin.io/how-it-works) cloud firmware management infrastructure to manage firmware updates and remote access to devices

The live streaming support on the client is based on [GStreamer1.0](https://gstreamer.freedesktop.org/) pipelines.

The Gstreamer pipeline is configured to stream audio/video as [H.264](https://en.wikipedia.org/wiki/H.264/MPEG-4_AVC)/[FLV](https://en.wikipedia.org/wiki/Flash_Video) encoded [RTMP](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol) streams to a configurable internet server

## Device - Enclosures

We're currently looking at a couple of Raspberry Pi Zero enclosure designs.

- PiZero design for PiCam [here](https://www.thingiverse.com/thing:1709013)
- Remixed design for 2xPiZero and PiCam for 360 video experiements [here](https://www.thingiverse.com/thing:3128603)

There are lots of others under various Creative Commons licenses which we are interested in hearing feedback on.

## Cloud RTMP - servers

We have been testing with the [Restream.io](https://restream.io) cloud platform which takes an RTMP stream and will then restream to other cloud endpoints such as [Twitch](https://www.twitch.tv), [Youtube](https://www.youtube.com/live), and [Facebook](https://live.fb.com)

The RTMP Stream URL and Stream Key are configurable and can be pointed to other endpoints easily

## Real time editing

We are currently working on VM images for 

- Local [Nginx](https://www.nginx.com) based RTMP restreaming and transcoding servers
- [OBS Studio](https://obsproject.com) VM image for real time a/v editing for live streams

# Maintainers & Contributers

- Alex J Lennon <ajlennon@dynamicdevices.co.uk>
- Dan Lynch <dan@danlynch.org>
- Matthew Croughan
- Sarat Kumar

# Architecture

Architecture is currently very simple and consists of:

- [Dockerfile.template](./Dockerfile.template) which scripts creation of the Resin.io OS image (this can be recreated manually if you don't want to use Resin - see below)
- Support files from Resin.io [resin-io-connect](https://github.com/resin-io/resin-wifi-connect) project to support local Wifi AP configuration
- [stream.py](./stream.py) Python script which performs all streaming setup and runs the GStreamer1.0 pipeline

# Supported Hardware

Please feel free to test and feed back your successes so we can grow this list

- Raspberry Pi v3 (beta)
- Raspberry Pi Zero W (alpha)

| Camera         | Support     | Status  | Notes                     | Needed Settings                         |
| -------------- | ----------- | ------- | ------------------------- | --------------------------------------- |
| Logitech Fusion| audio/video | alpha   | Device drops off USB bus, | AV_VIDEO_WIDTH=640, AV_VIDEO_HEIGHT=480 |
|                |             |         | Audio clicks              |                                         |
| Logitech C920  | audio/video | alpha   | Audio drops out           |                                         |
| Logitech C270  | audio/video | beta    |                           | AV_AUDIO_SAMPLING_RATE=32000            |
| PiCam          | video       | beta    |                           |                                         |
| PiCam Zero     | video       | alpha   |                           |                                         |


# Installation

## Standalone

Live Streaming support should work on any platform capable of running GStreamer1.0 pipelines. We also require support for Python3 and Python3 GStreamer1.0 bindings for `script.py`

This project is currently focussed on Linux platforms on Raspberry Pi hardware (v3 / Zero W) but there should be no real hurdle in running on other Linux/Embedded Linux platforms or indeed under Windows as GStreamer1.0 and Python are available for Win32.

Different platform builds of GStreamer1.0 can have slightly different plugin naming conventions and/or sometimes plugins can be missing. This may involve a certain amount of hand-rolling. Feel free to raise an issue if you run into trouble.

The [Dockerfile.template)(./Dockerfile.template) contains Docker format scripting to build a Linux image for Raspberry Pi with all needed components, and some optional extras.

At the time of writing you should be able to 

- Grab the current Raspbian image from [here](https://www.raspberrypi.org/downloads/raspbian)
- Write this to a uSD card using `dd` or your flash writing tool of choice e.g. [Etcher](https://etcher.io/)
- Boot up the image and allow it to configure
- Ensure you've set up wired or wireless internet connectivity
- You will need to set `gpu_mem` in the `config.txt` file in the uSD FAT boot partition to e.g. `128`
- You will need to set `start_x=1` in the `config.txt` file in the uSD FAT boot partition if you will be using PiCams.

Then run the following APT command to install needed dependencies. NB. Check the current commit of `Dockerfile.template` for the current command

    apt-get update \
        && apt-get install -y dnsmasq wireless-tools dbus xterm \
                   v4l-utils nano bc wget unzip netcat alsa-utils build-essential git usbutils openssh-server \
                   python3 python3-gi \
                   gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
                   gstreamer1.0-plugins-ugly gstreamer1.0-omx gstreamer1.0-alsa \
                   autoconf automake libtool pkg-config \
                   libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libraspberrypi-dev \
        && apt-get clean

Git clone this repository to have the needed `stream.py` file

    cd ~
    git clone https://github.com/DynamicDevices/makespacelive.git

If using a Picam you will need to build and install the `rpicamsrc` GStreamer1.0 plugin

    cd ~
    git clone https://github.com/thaytan/gst-rpicamsrc.git
    cd gst-rpicamsrc && ./autogen.sh && make && sudo make install

An example setup script would be something like:

    cd ~/makespacelive
    export AV_STREAM_URL=my_stream_url
    export AV_STREAM_KEY=my_stream_key
    ./stream.py

## Resin.io Based

Follow the Resin.io getting started tutorial [here](https://docs.resin.io/learn/getting-started/raspberrypi3/python)

There are a range of example projects. We suggest working through the link above. 

Then you can clone this repository and push it to your Resin.io repo endpoint which will build the Docker container(s) and deploy to your device(s)

    git clone https://github.com/DynamicDevices/makespacelive.git

When the container runs up it will be unable to connect to Wifi and so will start a local Wifi Access Point called "Wifi Connect"

You should connect to this AP with your phone and a page will pop up allowing you to select the Wifi SSSID and enter the correct password.

The device will then connect to the internet and to the Resin.io dashboard.
    
You should end up with a dashboard that looks something like [this](https://image.ibb.co/jxuC9K/resindash.jpg)

![example](https://image.ibb.co/jxuC9K/resindash.jpg)

The last step is to set environment variables for your stream URL and Key as in the [Operation](#Operation) section below

You should do this in your Resin.io dashboard under the 'Service Variables' tab e.g.

![example](https://image.ibb.co/nash9K/resinservicevars2.jpg)

# Operation

- Configure environment variables `AV_STREAM_URL` and `AV_STREAM_KEY` for your RTMP server endpoint

You may choose to create a free [Restream.io](https://restream.io) account for testing. You will first need to add a channel to your Restream.io dashboard (e.g. Twitch or YouTube) and then will be able to see your unique URL and key. Click on the key to make it visible.

- Optionally set other configuration environment variables as needed but defaults should work ok with Restream.io

- Run the `stream.py` script. This will do some detection of connected webcams/Picams and start livestreaming to your configured endpoint

- If using Restream.io you will see the image come up something like [this](https://image.ibb.co/ceRpOe/retreamme.jpg)

![example](https://image.ibb.co/ceRpOe/retreamme.jpg)

# Configuration

Configuration is achieved by setting environment variables prior to running `stream.py`

Currently supported variables are:

| Key                    | Description                              | Default Value            |
|------------------------|------------------------------------------| -------------------------|
| AV_STREAM_URL          | Target for RTMP live stream              | rtmp://10.0.31.212/live  |
| AV_STREAM_KEY          | Stream key if applcable                  |                          |
| AV_DISABLE_AUDIO       | Do not transmit audio                    | 0                        |
| AV_AUDIO_SAMPLING_RATE | Audio sample rate in Hz                  | 16000                    |
| AV_AUDIO_DEVICE        | ALSA audio hardware device               | 1                        |
| AV_AUDIO_BITRATE       | Encoded audio bitrate in kbps            | 128                      |
| AV_VIDEO_SOURCE        | Override the detected video source [TBD] |                          |
| AV_VIDEO_WIDTH         | Width of captured/encoded video          | 1280                     |
| AV_VIDEO_HEIGHT        | Height of captured/encoded video         | 720                      |
| AV_VIDEO_FRAMERATE     | Video frame rate in fps                  | 30                       |
| AV_H264_ENCODER_PARAMS | Extra params for H.264 encoder plugin    |                          |

An example setup script would be something like:

    cd ~/makespacelive
    export AV_STREAM_URL=my_stream_url
    export AV_STREAM_KEY=my_stream_key
    ./stream.py




# Overview

We host a variety of events at the DoES Liverpool makerspace/tech. hub in Liverpool and have been thinking for some time of how we might live stream these.

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

## Device - Hardware

On the device side we are testing with the Raspberry Pi v3 which has Wifi and a GPU core for video encoding acceleration.
We are also testing out whether a Raspberry Pi Zero W is capable enough for livestreaming.

With this platform we can use either a PiCam or a webcam. We've been testing with a Logitech C270, Logitech C920, and PiCams.
Audio is supported from the Logitech webcams and we've successfully tested USB audio adaptors for use with PiCam-based systems

## Device - Firmware

We are using the Resin.io cloud firmware management infrastructure to manage firmware updates and remote access to devices

The live streaming support on the client is based on GStreamer pipelines

The Gstreamer pipeline is configured to stream audio/video as h.264/FLV encoded RTMP streams to a configurable internet server

## Cloud RTMP - servers

We have been testing with the Restream.io cloud platform which takes an RTMP stream and will then restream to other cloud endpoints such as Twitch, Youtube, and Facebook

Stream URL and Stream Key are configurable and can be pointed to other endpoints easily

## Real time editing

We are currently working on VM images for 

- Local Nginx based RTMP restreaming and transcoding servers
- OBS Studio VM image for real time a/v editing for live streams

# Maintainers & Contributers

Alex J Lennon
Dan Lynch
Matthew Croughan
Sarat Kumar

# Installation

[TBD]

# Configuration

[TBD]


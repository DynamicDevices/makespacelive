#!/usr/bin/env bash

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# Choose a condition for running WiFi Connect according to your use case:

# 1. Is there a default gateway?
# ip route | grep default

# 2. Is there Internet connectivity?
# nmcli -t g | grep full

# 3. Is there Internet connectivity via a google ping?
# wget --spider http://google.com 2>&1

# 4. Is there an active WiFi connection?
iwgetid -r

if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
else
    printf 'Starting WiFi Connect\n'
    ./wifi-connect
fi

# Check if we should run up Jupyter kernel on 0.0.0.0:80
if [ ! -z "$DEBUG_RUN_JUPYTER" ]
then
while [ 1 ]
do
    printf Running Jupyter notebook
    jupyter notebook --allow-root --ip=0.0.0.0 --port=80 --NotebookApp.token=''
    printf Sleeping...
    sleep 5
done
fi

# Start your application here.
while [ 1 ]
do
    printf Streaming...
    ./stream.py $RESIN_DEVICE_NAME_AT_INIT
    printf Sleeping...
    sleep 5
done

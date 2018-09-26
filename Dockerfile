FROM resin/raspberrypi-python

# Enable systemd
ENV INITSYSTEM on

# Install Python, GStreamer
RUN apt-get update \
	&& apt-get install -y bc unzip netcat alsa-utils \
	&& apt-get install -y python \
        && apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-omx gstreamer1.0-alsa \
        && apt-get install -y autoconf automake libtool pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libraspberrypi-dev \
	# Remove package lists to free up space
#	&& rm -rf /var/lib/apt/lists/*

# Setup gst-rpicamsrc
RUN git clone https://github.com/thaytan/gst-rpicamsrc.git
RUN cd gst-rpicamsrc && ./autogen.sh && make && make install

# Grab ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
RUN unzip ngrok-stable-linux-arm.zip

# copy current directory into /app
COPY . /app

# run streaming script when container lands on device
#CMD ["/app/streampicam.sh", "ustream"]
CMD ["echo", "Hello World"]

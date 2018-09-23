FROM resin/raspberrypi-python

# Enable systemd
ENV INITSYSTEM on

# Install Python, GStreamer
RUN apt-get update \
	&& apt-get install -y python \
	&& apt-get install -y bc \
        && apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-omx \
	# Remove package lists to free up space
	&& rm -rf /var/lib/apt/lists/*

# copy current directory into /app
COPY . /app

# run python script when container lands on device
CMD ["python", "/app/hello.py"]

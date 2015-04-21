FROM resin/rpi-raspbian:jessie
# Install Python.
RUN apt-get update 
	&& apt-get install -y python
	# Remove package lists to free up space
	&& rm -rf /var/lib/apt/lists/*

ADD . /app

CMD ["python", "/app/hello.py"]

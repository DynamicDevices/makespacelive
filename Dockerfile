FROM resin/rpi-buildstep-armv6hf:latest

# Install Python.
RUN apt-get install -y python python-pip
RUN pip install rpi.gpio

ADD . /app

RUN echo python app/hello.py > /start

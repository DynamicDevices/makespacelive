FROM resin/rpi-raspbian:wheezy

# Install Python.
RUN apt-get update && apt-get install -y python

ADD . /app

CMD ["python", "/app/hello.py"]
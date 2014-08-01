#!/usr/bin/python

import RPi.GPIO as GPIO
from time import sleep

# Needs to be BCM. GPIO.BOARD lets you address GPIO ports by periperal
# connector pin number, and the LED GPIO isn't on the connector
GPIO.setmode(GPIO.BCM)

# set up GPIO output channel
GPIO.setup(16, GPIO.OUT)

while(1):
	# Turn On
	GPIO.output(16, GPIO.LOW)

	# Wait a bit
	sleep(100)

	# Turn Off
	GPIO.output(16, GPIO.HIGH)

	# Wait a bit
	sleep(100)
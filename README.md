# hello-python
This is a barebones resin.io project to demonstrate running python code. 
Currently it is targeting a raspberry pi and builds upon a debian wheezy base image. However, it is easy to 
change this to target any of the other targeted platforms supported by resin.io, all that you need to do is 
change the line:
```
FROM resin/rpi-raspbian:wheezy-2015-01-15
```
to any of the base OS images from the [resin.io docker hub](https://registry.hub.docker.com/repos/resin/).

For an explination on how [resin.io](https://resin.io/) uses Dockerfiles check out the [Dockerfile guide](http://docs.resin.io/#/pages/dockerfile.md)
 . Additionally if you want to learn how to optimise your Dockerfile look over [here](http://docs.resin.io/#/pages/build-optimisation.md)


__Note:__ Obviously apt package manager will only work in Debian environments.



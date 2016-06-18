# Dockermenu

A small application for your mac os x menu bar that lists all running docker containers.
Made because I kept leaving a bunch of running stuff on my old macbook which made all
resources go poof. :fire:

[dockermenu screenshot](screenshot.png)

Clicking an item in the menu will stop that particular container.

## Limitations

Dockermenu has only been tested on my local machine running Mac OS X El Capitan.

I have docker-machine version: 0.7.0, docker version 1.11.2.

Currently dockermenu will try to use the settings from `docker-machine env default` - if your environment is called something else you will have to change it in the code. This is something I'd like to fix eventually.

Dockermenu has not been tested with "Docker for mac" (currently beta at https://beta.docker.com/)

This is my very first Swift experiment, and it was conceived during two afternoons and with a lot of google. => lol code.


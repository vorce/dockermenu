# Dockermenu

A small application for your mac os x menu bar that lists all running docker containers.
Made because I kept leaving a bunch of running stuff on my old macbook which made all
resources go poof. :fire:

![dockermenu screenshot](screenshot.png)

Clicking an item in the menu will stop that particular container.

This is my very first Swift experiment, and it was conceived during two afternoons and with a lot of google. => lol code. 

The project has not been updated in a long time, but it's not dead - I use it every day but haven't seen a need for changing anything.

## Installation

You can either build it yourself (see details further down). Or download
the zip archive from [releases](/releases) and run `dockermenu.app`.

## Build and run

1. Open the project in Xcode
2. Click on the `Product` -> `Archive` menu item
3. Click "Export..."
4. Chose "Export as a Mac Application"

This should generate a `dockermenu.app` ready to be run.

## Known compatibilities

Dockermenu has been tested on my local machine running Mac OS X El Capitan, macOS Sierra, macOS Mojave, and maOS Catalina.

Tested with these docker versions:

- Docker version 17.03.1-ce, build c6d412e
- Docker version 19.03.1, build 74b1e89
- Docker version 19.03.5, build 633a0ea


Using "Docker for mac": https://docs.docker.com/docker-for-mac/



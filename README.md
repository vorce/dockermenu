# Dockermenu

A small application for your mac os x menu bar that lists all running docker containers.
Made because I kept leaving a bunch of running stuff on my old macbook which made all
resources go poof. :fire:

![dockermenu screenshot](screenshot.png)

Clicking an item in the menu will stop that particular container.

## Installation

You can either build it yourself (see section further down). Or download
the zip archive from [releases](/releases) and run `dockermenu.app`.

## Limitations

Dockermenu has only been tested on my local machine running Mac OS X El Capitan, and macOS Sierra.

Tested with this docker version:

	Docker version 17.03.1-ce, build c6d412e

Dockermenu has been tested with "Docker for mac": https://docs.docker.com/docker-for-mac/

This is my very first Swift experiment, and it was conceived during two afternoons and with a lot of google. => lol code.

## Build and run

1. Open the project in Xcode
2. Click on the `Product` -> `Archive` menu item
3. Click "Export..."
4. Chose "Export as a Mac Application"

This should generate a `dockermenu.app` ready to be run.

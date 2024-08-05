#!/bin/bash

echo "Starting VNC server at $RESOLUTION..."
vncserver -kill :1 || true
vncserver -geometry $RESOLUTION -depth 24 &

echo "VNC server started at $RESOLUTION! ^-^"

#
# websockify
#
echo "Starting websockify..."
websockify -D --web=/usr/share/novnc/ 80 localhost:5901

echo "Starting tail -F /dev/null..."
tail -F /dev/null

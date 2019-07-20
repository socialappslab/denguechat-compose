#!/bin/sh
# Replace the following command with your the command that works well in your host machine
IP=`ifconfig | grep -A 1 'en0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 2` 
export HOST_IP=$IP
echo "HOST_IP environment variable set to => " $HOST_IP

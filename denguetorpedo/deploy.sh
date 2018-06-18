#!/bin/bash
cd /home/dengue/denguetorpedo
bundle install
kill -9 `cat /home/dengue/denguetorpedo/tmp/pids/server.pid`
rm /home/dengue/denguetorpedo/tmp/pids/server.pid
rails server -p 3000

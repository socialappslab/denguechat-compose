#!/bin/bash
cd /home/dengue/denguetorpedo
bundle install
kill -9 `cat /home/dengue/denguetorpedo/tmp/pids/server.pid`
rm -f /home/dengue/denguetorpedo/tmp/pids/server.pid
bundle exec foreman start

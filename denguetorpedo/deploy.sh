#!/bin/bash
cd /home/dengue/denguetorpedo
bundle install
kill -9 `cat /home/dengue/denguetorpedo/tmp/pids/server.pid`
rm -f /home/dengue/denguetorpedo/tmp/pids/server.pid
RAILS_ENV=production 
rake assets:precompile
bundle exec foreman start

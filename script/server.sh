#!/bin/bash

case $1 in
  start)
    export RAILS_ENV=production
    rake assets:precompile
    ./script/delayed_job start
    rails s > /dev/null 2>&1 &
    ;;
  stop)
    kill -9 $(cat tmp/pids/server.pid)
    script/delayed_job stop
    ;;
esac

#!/bin/bash

echo -e "Starting Rails Server..."
rm -f /backend/tmp/pids/server.pid
bundle exec rails server -b '0.0.0.0'

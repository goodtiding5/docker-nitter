#!/bin/sh
#
# Help to setup local directories as volumes to the containers
#

echo "Creating dirs .."
mkdir -p ./data/nitter ./data/redis

echo "Modify permissions .."
chmod a+rwx ./data/nitter ./data/redis

echo "Done!"

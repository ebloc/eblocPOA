#!/bin/bash

# See your node on http://ebloc.cmpe.boun.edu.tr:3015
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh

if [ -z "$NAME" ]
then
    echo "E: Fill NAME variable in config.sh. You can run ./initialize.sh"
    exit
fi

if [ -z "$REPODIR" ]
then
    echo "E: Fill `REPODIR` variable in config.sh. You can run ./initialize.sh"
    exit
fi

echo "NAME="$NAME
echo "REPODIR="$REPODIR
echo ""
sudo pm2 delete app
sudo INSTANCE_NAME=$NAME RPC_HOST=localhost \
     WS_SERVER=http://79.123.177.145:3015 \
     WS_SECRET=63r98c3uz0cyg68v \
     RPC_PORT=8545 \
     LISTENING_PORT=3000 \
     pm2 start $REPODIR/eth-net-intelligence-api/app.js

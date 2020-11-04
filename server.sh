#!/bin/bash

connect_peers () {
    echo -e "## Connecting to peers"
    echo "loadScript(\"$DATADIR"/peers.js"\")" | sudo geth --datadir "/private" attach ipc:/private/geth.ipc console
}


# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    echo "E: Please run: sudo ./server.sh";
    exit
fi

SLEEP_DURATION=2
SLEEP_TILL_SERVER_STARTS=1
FILE_IPC=/private/geth.ipc
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh

# Updates peers
(&>/dev/null git fetch --all &)
git checkout origin/master -- peers.js 2>/dev/null
git checkout origin/master -- custom.json 2>/dev/null

if [ -z "$DATADIR" ]
then
    echo "E: Fill DATADIR variable in config.sh. You can run ./initialize.sh"
    exit
fi

if [ -z "$PORT" ]
then
    echo "E: PORT variable is empty, please set"
    exit
else
    echo "PORT="$PORT
fi

pid=$(sudo lsof -n -i :$PORT | grep LISTEN| awk '{print $2}');
if [ -n "$pid" ]; then
  sudo kill -9 $pid
fi

nohup geth --syncmode fast --cache=1024 --shh --datadir /private --port $PORT \
      --rpcaddr 127.0.0.1 --rpc --rpcport $RPCPORT --rpccorsdomain="*" --networkid 23422 \
      --rpcapi admin,eth,net,web3,debug,personal,shh --targetgaslimit '10000000' \
      --gasprice "18000000000" --allow-insecure-unlock> $DATADIR/geth_server.out 2>&1 &

FILE=$DIR/pass.js
if [ ! -f "$FILE" ]; then
    cp .pass.js pass.js
fi

sleep $SLEEP_DURATION
for i in {0..15}
do
    if [ -e "$FILE_IPC" ]; then
        connect_peers
        sleep $SLEEP_TILL_SERVER_STARTS
        # Second time called in case peers are not connected on the first try
        connect_peers
        echo "loadScript(\"$DATADIR"/pass.js"\")" | sudo geth --datadir "/private" attach ipc:/private/geth.ipc console
        echo "net" | sudo geth --datadir "/private" attach ipc:/private/geth.ipc console
        break
    else
        echo -e "Try $i: Sleeping for $SLEEP_DURATION seconds"
        sleep $SLEEP_DURATION
    fi
done

$DIR/stats.sh
sudo chown $(whoami) /private/geth.ipc

# tail -f geth_server.out

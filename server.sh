#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/config.sh

BLUE="\033[1;36m"
NC="\033[0m" # no color

connect_peers () {
    echo -e "## Connecting to peers"
    echo "loadScript(\"$REPODIR"/peers.js"\")" | \
        sudo geth --datadir "$DATADIR" attach ipc:$DATADIR/geth.ipc console
}

# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    echo "E: Please run: sudo ./server.sh";
    exit
fi

SLEEP_DURATION=2
SLEEP_TILL_SERVER_STARTS=1

FILE_IPC=$DATADIR/geth.ipc
echo $FILE_IPC

# update peers
(&>/dev/null git fetch --all &)
git checkout origin/master -- peers.js 2>/dev/null
git checkout origin/master -- custom.json 2>/dev/null

if [ -z "$REPODIR" ]
then
    echo "E: Fill `REPODIR` variable in config.sh. You can run ./initialize.sh"
    exit
fi

if [ -z "$PORT" ]
then
    echo "E: PORT variable is empty, please set"
    exit
else
    printf "${BLUE}==>${NC} PORT=$PORT\n"
fi

pid=$(sudo lsof -n -i :$PORT | grep LISTEN| awk '{print $2}');
if [ -n "$pid" ]; then
    sudo kill -9 $pid
fi

nohup geth --syncmode fast --cache=1024 --shh --datadir /home/alper/.eblocpoa \
      --port $PORT  --rpcaddr 127.0.0.1 --rpc --rpcport $RPCPORT --rpccorsdomain="*" \
      --networkid 23422 --rpcapi admin,eth,net,web3,debug,personal,shh \
      --targetgaslimit '10000000' --gasprice "18000000000" \
      --allow-insecure-unlock > $REPODIR/geth_server.out 2>&1 &

sleep $SLEEP_DURATION
for i in {0..15}
do
    if [ -e "$FILE_IPC" ]; then
        connect_peers
        sleep $SLEEP_TILL_SERVER_STARTS
        connect_peers  # called again in case peers are not connected
        echo "loadScript(\"$DIR"/pass.js"\")" | \
            sudo geth --datadir "$DATADIR" attach ipc:$DATADIR/geth.ipc console

        FILE=$DIR/unlock.js
        if [ -f "$FILE" ]; then
            echo "loadScript(\"$DIR"/unlock.js"\")" | \
                sudo geth --datadir "$DATADIR" attach ipc:$DATADIR/geth.ipc console
        fi
        echo "net" | sudo geth --datadir "$DATADIR" attach ipc:$DATADIR/geth.ipc console | tail -n +10 | head -n -1
        break
    else
        echo -e "Try $i: Sleeping for $SLEEP_DURATION seconds"
        sleep $SLEEP_DURATION
    fi
done

echo "" && $DIR/stats.sh
sleep 0.25
sudo chown $(whoami) $DATADIR/geth.ipc

# tail -f geth_server.out

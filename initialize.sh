#!/bin/bash

read_var () {
    read var

    if [[ $var == *\$* ]]; then
        echo 'Please enter string without a dollar sign'
    fi

    if [[ $var == *\"* ]]; then
        echo 'Please enter string without a double quote sign'
        exit
    fi

    if [[ $var == *\'* ]]; then
        echo 'Please enter string without a single quote sign'
        exit
    fi
}
ebloc_path="$PWD"
var=$(echo $ebloc_path | sed 's/\//\\\//g')

FILE=config.sh
if [ ! -f "$FILE" ]; then
    cp .config.sh config.sh
fi

FILE=pass.js
if [ ! -f "$FILE" ]; then
    cp .pass.js pass.js
fi

sed -i.bak "s/^\(REPODIR=\).*/\1\"$var\"/" config.sh && rm -f config.sh.bak
sed -i.bak "s/^\(REPODIR=\).*/\1\"$var\"/" config.sh && rm -f config.sh.bak
sed -i.bak "s/^\(REPODIR=\).*/\1\"$var\"/" config.sh && rm -f config.sh.bak

read -p "Enter name for eBloc Network Status: " name

name=${name:-myNameIs}
sed -i.bak "s/^\(NAME=\).*/\1\"$name\"/" config.sh && rm -f config.sh.bak

read -p "Enter PORT [30303]: " port
port=${port:-30303}
sed -i.bak "s/^\(PORT=\).*/\1$port/" config.sh && rm -f config.sh.bak

read -p "Enter RPC-PORT [8545]: " rpc_port
rpc_port=${rpc_port:-8545}
sed -i.bak "s/^\(RPCPORT=\).*/\1$rpc_port/" config.sh && rm -f config.sh.bak

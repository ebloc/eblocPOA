#!/bin/bash

DATADIR=/home/alper/.eblocpoa
sudo geth --datadir "$_DATADIR" attach ipc:$DATADIR/geth.ipc console

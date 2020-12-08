#!/bin/bash

sudo killall geth
sudo geth --datadir="/private" init custom.json

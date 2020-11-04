#!/bin/bash

sudo killall geth
geth --datadir="/private" init custom.json

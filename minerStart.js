account=""
passw=""

miner.setEtherbase(account)
personal.unlockAccount(account, passw, 0);
miner.start()

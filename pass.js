function checkAllBalances() {
    var totalBal = 0;
    for (var acctNum in eth.accounts) {
        var acct = eth.accounts[acctNum];
        var acctBal = web3.fromWei(eth.getBalance(acct), "ether");
        totalBal += parseFloat(acctBal);
        console.log("  eth.accounts[" + acctNum + "]: \t" + acct + " \tbalance: " + acctBal + " ether");
    }
    console.log("  Total balance: " + totalBal + " ether");
};

checkAllBalances();

personal.unlockAccount("0xd118b6ef83ccf11b34331f1e7285542ddf70bc49", 'alper', 0);
personal.unlockAccount("0x12ba09353d5c8af8cb362d6ff1d782c1e195b571", 'alper', 0);

const MirToken = artifacts.require("MirToken");
const MirTokenSale = artifacts.require("MirTokenSale");
const TrimMirror = artifacts.require("TrimMirror");


contract('MirTokenSale', (accounts) => {
    let mirTokenSale;
    let mirToken;
    let trimMirror;
    const admin = accounts[0];
    const delegate1 = accounts[1];
    const delegate2 = accounts[2];
    const rewardee100 = accounts[3];
    const rewardee1000 = accounts[4];

    const tokenPrice = 1000000000000000; // 1000000000000000 (10**15) WEI = 0.001 ETH
    it('initializes MIR Token Sale contract with correct values', function () {
        return MirTokenSale.deployed().then(function (instance) {
            mirTokenSale = instance;
            return mirTokenSale.address;
        }).then(function (address) {
            assert.notEqual(address, 0x0, 'has an address...')
            return mirTokenSale.mirToken;
        }).then(function (address) {
            assert.notEqual(address, 0x0, 'has the MIR Token contract...')
            return mirTokenSale.trimMirror;
        }).then(function (address) {
            assert.notEqual(address, 0x0, 'has the trimMirror Token contract...')
            return mirTokenSale.tokenPrice();
        }).then(function (price) {
            assert.equal(price, tokenPrice, 'has correct token prcie...')
        })
    })

    const buyer = accounts[1];
    const numberOfTokensTestBuy = 10;
    const numberOfTokensToTokenSalesContract = 750000;
    it('facilitates token buying', function () {
        return MirToken.deployed().then(function (instance) {
            mirToken = instance;
            return MirTokenSale.deployed();
        }).then(function (instance) {
            mirTokenSale = instance;
            return mirToken.transfer(mirTokenSale.address, numberOfTokensToTokenSalesContract, { from: admin });
        }).then(function () {
            return mirTokenSale.buyTokens(numberOfTokensTestBuy, { from: buyer, value: numberOfTokensTestBuy * tokenPrice });
        }).then(function (receipt) {
            assert.equal(receipt.logs.length, 1, 'triggers one event...');
            assert.equal(receipt.logs[0].event, 'Sell', 'should be the "Sell" event...');
            assert.equal(receipt.logs[0].args._buyer, buyer, 'logs the account that purchased the tokens...');
            assert.equal(receipt.logs[0].args._numberOfTokens, numberOfTokensTestBuy, 'logs the number of tokens purchased...');
            return mirTokenSale.tokensSold();
        }).then(function (amount) {
            assert.equal(amount, numberOfTokensTestBuy, 'increments the number of tokens sold...');
            return mirToken.balanceOf(buyer);
        }).then(function (balance) {
            assert.equal(balance, numberOfTokensTestBuy, 'buyer balance after buyTokens correct...');
            return mirToken.balanceOf(mirTokenSale.address);
        }).then(function (balance) {
            assert.equal(balance, numberOfTokensToTokenSalesContract - numberOfTokensTestBuy, 'MirTokenSale balance after buyTokens correct...');
            return mirTokenSale.buyTokens(numberOfTokensTestBuy, { from: buyer, value: 1 });
        }).then(assert.fail).catch(function (error) {
            assert(error.message.indexOf('revert') >= 0, 'msg.value should not be less than numberOfTokensTestBuy * tokenPrice...');
            return mirTokenSale.buyTokens(800000, { from: buyer, value: numberOfTokensTestBuy * tokenPrice });
        }).then(assert.fail).catch(function (error) {
            assert(error.message.indexOf('revert') >= 0, "can't purchase more token than available...");
        })
    })

    it('rewards as expected', function () {
        return MirToken.deployed().then(function (instance) {
            mirToken = instance;
            return TrimMirror.deployed();
        }).then(function (instance) {
            trimMirror = instance;
            return MirTokenSale.deployed();
        }).then(function (instance) {
            mirTokenSale = instance;
            // Need to approve the delegates first as admin
            return mirToken.approve(delegate1, 100000, { from: admin });
        }).then(function () {
            // Need to approve the delegates first as admin
            return mirToken.approve(delegate2, 100000, { from: admin });
        }).then(function () {
            return mirTokenSale.participateInReward(["rome", "e", "more"], { from: rewardee100 });
        }).then(function (result) {
            assert.equal(result.receipt.status, true, 'rewardee100 added to list...');
            return mirTokenSale.participateInReward(["year", "electricity", "apple"], { from: rewardee1000 });
        }).then(function (result) {
            assert.equal(result.receipt.status, true, 'rewardee1000 added to list...');
            return mirToken.reward100({ from: delegate1 });
        }).then(function (result) {
            assert.equal(result.receipt.status, true, 'reward100 folks rewarded...');
            return mirToken.reward1000({ from: delegate2 });
        }).then(function (result) {
            assert.equal(result.receipt.status, true, 'reward1000 folks rewarded...');
            return mirToken.balanceOf(rewardee100);
        }).then(function (balance) {
            assert.equal(balance, 100, 'rewardee100 receives 100 tokens');
            return mirToken.balanceOf(rewardee1000);
        }).then(function (balance) {
            assert.equal(balance, 1000, 'rewardee1000 receives 1000 tokens');
        })
    })
})

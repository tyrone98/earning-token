const assert = require('assert');
const truffleAssert = require('truffle-assertions');

const imATOM = artifacts.require('IMATOM');

contract('IMATOM', accounts => {
    let token;
    let owner = accounts[0];

    beforeEach('setup contract for each test', async () => {
        token = await imATOM.new({ from: owner });
    })

    it('mint 1000 coin in the first account', async () => {
        await token.mint(accounts[0], 1000, 'cosmosaddress1234', { from: owner });

        let balance = await token.balanceOf.call(accounts[0]);

        assert.equal(balance.toNumber(), 1000, 'Amount wasn\'t correctly mint to the receive');
    });

    it('grow to 1002 coin in the first account after distribute earning 2 coin', async () => {
        await token.mint(accounts[0], 1000, 'cosmosaddress1234', { from: owner });
        await token.distributeEarning(2, { from: owner });

        let balance = await token.balanceOf.call(accounts[0]);

        assert.equal(balance.toNumber(), 1002, 'Amount wasn\'t correctly mint to the receive');
    });

    it('send coin correctly', async () => {
        await token.mint(accounts[0], 1024, 'cosmosaddress1234', { from: owner });
        await token.mint(accounts[1], 1033, 'cosmosaddress1235', { from: owner });

        await token.transfer(accounts[1], 33, { from: accounts[0] });

        let from = await token.balanceOf.call(accounts[0]);
        let to = await token.balanceOf.call(accounts[1]);

        assert.equal(from.toNumber(), 1024 - 33, 'Amount wasn\'t correctly taken from the sender');
        assert.equal(to.toNumber(), 1033 + 33, 'Amount wasn\'t correctly send to the receiver');
    });

    it('total supply can\'t change after transfer coins', async () => {
        await token.mint(accounts[0], 1024, 'cosmosaddress1234', { from: owner });
        await token.mint(accounts[1], 1033, 'cosmosaddress1234', { from: owner });

        let totalSupply1 = await token.totalSupply.call();

        await token.transfer(accounts[1], 33, { from: accounts[0] });

        let totalSupply2 = await token.totalSupply.call();

        assert.equal(totalSupply1.toNumber(), totalSupply2.toNumber(), 'Total supply changed after transfer coins');
    });

    it('should rise by 20% of all of the accounts', async () => {
        await token.mint(accounts[0], 1024, 'cosmosaddress1234', { from: owner });
        await token.mint(accounts[1], 2128, 'cosmosaddress1235', { from: owner });

        let totalSupply = await token.totalSupply.call();

        assert.equal(totalSupply.toNumber(), 1024 + 2128, 'Amount wasn\'t correctly for total supply');

        await token.distributeEarning(Math.trunc((1024 + 2128) * 0.2), { from: owner });

        let balance0 = await token.balanceOf.call(accounts[0]);
        let balance1 = await token.balanceOf.call(accounts[1]);

        assert.equal(balance0.toNumber(), Math.trunc(1024 * 1.2), 'Balance wasn\'t correctly taken from the first account');
        assert.equal(balance1.toNumber(), Math.trunc(2128 * 1.2), 'Balance wasn\'t correctly taken from the second account');
    });

    it('should decrease 10 coins after burn 10 coins', async () => {
        await token.mint(accounts[0], 1024, 'cosmosaddress1234', { from: owner });

        await token.burn(10, "cosmosaddress1234", { from: accounts[0] });

        let balance = await token.balanceOf.call(accounts[0]);
        assert.equal(balance.toNumber(), 1024 - 10, 'Balance wasn\'t correctly after burn 10 coins');
    });
});
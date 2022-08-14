const { assert } = require('chai');
const { contracts_build_directory } = require('../truffle-config');

const Reference = artifacts.require('Reference');

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('Reference', ([deployer, user]) => {
    let reference;

    before(async () => {
        reference = await Reference.deployed();
    });

    describe('deployment', async () => {
        it('deploys successfully', async () => {
            const address = await reference.address;
            assert.notEqual(address, 0x0);
            assert.notEqual(address, '');
            assert.notEqual(address, null);
            assert.notEqual(address, undefined);
        });
    });
});
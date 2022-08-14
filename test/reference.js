const { assert } = require('chai');
const { contracts_build_directory } = require('../truffle-config');

const Reference = artifacts.require('Reference');

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('Reference', ([deployer, address1, address2, address3, address4]) => {
    let reference; // contract instance

    // set of user names and passwords
    let user1 = {
        address: address1,
        name: 'user1',
        password: 'password1'
    };
    let user2 = {
        address: address2,
        name: 'user2',
        password: 'password2'
    };

    let users = [user1, user2]; // user array

    before(async () => {
        reference = await Reference.deployed(); // deploy test contract
    });

    // deployment section
    describe('deployment', async () => {
        // assert that contract is deployed and has an address
        it('deploys successfully', async () => {
            const address = await reference.address;
            assert.notEqual(address, 0x0);
            assert.notEqual(address, '');
            assert.notEqual(address, null);
            assert.notEqual(address, undefined);
        });
    });

    //user section
    describe('users', async () => {
        // assert that user1 is added to the user list
        it('user can be added', async () => {
            await reference.addUser(user1.name, user1.password, { from: user1.address });

            // verify that user1 is in the user list
            const user = await reference.getUser(user1.address);
            assert.equal(user.name, user1.name);
            assert.equal(user.password, user1.password);
        });

        // assert that user1 address cannot be added twice
        it('user already exists', async () => {
            let userExists = false;
            let message = '';
            await reference.addUser(user2.name, user2.password, { from: user1.address })
                .catch((error) => {
                    message = error.reason;
                    userExists = true;
                });
            assert.equal(userExists, true);
            assert.equal(message, 'user_already_exists');
        });
    });
});
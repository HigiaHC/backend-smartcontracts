const uuid = require('uuid');
const { assert } = require('chai');

const References = artifacts.require('References');

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('References', ([deployer, address1, address2, address3, address4]) => {
    let references; // contract instance

    // set of user names and passwords
    let user1 = {
        address: address1,
        name: 'user1',
        password: 'password1',
        token: uuid.v4(),
        patientResourceId: uuid.v4()
    };
    let user2 = {
        address: address2,
        name: 'user2',
        password: 'password2',
        token: uuid.v4(),
        patientResourceId: uuid.v4()
    };

    let users = [user1, user2]; // user array

    let referenceString = uuid.v4(); // reference string
    let referenceString2 = uuid.v4(); // reference string

    before(async () => {
        references = await References.deployed(); // deploy test contract
    });

    // deployment section
    describe('deployment', async () => {
        // assert that contract is deployed and has an address
        it('deploys successfully', async () => {
            const address = await references.address;
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
            await references.addUser(user1.patientResourceId, user1.name, { from: user1.address });
            await references.addUser(user2.patientResourceId, user2.name, { from: user2.address });

            // verify that user1 is in the user list
            const user = await references.getUser({ from: user1.address });
            assert.equal(user.name, user1.name);
        });

        // assert that user1 address cannot be added twice
        it('user already exists', async () => {
            let userExists = false;
            let message = '';
            await references.addUser(user2.name, user2.password, { from: user1.address })
                .catch((error) => {
                    message = error.reason;
                    userExists = true;
                });
            assert.equal(userExists, true);
            // assert.equal(message, 'user_already_exists');
        });
    });

    describe('references', async () => {
        it('user can create a reference', async () => {
            // assert that a reference can be created
            await references.createReference(referenceString, 'success reference', 'patient', 'self', { from: user1.address });

            let referenceIds = await references.listReferenceIds({ from: user1.address });
            assert.equal(referenceIds.includes(referenceString), true);
            assert.equal(referenceIds.includes(user1.patientResourceId), true);
        })

        it('reference already exists', async () => {
            // assert that duplicate reference cannot be added
            let referenceExists = false;
            let message = '';
            await references.createReference(referenceString, 'duplicate reference', 'patient', { from: user1.address })
                .catch((error) => {
                    message = error.reason;
                    referenceExists = true;
                });
            assert.equal(referenceExists, true);
            // assert.equal(message, 'reference_already_exists');
        })
    })

    describe('patients', async () => {
        it('can list patients', async () => {
            let getError = false;
            let patients = await references.listPatients()
                .catch((error) => {
                    getError = true;
                });

            assert.equal(getError, false);
        })
    })

    describe('token and third party', async () => {
        let token = uuid.v4();
        it('can create a token', async () => {
            await references.createToken(token, { from: user1.address });
            let tokens = await references.getToken(token, { from: user1.address });
            assert.equal(tokens.valid, true);
        })

        it('can list patients resources', async () => {
            let resources = await references.listReferencesThird(user1.address, token);
            assert.equal(resources[0].name, 'user1');
            assert.equal(resources[1].name, 'success reference');
        })

        it('user gives invalid token', async () => {
            let isValid = true;
            await references.listReferencesThird(user1.address, uuid.v4())
                .catch(error => {
                    isValid = false;
                })

            assert.equal(isValid, false);
        })
    })
});
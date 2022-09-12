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
        token: uuid.v4()
    };
    let user2 = {
        address: address2,
        name: 'user2',
        password: 'password2',
        token: uuid.v4()
    };

    let users = [user1, user2]; // user array

    let referenceString = uuid.v4(); // reference string

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
            await references.addUser(user1.name, { from: user1.address });
            await references.addUser(user2.name, { from: user2.address });

            // verify that user1 is in the user list
            const user = await references.getUser({ from: user1.address });
            assert.equal(user.name, user1.name);
            // assert.equal(user.password, await reference.encrypt(user1.password));
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
            await references.createReference(referenceString, 'success reference', 'patient', { from: user1.address });

            let referenceIds = await references.listReferenceIds({ from: user1.address });

            assert.equal(referenceIds.includes(referenceString), true);
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
                    console.log(error)
                    getError = true;
                });
            console.log(patients);

            assert.equal(getError, false);
        })
    })

    // auth section
    // describe('authenticate', async () => {
    //     // assert that user1 can authenticate
    //     it('user can authenticate', async () => {
    //         const authenticated = await reference.auth(user1.name, user1.password, user1.token, { from: user1.address });
    //         let result = authenticated.logs[0].args.success;
    //         assert.equal(result, true);

    //         const user = await reference.getUser(user1.address);
    //         assert.equal(user.token.value, await reference.encrypt(user1.token));
    //     });

    //     it('user gives wrong name', async () => {
    //         const authenticated = await reference.auth(user2.name, user1.password, user1.token, { from: user1.address });
    //         let result = authenticated.logs[0].args.success;
    //         assert.equal(result, false);
    //     });

    //     it('user gives wrong password', async () => {
    //         const authenticated = await reference.auth(user1.name, user2.password, user1.token, { from: user1.address });
    //         let result = authenticated.logs[0].args.success;
    //         assert.equal(result, false);
    //     });

    //     it('user does not exist', async () => {
    //         let userExists = true;
    //         let message = '';
    //         await reference.auth(user1.name, user2.password, user1.token, { from: address3 })
    //             .catch((error) => {
    //                 message = error.reason;
    //                 userExists = false;
    //             });
    //         assert.equal(userExists, false);
    //         assert.equal(message, 'user_does_not_exist');
    //     });
    // });

    // reference section
    // describe('create reference', async () => {
    //     // assert that user1 can add a reference
    //     it('user can add a reference', async () => {
    //         // auth user2
    //         const authenticated = await reference.auth(user2.name, user2.password, user2.token, { from: user2.address });
    //         let result = authenticated.logs[0].args.success;
    //         assert.equal(result, true);

    //         // verify that user1 is in the user list
    //         const user = await reference.getUser(user2.address);
    //         assert.equal(user.name, user2.name);


    //         let referenceAdded = await reference.createReference(referenceString, user2.token, { from: user2.address });
    //         let referenceResult = referenceAdded.logs[0].args.success;
    //         assert.equal(referenceResult, true);

    //         // verify that reference1 is in the reference list
    //         const references = await reference.getReferences(user2.token, { from: user2.address });
    //         assert.equal(references.includes(referenceString), true);
    //     });

    //     it('reference already exists', async () => {
    //         let referenceExists = false;
    //         let message = '';
    //         await reference.createReference(referenceString, user2.token, { from: user2.address })
    //             .catch((error) => {
    //                 message = error.reason;
    //                 referenceExists = true;
    //             });
    //         assert.equal(referenceExists, true);
    //         assert.equal(message, 'reference_already_exists');
    //     });

    //     it('user sends invalid token', async () => {
    //         let validToken = true;
    //         let message = '';
    //         await reference.createReference(referenceString, user1.token, { from: user2.address })
    //             .catch((error) => {
    //                 message = error.reason;
    //                 validToken = false;
    //             });
    //         assert.equal(validToken, false);
    //         assert.equal(message, 'invalid_token');
    //     });
    // });

    // describe('get reference', async () => {
    //     it('user can get reference', async () => {
    //         // auth user2
    //         const authenticated = await reference.auth(user2.name, user2.password, user2.token, { from: user2.address });
    //         let result = authenticated.logs[0].args.success;
    //         assert.equal(result, true);

    //         // verify that user1 is in the user list
    //         const user = await reference.getUser(user2.address);
    //         assert.equal(user.name, user2.name);

    //         // verify that reference1 is in the reference list
    //         const references = await reference.getReferences(user2.token, { from: user2.address });
    //         assert.equal(references.includes(referenceString), true);
    //     });

    //     it('user sends invalid token', async () => {
    //         let validToken = true;
    //         let message = '';
    //         await reference.getReferences(user1.token, { from: user2.address })
    //             .catch((error) => {
    //                 message = error.reason;
    //                 validToken = false;
    //             });
    //         assert.equal(validToken, false);
    //         // assert.equal(message, 'invalid_token');
    //     });
    // });
});
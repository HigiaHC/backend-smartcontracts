// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import {StringUtils, ArrayUtils, ByteUtils} from "../utils/Utilities.sol";

contract Reference {
    using StringUtils for *;
    using ArrayUtils for *;
    using ByteUtils for *;

    uint256 public constant UNIX_DAY = 86400;

    enum AccountType {
        Patient,
        Professional
    }

    struct Account {
        address id;
        string name;
        uint256 accountType;
    }

    struct Patient {
        string name;
        bool instanced;
    }

    struct Professional {
        string name;
        string workplace;
        bool instanced;
    }

    Account[] public accounts;
    mapping(address => Patient) public patients;

    constructor() {}

    function addUser(string memory _name) public returns (bool) {
        // check if user is already present
        require(!patients[msg.sender].instanced, "user_already_exists");

        // register user
        accounts.push(
            Account({
                id: msg.sender,
                name: _name,
                accountType: uint256(AccountType.Patient)
            })
        );

        patients[msg.sender].name = _name;
        patients[msg.sender].instanced = true;
        return true;
    }

    function getUser() public view returns (Patient memory) {
        return patients[msg.sender];
    }
}

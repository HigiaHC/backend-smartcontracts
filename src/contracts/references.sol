// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import {StringUtils, ArrayUtils, ByteUtils} from "../utils/Utilities.sol";

contract References {
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

    struct Reference {
        string id;
        string name;
        string resourceType;
        uint256 date;
    }

    Account[] public accounts;
    mapping(address => Patient) public patients;
    mapping(address => Reference[]) public references;
    mapping(address => string[]) public referenceIds;

    modifier requireInstancedPatient() {
        require(patients[msg.sender].instanced, "user_does_not_exist");
        _;
    }

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

    function createReference(
        string memory _id,
        string memory _name,
        string memory _type
    ) public requireInstancedPatient returns (bool) {
        // check if a reference with this id is instanced
        require(
            !referenceIds[msg.sender].contains(_id),
            "reference_already_exists"
        );

        //add reference
        referenceIds[msg.sender].push(_id);

        references[msg.sender].push(
            Reference({
                id: _id,
                name: _name,
                resourceType: _type,
                date: block.timestamp
            })
        );

        return true;
    }

    function listReferenceIds()
        public
        view
        requireInstancedPatient
        returns (string[] memory)
    {
        return referenceIds[msg.sender];
    }

    function listReferences()
        public
        view
        requireInstancedPatient
        returns (Reference[] memory)
    {
        return references[msg.sender];
    }

    function listPatients() public view returns (Account[] memory) {
        return accounts;
    }
}

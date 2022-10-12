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
        string from;
        string resourceType;
        uint256 date;
    }

    struct Token {
        bytes32 token;
        bool valid;
        uint256 validUntil;
        uint256 usesLeft;
        bool instanced;
    }

    Account[] public accounts;
    mapping(address => Patient) public patients;
    mapping(address => Reference[]) public references;
    mapping(address => string[]) public referenceIds;

    //token mappings
    mapping(address => mapping(bytes32 => Token)) public tokens;

    modifier requireInstancedPatient() {
        require(patients[msg.sender].instanced, "user_does_not_exist");
        _;
    }

    constructor() {}

    function addUser(string memory _id, string memory _name) public returns (bool) {
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

        createReference(_id, _name, "Patient", "self");

        return true;
    }

    function getUser() public view returns (Patient memory) {
        return patients[msg.sender];
    }

    function createReference(
        string memory _id,
        string memory _name,
        string memory _type,
        string memory _from
    ) public requireInstancedPatient returns (bool) {
        // check if a reference with this id is instanced
        require(
            !referenceIds[msg.sender].contains(_id),
            "reference_already_exists"
        );

        if(compareStrings(_type, 'Patient') && patients[msg.sender].instanced){
            return false;
        }

        //add reference
        referenceIds[msg.sender].push(_id);

        references[msg.sender].push(
            Reference({
                id: _id,
                name: _name,
                from: _from,
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

    function createToken(string memory _token)
        public
        requireInstancedPatient
        returns (bool)
    {
        bytes32 tokenHash = _token.getHash();

        tokens[msg.sender][tokenHash] = Token({
            token: tokenHash,
            valid: true,
            validUntil: block.timestamp + UNIX_DAY,
            usesLeft: 1,
            instanced: true
        });

        return true;
    }

    function getToken(string memory _tokenString)
        public
        view
        returns (Token memory)
    {
        bytes32 tokenHash = _tokenString.getHash();
        return tokens[msg.sender][tokenHash];
    }

    function validateToken(address _address, string memory _tokenString)
        public
        view
        returns (bool)
    {
        bytes32 tokenHash = _tokenString.getHash();

        Token memory token = tokens[_address][tokenHash];
        require(token.instanced && token.valid, "invalid_token");
        require(token.validUntil >= block.timestamp, "expired_token");

        return true;
    }

    function listReferencesThird(address _patient, string memory _tokenString)
        public
        view
        returns (Reference[] memory)
    {
        bytes32 tokenHash = _tokenString.getHash();

        Token memory token = tokens[_patient][tokenHash];
        require(token.instanced && token.valid, "invalid_token");
        require(token.validUntil >= block.timestamp, "expired_token");

        return references[_patient];
    }

    function createReferenceThird(
        string memory _tokenString,
        string memory _id,
        string memory _name,
        string memory _type,
        string memory _from
    ) public returns (bool) {
        bytes32 tokenHash = _tokenString.getHash();

        Token memory token = tokens[msg.sender][tokenHash];
        require(token.instanced && token.valid, "invalid_token");
        require(token.validUntil >= block.timestamp, "expired_token");

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
                from: _from,
                resourceType: _type,
                date: block.timestamp
            })
        );

        tokens[msg.sender][tokenHash].usesLeft--;
        if (tokens[msg.sender][tokenHash].usesLeft == 0)
            tokens[msg.sender][tokenHash].valid = false;

        return true;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

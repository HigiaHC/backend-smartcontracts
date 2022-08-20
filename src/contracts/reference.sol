// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import "../utils/utilities.sol";

contract Reference {
    using Utilities for *;

    struct User {
        string name;
        string password;
        string token;
        bool isValue;
    }

    mapping(address => User) public users;
    mapping(address => string[]) public references;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    modifier authorizeManager() {
        require(msg.sender == manager);
        _;
    }

    modifier requireRealUser() {
        require(users[msg.sender].isValue, "user_does_not_exist");
        _;
    }

    function contains(string[] memory _array, string memory _term)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i].equals(_term)) {
                return true;
            }
        }
        return false;
    }

    // authenticate a user for token creation
    function auth(
        string memory _name,
        string memory _password,
        string memory _token
    ) public requireRealUser returns (bool) {
        User storage user = users[msg.sender]; // get user from storage

        // check if user has been authenticated
        bool isAuthenticated = user.name.equals(_name) &&
            user.password.equals(_password);

        // if user is authenticated, set token
        if (isAuthenticated) {
            user.token = _token;
            return true;
        }

        return false;
    }

    // create a new user
    function addUser(string memory _name, string memory _password)
        public
        returns (bool)
    {
        // check if user is already registered
        require(!users[msg.sender].isValue, "user_already_exists");

        // register user
        users[msg.sender].name = _name;
        users[msg.sender].password = _password;
        users[msg.sender].isValue = true;
        return true;
    }

    function getUser(address _user) public view returns (User memory) {
        return users[_user];
    }

    function createReference(string memory _reference, string memory _token)
        public
        requireRealUser
        returns (bool)
    {
        // check if user is authorized
        require(users[msg.sender].token.equals(_token), "invalid_token");

        // check if reference is already registered
        require(
            !contains(references[msg.sender], _reference),
            "reference_already_exists"
        );

        // add reference to user's references
        references[msg.sender].push(_reference);
        return true;
    }

    function getReferences(string memory _token)
        public
        view
        requireRealUser
        returns (string[] memory)
    {
        // check if user is authorized
        require(users[msg.sender].token.equals(_token), "invalid_token");

        return references[msg.sender];
    }
}

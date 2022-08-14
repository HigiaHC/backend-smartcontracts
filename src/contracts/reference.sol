// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Reference {
    struct User {
        string name;
        string password;
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

    // VERY IMPORTANT!!!!!!!!!!!!!!!
    // This function should exists only for testing purposes.
    // DO NOT USE IT IN PRODUCTION!
    // function clearUser(address _user)
    //     public
    //     authorizeManager
    //     returns (bool)
    // {
    //     users.delete(_user);
    //     references.delete(_user);
    //     return true;
    // }

    // authenticate a user for token creation
    function auth(string memory _name, string memory _password)
        public
        view
        returns (bool)
    {
        User memory user = users[msg.sender]; // get user from storage
        // check if user has been authenticated
        return
            keccak256(bytes(user.name)) == keccak256(bytes(_name)) &&
            keccak256(bytes(user.password)) == keccak256(bytes(_password));
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
}

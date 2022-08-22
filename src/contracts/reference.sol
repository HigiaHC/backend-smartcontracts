// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

import "../utils/utilities.sol";

contract Reference {
    uint256 public constant UNIX_DAY = 86400;

    struct Token {
        bytes32 value;
        uint256 timestamp;
    }

    struct User {
        string name;
        bytes32 password;
        Token token;
        Token sharingToken;
        bool isValue;
    }

    struct Account {
        address add;
        string name;
    }

    Account[] public accounts;
    mapping(address => User) public users;
    mapping(address => string[]) public references;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    event ActionResult(address user, bool success);

    modifier authorizeManager() {
        require(msg.sender == manager);
        _;
    }

    modifier requireRealUser() {
        require(users[msg.sender].isValue, "user_does_not_exist");
        _;
    }

    function equals(string memory _a, string memory _b)
        private
        pure
        returns (bool)
    {
        return keccak256(bytes(_a)) == keccak256(bytes(_b));
    }

    function equals(bytes32 _a, bytes32 _b) private pure returns (bool) {
        return _a == _b;
    }

    function contains(string[] memory _array, string memory _term)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (equals(_array[i], _term)) {
                return true;
            }
        }
        return false;
    }

    function encrypt(string memory _string) public pure returns (bytes32) {
        return keccak256(bytes(_string));
    }

    // authenticate a user for token creation
    function auth(
        string memory _name,
        string memory _password,
        string memory _token
    ) public requireRealUser returns (bool) {
        User storage user = users[msg.sender]; // get user from storage

        // check if user has been authenticated
        bool isAuthenticated = equals(user.name, _name) &&
            equals(user.password, encrypt(_password));

        // if user is authenticated, set token
        if (isAuthenticated) {
            user.token.value = encrypt(_token);
            user.token.timestamp = block.timestamp;
            emit ActionResult(msg.sender, true);
            return true;
        }

        emit ActionResult(msg.sender, false);
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
        accounts.push(Account({add: msg.sender, name: _name}));

        users[msg.sender].name = _name;
        users[msg.sender].password = encrypt(_password);
        users[msg.sender].isValue = true;
        return true;
    }

    function getUser(address _user) public view returns (User memory) {
        return users[_user];
    }

    function getUsers() public view returns (Account[] memory) {
        return accounts;
    }

    function createReference(string memory _reference, string memory _token)
        public
        requireRealUser
        returns (bool)
    {
        // check if user is authorized
        require(
            equals(users[msg.sender].token.value, encrypt(_token)),
            "invalid_token"
        );
        //TODO: test if token is expired
        // require(
        //     users[msg.sender].token.timestamp + UNIX_DAY > block.timestamp,
        //     "token_expired"
        // );

        // check if reference is already registered
        require(
            !contains(references[msg.sender], _reference),
            "reference_already_exists"
        );

        // add reference to user's references
        references[msg.sender].push(_reference);
        emit ActionResult(msg.sender, true);
        return true;
    }

    function getReferences(string memory _token)
        public
        view
        requireRealUser
        returns (string[] memory)
    {
        // check if user is authorized
        require(
            equals(users[msg.sender].token.value, encrypt(_token)),
            "invalid_token"
        );
        //TODO: test if token is expired
        // require(
        //     users[msg.sender].token.timestamp + UNIX_DAY > block.timestamp,
        //     "token_expired"
        // );

        return references[msg.sender];
    }

    // share functions
    function share(
        string memory _name,
        string memory _password,
        string memory _token
    ) public requireRealUser returns (bool) {
        User storage user = users[msg.sender]; // get user from storage

        // check if user has been authenticated
        bool isAuthenticated = equals(user.name, _name) &&
            equals(user.password, encrypt(_password));

        // if user is authenticated, set token
        if (isAuthenticated) {
            user.sharingToken.value = encrypt(_token);
            user.sharingToken.timestamp = block.timestamp;
            emit ActionResult(msg.sender, true);
            return true;
        }

        emit ActionResult(msg.sender, false);
        return false;
    }

    function createSharedReference(
        string memory _reference,
        string memory _token
    ) public requireRealUser returns (bool) {
        // check if user is authorized
        require(
            equals(users[msg.sender].sharingToken.value, encrypt(_token)),
            "invalid_token"
        );
        //TODO: test if token is expired
        // require(
        //     users[msg.sender].sharingToken.timestamp + UNIX_DAY > block.timestamp,
        //     "token_expired"
        // );

        // check if reference is already registered
        require(
            !contains(references[msg.sender], _reference),
            "reference_already_exists"
        );

        // add reference to user's references
        references[msg.sender].push(_reference);
        emit ActionResult(msg.sender, true);
        return true;
    }

    function sharedReferences(string memory _token)
        public
        view
        requireRealUser
        returns (string[] memory)
    {
        // check if user is authorized
        require(
            equals(users[msg.sender].sharingToken.value, encrypt(_token)),
            "invalid_token"
        );
        //TODO: test if token is expired
        // require(
        //     users[msg.sender].sharingToken.timestamp + UNIX_DAY > block.timestamp,
        //     "token_expired"
        // );

        return references[msg.sender];
    }
}

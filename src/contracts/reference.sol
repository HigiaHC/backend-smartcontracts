// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Reference {
    struct User {
        string name;
        string password;
    }

    mapping(address => User) public users;
    mapping(address => string) public references;
    address public manager;

    constructor() {
        manager = msg.sender;
    }

    function sum(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
}

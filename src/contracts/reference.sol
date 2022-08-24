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

    constructor() {}
}

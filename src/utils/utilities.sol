// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

library Utilities {
    function equals(string memory _a, string memory _b)
        public
        pure
        returns (bool)
    {
        return keccak256(bytes(_a)) == keccak256(bytes(_b));
    }
}

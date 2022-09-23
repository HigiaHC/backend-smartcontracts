// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

library StringUtils {
    function equals(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {
        return keccak256(bytes(_a)) == keccak256(bytes(_b));
    }
}

library ArrayUtils {
    using StringUtils for *;

    function contains(string[] memory _array, string memory _string)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i].equals(_string)) {
                return true;
            }
        }
        return false;
    }
}

library ByteUtils {
    function equals(bytes32 _a, bytes32 _b) internal pure returns (bool) {
        return _a == _b;
    }

    function getHash(string memory _string) internal pure returns (bytes32) {
        return keccak256(bytes(_string));
    }
}

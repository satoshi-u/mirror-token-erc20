//SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2; // string[] as input in trimStringMirroringChars()

contract TrimMirror {
    // concatStrings : joins given input strings and returns output string
    function concatStrings(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    // useum
    function getSlice(
        uint256 begin,
        uint256 end,
        string memory text
    ) internal pure returns (string memory) {
        bytes memory a = new bytes(end - begin);
        for (uint256 i = 0; i < end - begin; i++) {
            a[i] = bytes(text)[i + begin];
        }
        return string(a);
    }

    // Example 1
    // Input: "year", "electricity", "apple" Output: "appectricitear"
    // Example 2
    // Input: "tree", “must”, "museum", "ethereum" Output: "etheresesree"  next->ethereum   prev->museum
    // function trimStringMirroringChars(string[] calldata data) public pure returns (string memory) {}
    // err*** : TypeError: Data location must be "memory" for parameter in function, but "calldata" was given.
    function trimStringMirroringChars(string[] memory data)
        public
        pure
        returns (string memory finalResult)
    {
        // init
        string memory _next;
        string memory _prev;

        string memory next = data[data.length - 1];
        string memory prev = data[data.length - 2];
        bytes memory nextBytes;
        bytes memory prevBytes;
        for (uint256 i = data.length - 1; i > 0; i--) {
            nextBytes = bytes(next);
            prevBytes = bytes(prev);
            uint256 traverseLength;
            if (nextBytes.length > prevBytes.length) {
                traverseLength = prevBytes.length;
            } else {
                traverseLength = nextBytes.length;
            }

            uint256 i_next = nextBytes.length - 1;
            uint256 i_prev = 0;
            uint256 _nextCounter = nextBytes.length;
            uint256 _prevCounter = prevBytes.length;

            _next = next;
            _prev = prev;
            for (uint256 _i = 0; _i < traverseLength; _i++) {
                if (_nextCounter == 0 || _prevCounter == 0) {
                    break;
                }
                if (nextBytes[i_next] == prevBytes[i_prev]) {
                    next = getSlice(0, i_next, _next);
                    if (i_next > 0) {
                        i_next--;
                    }
                    prev = getSlice(i_prev + 1, prevBytes.length, _prev);
                    i_prev++;
                }
                _nextCounter--;
                _prevCounter--;
                finalResult = concatStrings(next, prev);
            }
            if (i == 1) {
                return finalResult;
            }
            next = finalResult;
            prev = data[i - 2];
        }
    }
}

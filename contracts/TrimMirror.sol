//SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2; // string[] as input in trimStringMirroringChars()

contract TrimMirror {
    // reverseStr : Reverses string and returns output string
    function reverseStr(string memory _str)
        internal
        pure
        returns (string memory)
    {
        bytes memory _strBytes = bytes(_str);
        assert(_strBytes.length > 0);
        string memory _tempStr = new string(_strBytes.length);
        bytes memory _newStr = bytes(_tempStr);
        for (uint256 i = 0; i < _strBytes.length; i++) {
            _newStr[_strBytes.length - i - 1] = _strBytes[i];
        }
        return string(_newStr);
    }

    // deleteSubString : deletes (all) given subStr from given str and returns output string, TODO optimise
    function deleteSubString(string memory str, string memory subStr)
        internal
        pure
        returns (string memory)
    {
        bytes memory strBytes = bytes(str);
        bytes memory subStrBytes = bytes(subStr);
        if (subStrBytes.length == 0) {
            return str;
        }
        string memory _newStr = new string(
            strBytes.length - subStrBytes.length
        );
        bytes memory _newStrBytes = bytes(_newStr);

        uint256 i_new = 0; // i_new to keep track of index of _newStr
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] == subStrBytes[0]) {
                // match of first char -> check further
                uint256 _i = i + 1;
                // EDGE CASE
                if (_i == strBytes.length) {
                    // reached end-  of main string - need to exit,
                    if (subStrBytes.length == 1) {
                        // MATCH -> this works when the substr is just 1 letter and present at last of str (st, s)
                        return string(_newStrBytes);
                    } else {
                        // NO-MATCH -> this works when the substr is greater than 1 letter and first letter of substr matches last of str -false (museum mu)
                        _newStrBytes[i_new] = strBytes[i];
                        i_new++;
                        continue;
                    }
                }

                uint256 j = 1;
                for (j = 1; j < subStrBytes.length; j++) {
                    if (strBytes[_i] == subStrBytes[j]) {
                        // match of subseq char -> check further
                        _i++;
                    } else {
                        // match of subseq char failed -> return to where we left
                        break;
                    }
                }

                if (j == subStrBytes.length) {
                    // complete traversal of subStrBytes - match found
                    // skip i and don't copy this subStr into _newStr
                    i = i + (subStrBytes.length - 1);
                } else {
                    // incomplete traversal of subStrBytes - false match
                    // copy this i-th char into _newStr
                    _newStrBytes[i_new] = strBytes[i];
                }
            } else {
                // No match of first char
                // copy this i-th char into _newStr
                _newStrBytes[i_new] = strBytes[i];
                i_new++;
            }
        }
        return string(_newStrBytes);
    }

    // concatStrings : joins given input strings and returns output string
    function concatStrings(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    // compareStrings : compares given input strings a & b and returns bool
    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // getSlice : slices given [str] as per [begin, end] and returns sliced string
    // Note: _bytes[i:j]; // only works with calldata type - we want to work with memory as getSubs() works with memory
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

    // getSubs : takes a string as input and returns all its subsets(reverse order)
    // Note: input str -> memory instead of calldata -> we will need getSubs() for concat_strings other than [calldata data]@trimStringMirroringChars
    function getSubs(string memory str)
        internal
        pure
        returns (string[] memory)
    {
        bytes memory bytes_str = bytes(str);
        uint256 n_str = bytes_str.length;
        string[] memory str_subsets = new string[]((n_str * (n_str + 1)) / 2); // * calldata arrays are read-only.
        uint256 _i = 0;
        for (uint256 i = bytes_str.length; i > 0; i--) {
            for (uint256 j = 0; j < i; j++) {
                // b = b[j:i]; // only works with calldata type
                string memory s = getSlice(j, i, str);
                str_subsets[_i] = s; // str_subsets.push(s) * push is not available outside of storage.
                _i++;
            }
        }
        return str_subsets;
    }

    // getMirrorStrings : takes two string arrays and returns the mirror-sub-strings to be removed as per requirement
    function getMirrorStrings(
        string[] memory prev_subs,
        string[] memory next_subs
    ) internal pure returns (string memory prev_sub, string memory next_sub) {
        for (uint256 i = 0; i < next_subs.length; i++) {
            next_sub = next_subs[i];
            string memory next_sub_r = reverseStr(next_sub);
            for (uint256 j = 0; j < prev_subs.length; j++) {
                prev_sub = prev_subs[j];
                if (compareStrings(next_sub_r, prev_sub)) {
                    return (prev_sub, next_sub);
                }
            }
        }
    }

    // Example 1
    // Input: "year", "electricity", "apple" Output: "appectricitear"
    // Example 2
    // Input: "tree", “must”, "museum", "ethereum" Output: "etheresesree"
    // function trimStringMirroringChars(string[] calldata data) public pure returns (string memory) {}
    // err*** : TypeError: Data location must be "memory" for parameter in function, but "calldata" was given.
    function trimStringMirroringChars(string[] memory data)
        public
        pure
        returns (string memory)
    {
        // iniit
        string memory finalResult = "";
        string memory next = data[data.length - 1];
        string memory prev = data[data.length - 2];

        for (uint256 i = data.length - 1; i > 0; i--) {
            string[] memory next_subs = getSubs(next);
            string[] memory prev_subs = getSubs(prev);
            (string memory prev_sub, string memory next_sub) = getMirrorStrings(
                prev_subs,
                next_subs
            );
            string memory next_trimmed = deleteSubString(next, next_sub);
            string memory prev_trimmed = deleteSubString(prev, prev_sub);

            if (i == 1) {
                finalResult = concatStrings(finalResult, next_trimmed);
                finalResult = concatStrings(finalResult, prev_trimmed);
                return finalResult;
            }
            next = prev_trimmed;
            prev = data[i - 2];
            finalResult = concatStrings(finalResult, next_trimmed);
        }
        return finalResult;
    }
}

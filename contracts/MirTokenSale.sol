// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2; // string[] as input in participateInReward()

import "./MirToken.sol";
import "./TrimMirror.sol";

contract MirTokenSale {
    address admin;
    MirToken public mirToken;
    TrimMirror public trimMirror;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    constructor(
        MirToken _mirToken,
        TrimMirror _trimMirror,
        uint256 _tokenPrice
    ) public {
        admin = msg.sender;
        mirToken = _mirToken;
        trimMirror = _trimMirror;
        tokenPrice = _tokenPrice;
    }

    event Sell(address _buyer, uint256 _numberOfTokens);

    // to buy tokens
    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value >= _numberOfTokens * tokenPrice);
        require(mirToken.balanceOf(address(this)) >= _numberOfTokens);
        require(mirToken.transfer(msg.sender, _numberOfTokens));
        tokensSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
    }

    // to win rewards
    function participateInReward(string[] memory input)
        public
        payable
        returns (bool)
    {
        string memory output = trimMirror.trimStringMirroringChars(input);
        if (bytes(output).length >= 0 && bytes(output).length <= 5) {
            // ser arr in mir-token contract
            mirToken.addInReward100(msg.sender);
        } else {
            // ser arr in mir-token contract
            mirToken.addInReward1000(msg.sender);
        }
        return true;
    }
}

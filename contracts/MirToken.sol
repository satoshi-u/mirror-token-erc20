// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract MirToken {
    address admin;
    string public name = "Mirror Token";
    string public symbol = "MIR";
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    address[] public toReward100;
    address[] public toReward1000;

    // to add 100 tokens rewardee(s) from MirTokenSale Contract
    function addInReward100(address _participant_addr) public returns (bool) {
        toReward100.push(_participant_addr);
    }

    // to add 1000 tokens rewardee(s) from MirTokenSale Contract
    function addInReward1000(address _participant_addr) public returns (bool) {
        toReward1000.push(_participant_addr);
    }

    // struct defining our token delegates
    struct Delegate {
        address addr;
        string name;
        uint256 maxLimitPerTxn;
    }
    Delegate delegate1;
    Delegate delegate2;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        uint256 _initialSupply,
        address _delegate1Addr,
        address _delegate2Addr
    ) public {
        admin = msg.sender;
        totalSupply = _initialSupply; // 1000000 tokens
        balanceOf[msg.sender] = _initialSupply; // allocate initial Supply to admin @contract-creator -> accounts[0]
        delegate1 = Delegate(_delegate1Addr, "delegate1", 100);
        delegate2 = Delegate(_delegate2Addr, "delegate2", 1000);
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value, "Not enough tokens");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Not enough tokens");
        require(allowance[_from][msg.sender] >= _value, "Not enough allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // called by delegate1 to reward 100 tokens to rewardee(s)
    function reward100() public payable returns (bool) {
        uint256 numberOfRewardTokens = 100;
        for (uint256 i = 0; i < toReward100.length; i++) {
            require(
                allowance[admin][delegate1.addr] >= numberOfRewardTokens,
                "Not enough allowance @delegate1"
            );
            require(
                numberOfRewardTokens <= delegate1.maxLimitPerTxn,
                "Exceeded Max Txn Limit @delegate1"
            );
            require(transferFrom(admin, toReward100[i], numberOfRewardTokens));
        }
        // clear reward array
        delete toReward100;
        return true;
    }

    // called by delegate2 to reward 1000 tokens to rewardee(s)
    function reward1000() public payable returns (bool) {
        uint256 numberOfRewardTokens = 1000;
        for (uint256 i = 0; i < toReward1000.length; i++) {
            require(
                allowance[admin][delegate2.addr] >= numberOfRewardTokens,
                "Not enough allowance @delegate2"
            );
            require(
                numberOfRewardTokens <= delegate2.maxLimitPerTxn,
                "Exceeded Max Txn Limit @delegate2"
            );
            require(transferFrom(admin, toReward1000[i], numberOfRewardTokens));
        }
        // clear reward arrays
        delete toReward1000;
        return true;
    }
}

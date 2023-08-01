// SPDX-License-Identifier: UNKNOWN 
pragma solidity 0.8.19;
import "./ERC20interface.sol";
contract LToken is ERC20interface{
    
    string name = "LaserToken";
    string symbol = "LT";
    uint8 public decimals;
    address public owner;
    uint public totalSupply;

    mapping (address => uint256) private balances;
    mapping (address => mapping(address => uint256)) public allowed;

    constructor(uint256 _initialValue, uint8 _decimalUnits){
        decimals = _decimalUnits;
        totalSupply = _initialValue*(10**uint256(decimals));
        balances[owner]= totalSupply;
        owner = msg.sender;
    }
    
    function balanceOf(address _address) public view override returns(uint256) {
        return balances[_address];
    }
        
    function transfer(address _to, uint256 _value) public override returns (bool success){
        //check balance
        require(balances[msg.sender]>= _value,"not enough tokens");
        //transfer amount
        balances[_to]+=_value;
        balances[msg.sender]-=_value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(balances[msg.sender]>= _value, "not enough tokens to be approved");
        allowed[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256 value){
        return allowed[_owner][_spender];

    }
    function transferFrom(address _from, address _to, uint _value)public override returns (bool success){
        
        require(allowance(_from,msg.sender)>=_value, "not enough allowed funds");
        require(balances[_from]>=_value, "not enough funds available");
        
        balances[_to] +=_value;
        balances[_from] -= _value;
        allowed[_from][msg.sender]-=_value;

        emit Transfer(_from, _to, _value);
        return true;
    }
    
    
} 
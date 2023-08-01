// SPDX-License-Identifier: UNKNOWN 
pragma solidity 0.8.19;

interface ERC20interface{
    function balanceOf(address _addr) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    //transferFrom fucntion not mandatory for erc20 but important for defi
    function transferFrom(address _to, address _from, uint _value) external returns(bool successs); 
    function approve( address _spender, uint _value) external returns(bool success);
    function allowance (address owner, address _spender) external view returns (uint remaining);
    
    event Approval (address indexed _owner, address indexed _spender, uint _value);
    event Transfer (address indexed _from, address indexed _to, uint _value);
}
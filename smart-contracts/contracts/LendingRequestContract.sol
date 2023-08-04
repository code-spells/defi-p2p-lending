// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;
import "hardhat/console.sol";
import "./ERC20interface.sol";
contract LendingRequest{
    
    address payable private owner;//Address of owner contract that is allowed to operated this contract.
    address payable private token;//Address of Erc20 contract that is being asked for, in the request.
    address payable private asker;//Eth address  of the asker of the loan
    address payable private lender;//Eth address of the lender of the loan(if any).
    uint public collateral; //amount deposited(in eth) as security.
    uint256 public amountAsked;//amount asked in loan(no. of erc20 tokens). 
    uint256 public paybackAmount;//amount promised to be paid back(on erc20 tokens)
    string public purpose; //purpose of the loan
    uint256 public collateralCollectionTimeStamp;// time after which collateral can be collected by the lender

    bool public moneyLent;
    bool public debtSettled;
    bool public collateralCollected;

    constructor(
        address payable _asker,
        uint256 _amountAsked,
        uint256 _paybackAmount,
        string memory _purpose,
        address payable _owner,
        address payable _token,
        uint256 _collateral,
        uint256 _collateralCollectionTmeStamp
    ) payable {
        asker = _asker;
        amountAsked = _amountAsked;
        paybackAmount = _paybackAmount;
        purpose = _purpose;
        owner = _owner;
        token = _token;
        collateral= _collateral;
        collateralCollectionTimeStamp = _collateralCollectionTmeStamp;
    } 

    modifier onlyOwner(){
        require(msg.sender == owner, "unauthoriozed acess");
        _;
    }

    function lend(address payable _lender) external onlyOwner returns  (bool success){
        //check that lener is not the asker
        require(_lender!=asker, "lender and asker can not be the same" );
        //check money is not lent already
        require(!moneyLent, "money already lent");
        //collateral is not yet collected
        require(!collateralCollected,"collateral already collected or request cancelled");

        uint balance = ERC20interface(token).allowance(_lender, address(this));
        require(balance>=amountAsked,"not enought balance to lend money");
        require(ERC20interface(token).transferFrom( _lender, asker, amountAsked), "transfer failed");
        moneyLent = true;
        lender = _lender;

        return true;
    } 

    function payback (address payable _asker) external onlyOwner returns (bool success){
        require(_asker == asker, "invalid asker");
        require (moneyLent && !debtSettled, "no current loAN");
        require (!collateralCollected,"collateral already colleted");

        uint balance = ERC20interface(token).allowance(_asker, address(this));
        require(balance>=paybackAmount,"not enought balance to payback money");
        require(ERC20interface(token).transferFrom( _asker, lender, paybackAmount), "transfer failed");
        debtSettled =true;

        //return collateral
        _asker.transfer(address(this).balance);
        collateral -= address(this).balance;
        
        return true;

    }

    function collectCollateral(address payable _lender) external onlyOwner returns (bool success){
        require (_lender == lender,"invalid lender");
        require(moneyLent ==true && debtSettled ==false, "money not lent" );
        require (!collateralCollected, "collateral already collected");
        require (block.timestamp>= collateralCollectionTimeStamp, "too soon to collect collateral");

        collateralCollected = true;
        _lender.transfer(address(this).balance);
        return true;
    }

    function cancelRequest(address _asker) external onlyOwner returns(bool success){
        require (_asker == asker, "invalidasker");
        require (moneyLent == false && debtSettled == false && collateralCollected == false, "can not cancel now" );

        collateralCollected = true;
        asker.transfer(address(this).balance);
        collateral -= address(this).balance;

        return true;
    }

    function getRequestParameters() external onlyOwner view returns(
        address payable, address payable, uint256, uint256, string memory
    ){
        return  (asker, lender, amountAsked, paybackAmount, purpose);
    }

    function getRequestState() external onlyOwner view returns (
        bool, bool, uint256, bool, uint256, uint256
    ){
        return (moneyLent, debtSettled, collateral, collateralCollected,collateralCollectionTimeStamp, block.timestamp);
    }
    
}
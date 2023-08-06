// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.8.19;

/*
an abstract contract is a contract that never gets deployed on a blockchain network as an individual contract.
it is just a piece of code that is used elsewhere in other files thats part of inheritance.
requestFactory is going to be consumed by the top wrapper (DEFI PLATFORM contract) which will built the defi platform.
as part of DEFI PLATFORM contract, we will be consuming this requestFactory. 
since there's no need to instantiated or deployed on a network, we can define this safely as an abstract contract.
there's no constructor in an abstract contract as it is not deployed on a network.
*/

import "hardhat/console.sol";
import "./LendingRequestContract.sol";

abstract contract RequestFactory{
    function createLendingRequest(
        uint256 _amount,
        uint256 _paybackAmount,
        string memory _purpose,
        address payable _origin,
        address payable _token,
        uint256 _collateral,
        uint256 _collateralCollectionTimeStamp
    ) internal returns (address payable lendingRequest){
        return lendingRequest = payable(address(uint160(address(  
            //solidity suppports atomic changes in datatypes to change from hexstring to address payable and other similar conversions.
            new LendingRequest{value:msg.value}(
            //value:msg.value is a new thing used here. this is how we provide the ethers to a new contract which is available in tx context.
                _origin,
                _amount,
                _paybackAmount,
                _purpose,
                payable(address(this)),
            //this address belongs to the current contract which calls this function, supposed to be requestfactory but since it's an
            //abstract contract, this is address of the contract calling this contract function,i.e,in our case, the defi platform contract.
                _token,
                _collateral,
                _collateralCollectionTimeStamp
            )
        ))));
    }
}
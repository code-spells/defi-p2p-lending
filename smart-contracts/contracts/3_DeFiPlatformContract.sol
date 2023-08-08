// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.8.19;
import "hardhat/console.sol";
import "./LendingRequestContract.sol";
import "./RequestFactoryAbstract.sol";
import "./2_GovernanceContract.sol";


contract DefiPlatform is RequestFactory{
    event LoanAsked();
    event LoanGiven();
    event LoanReturned();
    event LoanDefaulted();
    event LoanAskCancelled();
    
    address[] private lendingRequests;
    mapping(address => uint256) private requestIndex;
    mapping(address => uint256) private userRequestCount;
    mapping(address => bool) private validRequests;

    address private governance;

    constructor( address _governance){
        governance = _governance;
    }
    /**
    this entire smart contract is acting like a wrapper, it will be passing on the queries through these funtions from the user to
    lendingRequestContract by adding either a few extra validations on it or making certain incriments to certain mappings and arrays
    that we are tracking, so that we can show these to the end users and also adding a level of governance by including the overnance
    smart contract.  
     */
    function ask 
    (uint256 _amount, uint256 _paybackAmount, string memory _purpose,
     address payable _token, uint256 _collateralCollectionTimeStamp) external payable{
        //get if valid
        bool isPlatformEnabled = Governance(governance).isPlatformEnabled();
        require (isPlatformEnabled,"new loan requests are currently disabled");
        //validate the input parameters
        require(_amount>0,"loan amount not valid");
        require(_paybackAmount>_amount,"payback amount should be more than the loan ask amount");
        require(msg.value>0,"some ether collateral must be included as part of the loan ask request");

        address payable requestContract = createLendingRequest(
            _amount,
            _paybackAmount,
            _purpose,
            payable(msg.sender),
            _token,
            msg.value,
            _collateralCollectionTimeStamp);

        userRequestCount[msg.sender] ++; // no. of requests per user

        requestIndex[requestContract]= lendingRequests.length; 
        lendingRequests.push(requestContract);
        validRequests[requestContract] = true;

        emit LoanAsked();
    }

    function lend(address payable _requestContractAddress) external returns(bool result) {
        require(validRequests[_requestContractAddress],"no a valid request");
        bool success = LendingRequest(_requestContractAddress).lend(payable(msg.sender));
        require(success,"lending failed");

        emit LoanGiven();
        return true;
    }

    function payback (address payable _requestContractAddress) external returns(bool result) {
        require(validRequests[_requestContractAddress],"no a valid request");
        bool success = LendingRequest(_requestContractAddress).payback(payable(msg.sender));
        require(success,"payback failed");

        emit LoanReturned();
        return true;
    }

    function collectCollateral(address payable _requestContractAddress) external returns(bool result) {
        require(validRequests[_requestContractAddress],"no a valid request");
        bool success = LendingRequest(_requestContractAddress).collectCollateral(payable(msg.sender));
        require(success,"collateral collection failed");

        emit LoanDefaulted();
        return true;
    }

    function cancelRequest(address payable _requestContractAddress) external returns(bool result) {
        require(validRequests[_requestContractAddress],"no a valid request");
        bool success = LendingRequest(_requestContractAddress).cancelRequest(msg.sender);
        require(success,"request cancellation failed");

        emit LoanAskCancelled();
        return true;
    } 

    function removeRequest(address _requestContractAddress, address _asker) private {
        
        userRequestCount[_asker] --;
        uint256 idx= requestIndex[_requestContractAddress];
        if(lendingRequests[idx] == _requestContractAddress){
            requestIndex[lendingRequests[lendingRequests.length-1]] = idx;
            lendingRequests[idx] = lendingRequests[lendingRequests.length-1];
            lendingRequests.pop();
        }

        validRequests[_requestContractAddress]= false;

    } 
   
    function getRequestParameters(address payable _requestContractAddress) external view returns (
        address asker, address lender, uint256 askAmount, uint256 paybackAmount,string memory purpose) {
        (asker, lender, askAmount, paybackAmount, purpose) = LendingRequest(_requestContractAddress).getRequestParameters();
    }

    function getRequestState(address payable _requestContractAddress) external view returns (
        bool moneyLent, bool debtSettled, uint256 collateral, bool collateralCollected, uint256 collateralCollectionTimeStamp,
         uint256 currentTimeStamp) {
        return LendingRequest(_requestContractAddress).getRequestState();
    }

    function getCollateralBalance(address _requestContractAddress) external view returns(uint256) {
        return address(_requestContractAddress).balance;
    }


    function getRequests() external view returns(address[] memory) {
        return lendingRequests;
    }
} 
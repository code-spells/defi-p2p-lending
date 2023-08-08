// SPDX-License-Identifier: UNLICENSED 
pragma solidity 0.8.19;
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
contract Governance is Initializable {

    uint16 max_flagging;
    uint16 currentFlags;
    bool public isPlatformEnabled;

    function initialize(uint16 _max_flagging) public initializer {
        max_flagging = _max_flagging;
        currentFlags = 0;
        isPlatformEnabled = true;
    }

    function flag() external returns(bool _success){

        currentFlags += 1;

        if (currentFlags > max_flagging){
            isPlatformEnabled = false;
            currentFlags = 0;
        }

        return true;

    }

   /* function enableFlag() external returns(bool _success){

        currentFlags += 1;

        if (currentFlags > max_flagging){
            isPlatformEnabled = true;
            currentFlags = 0;
        }

        return true;

    }*/
    function changePlatformState(bool newState) external returns(bool _success){
        isPlatformEnabled = newState;
        return true;
    }

}
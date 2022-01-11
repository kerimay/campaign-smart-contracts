// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Enrollment is Wallet {
    
    uint32 defaultUsage;
    mapping(address => uint256) public initialUsageCount;
    mapping(address => bool) public enrollmentAttendance;
    
    Item[] enrollmentBenefits;
    
    constructor (uint32 _defaultUsage, Item[] memory _benefits) {
        defaultUsage = _defaultUsage;
        
        for (uint k=0; k<_benefits.length; k++) {
            enrollmentBenefits.push(_benefits[k]);
        }
    }
    
    function joinEnrollmentCampaign(address _user) public {
        require(enrollmentAttendance[_user] == false, "You always attended, you can't attend anymore.");
        initialUsageCount[_user] = defaultUsage;
        enrollmentAttendance[_user] = true;
    }
    
    function isAvailable(address _user) view internal returns (bool) {
        require(enrollmentAttendance[_user] == true, "Enrollment campaign should be attended.");
        if (initialUsageCount[_user] > 0) {
            return true;
        }
        return false;
    }
    
    function buyItemAndGetBenefit(address _user, Item memory _item) public {
        require(isAvailable(_user) == true, "Enrollment campaign has been used already.");
        
        addItemToWallet(_user, _item);
        initialUsageCount[_user]--;
        
        for (uint i = 0; i < enrollmentBenefits.length; i++) {
            addItemToWallet(_user, enrollmentBenefits[i]);
        }
    }
}
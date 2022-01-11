// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;


import "./Barter.sol";
import "./PointBarter.sol";
/*import "./Enrollment.sol";
import "./Checklist.sol";
import "./Lottery.sol";*/

contract Distribution {
    Barter barter;
    PointBarter pointBarter;
    
    struct _Distribution {
        string component;
        uint256 ratio;
    }
    
    _Distribution[] public comps;
    
    constructor(_Distribution[] memory terms) {
        uint256 ratioSum;
        for (uint i = 0; i < terms.length; i++) {
            ratioSum += terms[i].ratio;
            comps.push(terms[i]);
        }
        require(ratioSum == 100, "Make sure ratio sum is 100");
    }
    
    // For a production ready software, there should an oracle be used
    function findTheComponent() internal view returns (string memory) {
        uint256 sum = 0;
        uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % 100;

        for (uint i = 0; i < comps.length; i++) {
            sum += comps[i].ratio;
            if (sum > randomnumber) {
                return comps[i].component;
            }
        }
    }
    
    function distributeToTheCampaign(address _user) public {
        string memory newComp = findTheComponent();
        
        if (keccak256(bytes(newComp)) == keccak256(bytes("barter"))) {
            barter.getBenefit(_user);
        } else if (keccak256(bytes(newComp)) == keccak256(bytes("pointBarter"))) {
            pointBarter.getPointBarterBenefit(_user);
        }
    }
}
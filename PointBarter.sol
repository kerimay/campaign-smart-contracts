// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./Token.sol";
import "./Wallet.sol";

contract PointBarter is Token {
    
    mapping(string => uint256) public inputs;
    mapping(string => uint256) public outputs;
    
    uint256 public inputToken;
    Item[] public outputList;


    
    constructor (uint256 requiredTokenAmount, Item[] memory _outputs) Token("CampaignToken", "CAMPAIGN", 18, 1000000000000000000000000) {
        require(requiredTokenAmount > 0, "Some token input should be added");
        inputToken = requiredTokenAmount;
        
        for (uint i=0; i<_outputs.length; i++) {
            outputs[_outputs[i].itemId] = _outputs[i].quantity;
            outputList.push(_outputs[i]);
        }
    }
    
   function addInputToken(uint256 tokenAmount) private onlyOwner {
        inputToken += tokenAmount;
    }
    
    function addOutput(string memory _itemId, uint _quantity) private onlyOwner {
        outputs[_itemId] = _quantity;
    }
    
    function checkPointBarterAvailability(address _user) public view returns (bool) {
        return balanceOf[_user] >= inputToken;
    }
    
    function getPointBarterBenefit(address _user) public {
        require(checkPointBarterAvailability(_user) == true, "Token balance is not enough for the campaign");
        _transfer(_user, address(this), inputToken);
        
        for (uint i = 0; i < outputList.length; i++) {
            addItemToWallet(_user, outputList[i]);
        }
    }
}
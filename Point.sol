// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";
import "./Token.sol";

contract Point is Wallet, Token {
    using SafeMath for uint;
    
    struct ItemPoint {
        string itemId;
        uint256 point;
    }
    
    mapping(string => uint256) public pointTable;

    constructor() Token("CampaignToken", "CAMPAIGN", 18, 1000000000000000000000000) {
        
    }
    
    function definePointTerms(ItemPoint[] memory _points) public onlyOwner {
        for (uint i=0; i<_points.length; i++) {
            pointTable[_points[i].itemId] = _points[i].point; 
        }
    }

    function findEqualPoint(string memory _itemId, uint256 _quantity) public view returns (uint256) {       
        uint256 totalPoint;

        require(pointTable[_itemId] > 0, "Given item doesn't have points in the table");
        totalPoint = pointTable[_itemId].mul(_quantity);
        return totalPoint;
    }

    function earnTokens(address _to, Item[] memory itemStruct) public {
        require(_to != address(0));
        
        for (uint i=0; i<itemStruct.length; i++) {
            uint256 totalPoint;    
            totalPoint = findEqualPoint(itemStruct[i].itemId, itemStruct[i].quantity);
            require(getBalance(address(this)) >= totalPoint, "Not enough token reserves in the contract");
            _transfer(address(this), _to, totalPoint);    
        }
        spendItems(_to, itemStruct);
    }
    
}

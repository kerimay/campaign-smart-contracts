// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Lottery is Wallet {
    
    mapping(string => uint256) public lotteryInputs;
    mapping(string => uint256) public lotteryOutputs;

    Item[] lotteryInputList;
    Item lotteryOutput;
    
    address[] public lotteryParticipants;
    
    
    constructor (Item[] memory _inputs, Item memory _output) {
        for (uint i=0; i<_inputs.length; i++) {
            lotteryInputs[_inputs[i].itemId] = _inputs[i].quantity;
            lotteryInputList.push(_inputs[i]);
        }
            lotteryOutputs[_output.itemId] = _output.quantity;
            lotteryOutput = _output;
    }
    
    
    function checkLotteryAvailability(address _user) public returns (bool) {
        Consumer storage consumer = consumers[_user];

        for (uint i = 0; i<lotteryInputList.length; i++) {
            if  (containsItem[_user][lotteryInputList[i].itemId] == false) {
                require(containsItem[_user][lotteryInputList[i].itemId] = true, "Required input item does not exist in the consumer wallet");
            }
            for (uint k = 0; k<consumer.itemStructs.length; k++) {
                if (keccak256(bytes(consumer.itemStructs[k].itemId)) == keccak256(bytes(lotteryInputList[i].itemId))) {
                    require(consumer.itemStructs[k].quantity >= lotteryInputList[i].quantity);
                }
            }
        }
        
        return true;
    }
    
    function participateInLottery(address _user) public {
        require(checkLotteryAvailability(_user) == true, "User does not have enough items");
        spendItems(_user, lotteryInputList);

        lotteryParticipants.push(_user);        
    }
    
    function getParticipants() public view returns (address[] memory) {
        return lotteryParticipants;
    }
    
    function doTheLottery() public onlyOwner returns (address) {
        uint256 len = lotteryParticipants.length;
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % len;
        address winner = lotteryParticipants[randomIndex];
        
        addItemToWallet(winner, lotteryOutput);
        return winner;
    }
}
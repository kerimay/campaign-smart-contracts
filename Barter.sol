// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;


import "./Wallet.sol";

contract Barter is Wallet {
    
    mapping(string => uint256) public inputs;
    mapping(string => uint256) public outputs;

    Item[] inputList;
    Item[] outputList;
    
    constructor (Item[] memory _inputs, Item[] memory _outputs) public {
        for (uint i=0; i<_inputs.length; i++) {
            inputs[_inputs[i].itemId] = _inputs[i].quantity;
            inputList.push(_inputs[i]);
        }
        
        for (uint i=0; i<_outputs.length; i++) {
            outputs[_outputs[i].itemId] = _outputs[i].quantity;
            outputList.push(_outputs[i]);
        }
    }

    function addInput(string memory _itemId, uint _quantity) private onlyOwner {
        inputs[_itemId] = _quantity;
    }
    
    function addOutput(string memory _itemId, uint _quantity) private onlyOwner {
        outputs[_itemId] = _quantity;
    }
    
    function checkCampaignAvailability(address _user) public returns (bool) {
        Consumer storage consumer = consumers[_user];

        for (uint i = 0; i<inputList.length; i++) {
            if  (containsItem[_user][inputList[i].itemId] == false) {
                require(containsItem[_user][inputList[i].itemId] = true, "Required input item does not exist in the consumer wallet");
            }
            for (uint k = 0; k<consumer.itemStructs.length; k++) {
                if (keccak256(bytes(consumer.itemStructs[k].itemId)) == keccak256(bytes(inputList[i].itemId))) {
                    require(consumer.itemStructs[k].quantity >= inputList[i].quantity);
                }
            }
        }
        
        return true;
    }
    
    function getBenefit(address _user) public {
        Consumer storage consumer = consumers[_user];

        require(checkCampaignAvailability(_user) == true);
        spendItems(_user, inputList);
        for (uint i = 0; i < outputList.length; i++)
        addItemToWallet(_user, outputList[i]);
    }
    
}
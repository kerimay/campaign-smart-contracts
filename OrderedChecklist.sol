// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Checklist is Wallet {
    
    mapping(address => mapping(uint256 => bool)) public consumerTaskState;
    mapping(address => bool) public consumerChecklistDone;

    Item[] checklistTasks;
    Item[] checklistBenefits;
    
    constructor (Item[] memory _tasks, Item[] memory _benefits) {
        for (uint i=0; i<_tasks.length; i++) {
            checklistTasks.push(_tasks[i]);
        }
        
        for (uint k=0; k<_benefits.length; k++) {
            checklistBenefits.push(_benefits[k]);
        }
    }
    
    function checkIfTheTaskIsAvailable(address _user, Item memory _item) private returns (bool) {
        require(consumerChecklistDone[_user] == false);
        
        for (uint i=0; i<checklistTasks.length; i++) {
            if (consumerTaskState[_user][i] == false) {
                require(keccak256(abi.encodePacked(checklistTasks[i].itemId,checklistTasks[i].quantity)) == keccak256((abi.encodePacked(_item.itemId, _item.quantity))), "Tasks should be done in order");
                return true;
            }
        }
        return false;
    }

    function doTask(address _user, Item memory _item) public {
        require(checkIfTheTaskIsAvailable(_user, _item) == true, "Task is not available");
        for (uint i = 0; i < checklistTasks.length; i++) {
            if (keccak256(abi.encodePacked(checklistTasks[i].itemId,checklistTasks[i].quantity)) == keccak256((abi.encodePacked(_item.itemId, _item.quantity)))) {
                consumerTaskState[_user][i] = true;
                if (i == checklistTasks.length-1) {
                consumerChecklistDone[_user] = true;
            }
            }
        }
    }

    function getBenefits(address _user) public {
        require(consumerChecklistDone[_user] == true, "Checklist tasks should be done");
        for (uint i = 0; i < checklistBenefits.length; i++) {
            addItemToWallet(_user, checklistBenefits[i]);
        }
        resetChecklistForUser(_user);
    }
    
    function resetChecklistForUser(address _user) private {
        for (uint i = 0; i < checklistTasks.length; i++) {
            consumerTaskState[_user][i] = false;
        }
        consumerChecklistDone[_user] = false;
    }
    
}
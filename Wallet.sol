// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Wallet {
    using SafeMath for uint;

    struct Consumer {
        string id;
        Item[] itemStructs;
    }

    struct Item {
        string itemId;
        uint quantity;
    }

    address public walletContract = address(this);
    address owner;
    mapping(address => Consumer) public consumers;
    mapping(address => mapping(string => bool)) public containsItem;
    mapping(uint256 => Item) public itemIndex;
    string[] public itemList;
    address[] public consumerAccounts;
    Item[] public itemArray;

    constructor() public {
        owner = msg.sender;
    }
    function createConsumer(address _address, string memory consumerId) public onlyOwner {
        Consumer storage consumer = consumers[_address];
        consumer.id = consumerId;
        consumerAccounts.push(_address);
    }

    function createItem(string memory _itemId, uint256 _index) public onlyOwner {
        Item storage item = itemIndex[_index];
        item.itemId = _itemId;
        itemList.push(_itemId);
    }

/*
    // TODO: not public
    function getConsumerData(address _address) public view returns (Consumer memory) {
        return consumers[_address];
    }
*/

    function addItemToWallet(address _address, Item memory _item) public {
        Consumer storage consumer = consumers[_address];
        bool isAdded = false;

        for (uint i = 0; i < consumer.itemStructs.length; i++) {
            if (keccak256(bytes(consumer.itemStructs[i].itemId)) == keccak256(bytes(_item.itemId))) {
                require(containsItem[_address][_item.itemId] = true);
                consumer.itemStructs[i].quantity = consumer.itemStructs[i].quantity.add(_item.quantity);
                isAdded = true;
            }
        }

        if (isAdded == false) {
            consumer.itemStructs.push(_item);
            containsItem[_address][_item.itemId] = true;
        }
    }

    // TODO: can be improved, zero should't be spent
    function spendItems(address _address, Item[] memory _itemStructs) public {
        Consumer storage consumer = consumers[_address];

        for (uint i = 0; i < _itemStructs.length; i++) {
            if (containsItem[_address][_itemStructs[i].itemId] == false) {
                require(containsItem[_address][_itemStructs[i].itemId] = true, "Given item does not exist in the consumer wallet");
            }
            for (uint k = 0; k < consumer.itemStructs.length; k++) {
                if (keccak256(bytes(consumer.itemStructs[k].itemId)) == keccak256(bytes(_itemStructs[i].itemId))) {
                    require(consumer.itemStructs[k].quantity >= _itemStructs[i].quantity);
                    consumer.itemStructs[k].quantity = consumer.itemStructs[k].quantity.sub(_itemStructs[i].quantity);
                    require(consumer.itemStructs[k].quantity >= 0, "Balance should be more than 0, check spending items.");
                }
            }
        }
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Wallet.sol";

contract Token is Wallet {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply * (10 ** _decimals);
        balanceOf[msg.sender] = totalSupply;
    }
    
    function _transfer(address _from, address _to, uint256 _value) public {
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);        
    }
    
    function _mint(address account, uint256 _value) internal {
        require(account != address(0));
        totalSupply = totalSupply.add(_value);
        balanceOf[account] = balanceOf[account].add(_value);
        emit Transfer(address(0), account, _value);        
    }
    
    function getBalance(address _user) public view returns (uint256) {
        return balanceOf[_user];
    }
}
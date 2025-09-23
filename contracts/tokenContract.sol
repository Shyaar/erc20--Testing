// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IERC20 } from"./interfaces/IERC20.sol";
import { Events } from "./lib/events.sol";

contract TokenContract {
  
    string tokenName;
    string tokenSymbol;
    uint256 decimals = 18;

    mapping(address => uint256) balances;
    mapping (address => mapping(address => uint256)) allowances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
      tokenName = _tokenName;
      tokenSymbol = _tokenSymbol;
    }

    function balanceOf(address tokenHolder) external view returns (uint256) {
      uint256 balance = balances[tokenHolder];
      return balance;
    }
    
    function transfer(address recipient, uint256 amount) external {
      require(recipient != address(0), "Invalid address zero detected");
      require(amount > 0, "Amount must be greater than zero");

      uint256 balance = this.balanceOf(msg.sender);

      require(balance >= amount, "Insufficient balance");

      balances[msg.sender] -= amount;
      balances[recipient] += amount;

      emit Events.Transfer(msg.sender, recipient, amount);
    }
    function transferFrom(
        address owner,
        address spender,
        uint256 amount
    ) external returns(bool){
      require(owner != address(0), "Invalid address zero");
      require(spender != address(0), "Invalid address zero");
      require(amount > 0, "Invalid amount");

      uint256 spenderAllowance = allowances[owner][spender];
      require(spenderAllowance >= amount, "Insufficient allowance");

      uint256 ownerBalance = this.balanceOf(owner);

      require(ownerBalance >= amount, "Insufficient owner balance");

      allowances[owner][spender] -= amount;

      balances[owner] -= amount;
      balances[spender] += amount;

      emit Events.TransferFrom(owner, spender, amount);

      return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {
      require(owner != address(0), "Invalid address zero detected");
      require(spender != address(0), "Invalid address zero detected");

      uint256 spenderAllowance = allowances[owner][spender];
      return spenderAllowance;
    }

    function approve(address spender, uint256 amount) external {
      require(spender != address(0), "Invalid address zero detected");
      allowances[msg.sender][spender] += amount;

      emit Events.Approve(msg.sender, spender, amount);
    }

    function name() external view returns(string memory) {
      return tokenName;
    }
    function symbol() external view returns(string memory) {
      return tokenSymbol;
    }

    function mint(address reciever, uint256 amount) external {
      require(reciever != address(0), "Invalid address zero detected");

      balances[reciever] += amount;
    }
}

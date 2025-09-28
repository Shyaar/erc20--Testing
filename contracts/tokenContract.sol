// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { IERC20 } from"./interfaces/IERC20.sol";
import { Events } from "./lib/events.sol";
import { Errors} from "./lib/errors.sol";


contract TokenContract {
  
    string public tokenName;
    string public tokenSymbol;
    uint256 public decimals = 18;

    uint256 public totalSupply; 
    mapping(address => uint256) private balances;
    mapping (address => mapping(address => uint256)) private allowances;

    address public admin;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
      tokenName = _tokenName;
      tokenSymbol = _tokenSymbol;
      admin = msg.sender;
      mint(address(this), 10 * decimals);
    }

    modifier onlyAdmin() {
      if(msg.sender != admin){
        revert Errors.notAdmin();
      }
      _;
    }

    function balanceOf(address tokenHolder) external view returns (uint256) {
      if (tokenHolder == address(0)){
        revert Errors.invalidAccount(tokenHolder);
      }
      uint256 balance = balances[tokenHolder];
      return balance;
    }
    

    function transfer(address recipient, uint256 amount) external {
      
      if (recipient == address(0)){
        revert Errors.invalidAccount(recipient);
      }

      
      if (amount <=0){
        revert Errors.invalidAmount(amount);
      }

      uint256 balance = this.balanceOf(msg.sender);

     
      if (balance < amount){
        revert Errors.insufficientBalance();
      }

      balances[msg.sender] -= amount;
      balances[recipient] += amount;

      emit Events.Transfer(msg.sender, recipient, amount);
    }


    function transferFrom(
        address owner,
        address receipient,
        uint256 amount
    ) external returns(bool){
      
       if (owner == address(0)){
        revert Errors.invalidAccount(owner);
      }

      
      if (receipient == address(0)){
        revert Errors.invalidreceipientAccount(receipient);
      }


      
      if (amount <=0){
        revert Errors.invalidAmount(amount);
      }

      uint256 spenderAllowance = allowances[owner][msg.sender];

      
      if(spenderAllowance < amount){
        revert Errors.insufficientAllowance();
      }

      uint256 ownerBalance = this.balanceOf(owner);

       if (ownerBalance < amount){
        revert Errors.insufficientBalance();
      }

      allowances[owner][msg.sender] -= amount;

      balances[owner] -= amount;
      balances[receipient] += amount;

      emit Events.TransferFrom(owner, receipient, amount);

      return true;
    }


    function allowance(
        address owner,
        address spender
    ) external view returns (uint256) {

       if (owner == address(0)){
        revert Errors.invalidAccount(owner);
      }

      
      if (spender == address(0)){
        revert Errors.invalidSpenderAccount(spender);
      }

      uint256 spenderAllowance = allowances[owner][spender];
      return spenderAllowance;
    }


    function approve(address spender, uint256 amount) external {

      if (spender == address(0)){
        revert Errors.invalidSpenderAccount(spender);
      }
      
      allowances[msg.sender][spender] += amount;

      emit Events.Approve(msg.sender, spender, amount);
    }


    function name() external view returns(string memory) {
      return tokenName;
    }


    function symbol() external view returns(string memory) {
      return tokenSymbol;
    }

      function totalSupplyOf() external view returns(uint) {
      return totalSupply;
    }

    function mint(address reciever, uint256 amount) public {
        if (reciever == address(0)) {
            revert Errors.invalidAccount(reciever);
        }

        if (amount <=0){
        revert Errors.invalidAmount(amount);
      }

        totalSupply += amount;
        balances[reciever] += amount;

        emit Events.Transfer(address(this), reciever, amount);
    }
}

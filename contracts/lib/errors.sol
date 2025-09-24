// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library Errors{
    error invalidAccount(address _address);
    error invalidSpenderAccount(address _address);
    error invalidAmount(uint256 _amount);

    error insufficientBalance();
    error insufficientAllowance();
}
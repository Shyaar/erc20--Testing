// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { Errors } from "../../contracts/lib/errors.sol";

import { Events } from "../../contracts/lib/events.sol";

import { TokenContract } from "../../contracts/tokenContract.sol";

contract CustomErc20Test is Test{
    TokenContract erc20Contract;

    address deployer = address(0x01);
    address addr2 = address(0x02);
    address addr3 = address(0x03);

    string tokenName = "STToken";
    string tokenSymbol = "STT";
    uint8 decimals = 18;

    uint256 totalSupply = 10 * decimals;
    address admin;

    function setUp() public{
        vm.prank(deployer);
        erc20Contract = new TokenContract(tokenName,tokenSymbol);
    }

    function testDeployment() public view{
        assertEq(erc20Contract.admin(), deployer);
        assertEq(erc20Contract.symbol(), tokenSymbol);
        assertEq(erc20Contract.name(), tokenName);
        assertEq(erc20Contract.totalSupplyOf(), totalSupply);
        assertEq(erc20Contract.balanceOf(address(erc20Contract)), totalSupply);
    }

    function testBalanceRevertWithAddress0() public {
    
        address add0 = address(0x0);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.invalidAccount.selector,add0
            )
        );

        erc20Contract.balanceOf(add0);
    }

    function testBalanceReturn() public {

        vm.prank(deployer);

        erc20Contract.mint(addr2,100);

        // console.log("balance of:", erc20Contract.balanceOf(addr2));

        assertEq(erc20Contract.balanceOf(addr2), 100);

    }

    function testTransferRevertsWithAddress0() public {
        
    }
}
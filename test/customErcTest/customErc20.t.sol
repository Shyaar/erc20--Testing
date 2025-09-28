// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { Errors } from "../../contracts/lib/errors.sol";
import { Events } from "../../contracts/lib/events.sol";
import { TokenContract } from "../../contracts/tokenContract.sol";

contract CustomErc20Test is Test {
    TokenContract erc20Contract;

    address deployer = address(0x01);
    address addr1 = address(0x02);
    address addr2 = address(0x03);
    address addr3 = address(0x04);

    string tokenName = "STToken";
    string tokenSymbol = "STT";
    uint8 decimals = 18;

    uint256 totalSupply = 10 * decimals;

 
    // SETUP
    function setUp() public {
        vm.prank(deployer);
        erc20Contract = new TokenContract(tokenName, tokenSymbol);
    }

 
    // DEPLOYMENT
    function testDeployment() public view {
        assertEq(erc20Contract.admin(), deployer);
        assertEq(erc20Contract.symbol(), tokenSymbol);
        assertEq(erc20Contract.name(), tokenName);
        assertEq(erc20Contract.totalSupplyOf(), totalSupply);
        assertEq(erc20Contract.balanceOf(address(erc20Contract)), totalSupply);
    }

 
    // BALANCEOF
    function testBalanceRevertWithAddress0() public {
        address add0 = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.invalidAccount.selector, add0)
        );
        erc20Contract.balanceOf(add0);
    }

    function testBalanceReturn() public {
        vm.prank(deployer);
        erc20Contract.mint(addr1, 100);
        assertEq(erc20Contract.balanceOf(addr1), 100);
    }

 
    // MINT
    function testMintEmitsTransferEvent() public {
        uint256 amount = 200;
        vm.prank(deployer);

        vm.expectEmit(true, true, false, true);
        emit Events.Transfer(address(erc20Contract), addr1, amount);

        erc20Contract.mint(addr1, amount);

        assertEq(erc20Contract.balanceOf(addr1), amount);
        assertEq(erc20Contract.totalSupplyOf(), totalSupply + amount);
    }

 
    // TRANSFER
    function testTransferRevertsWithAddress0() public {
        address add0 = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(Errors.invalidAccount.selector, add0)
        );
        erc20Contract.transfer(add0, 50);
    }

    function testTransferRevertsWithZeroAmount() public {
        vm.expectRevert(
            abi.encodeWithSelector(Errors.invalidAmount.selector, 0)
        );
        erc20Contract.transfer(addr1, 0);
    }

    function testTransferRevertsWithInsufficientBalance() public {
        uint256 amount = 50;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.insufficientBalance.selector)
        );
        erc20Contract.transfer(addr1, amount);
    }

    function testTransferWorksAndEmitsEvent() public {
        uint256 amount = 50;
        vm.prank(deployer);
        erc20Contract.mint(addr2, amount);

        vm.prank(addr2);

        vm.expectEmit(true, true, false, true);
        emit Events.Transfer(addr2, addr3, amount);

        erc20Contract.transfer(addr3, amount);

        assertEq(erc20Contract.balanceOf(addr2), 0);
        assertEq(erc20Contract.balanceOf(addr3), amount);
    }

 
    // APPROVE
    function testApproveEmitsEvent() public {
        uint256 amount = 300;

        vm.prank(addr1);

        vm.expectEmit(true, true, false, true);
        emit Events.Approve(addr1, addr2, amount);

        erc20Contract.approve(addr2, amount);

        assertEq(erc20Contract.allowance(addr1, addr2), amount);
    }

 
    // TRANSFERFROM
    function testTransferFromWorksAndEmitsEvent() public {
        uint256 amount = 150;

        // Mint to owner
        vm.prank(deployer);
        erc20Contract.mint(addr1, 500);

        // Approve spender
        vm.prank(addr1);
        erc20Contract.approve(addr2, 200);

        // TransferFrom by spender
        vm.prank(addr2);

        vm.expectEmit(true, true, false, true);
        emit Events.TransferFrom(addr1, addr3, amount);

        erc20Contract.transferFrom(addr1, addr3, amount);

        assertEq(erc20Contract.balanceOf(addr1), 350);
        assertEq(erc20Contract.balanceOf(addr3), 150);
        assertEq(erc20Contract.allowance(addr1, addr2), 50);
    }

    function testTransferFromRevertsIfAllowanceInsufficient() public {
        vm.prank(deployer);
        erc20Contract.mint(addr1, 100);

        vm.prank(addr1);
        erc20Contract.approve(addr2, 50);

        vm.prank(addr2);
        vm.expectRevert(abi.encodeWithSelector(Errors.insufficientAllowance.selector));
        erc20Contract.transferFrom(addr1, addr3, 100);
    }

    function testTransferFromRevertsIfOwnerBalanceInsufficient() public {
        vm.prank(addr1);
        erc20Contract.approve(addr2, 500);

        vm.prank(addr2);
        vm.expectRevert(abi.encodeWithSelector(Errors.insufficientBalance.selector));
        erc20Contract.transferFrom(addr1, addr3, 400);
    }

    function testTransferFromRevertsWithZeroOwner() public {
        address add0 = address(0);

        vm.prank(addr2);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.invalidAccount.selector, add0)
        );
        erc20Contract.transferFrom(add0, addr3, 50);
    }

    function testTransferFromRevertsWithZeroRecipient() public {
        address add0 = address(0);

        vm.prank(deployer);
        erc20Contract.mint(addr1, 100);

        vm.prank(addr1);
        erc20Contract.approve(addr2, 100);

        vm.prank(addr2);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.invalidreceipientAccount.selector, add0)
        );
        erc20Contract.transferFrom(addr1, add0, 50);
    }
}

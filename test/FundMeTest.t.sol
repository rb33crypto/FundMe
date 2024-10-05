// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
	FundMe fundMe;

	address USER = makeAddr("user");
	uint256 constant SEND_VLAUE = 0.1 ether;
	uint256 constant STARTING_BALANCE = 10 ether;
	uint256 constant GAS_PRICE = 1;

	modifier funded(){
		vm.prank(USER);
		fundMe.fund{value: SEND_VLAUE}();
		_;
	}

	function setUp() external {
		//fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
		DeployFundMe deployFundMe = new DeployFundMe();
		fundMe = deployFundMe.run();
		vm.deal(USER, STARTING_BALANCE);
	}

	function testMinDollarIsFive() public {
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}

	function testOwnerIsMsgSender() public {
		assertEq(fundMe.getOwner(), msg.sender);
	}

	function testPriceFeedVersionIsAccurate() public {
		uint256 version = fundMe.getVersion();
		assertEq(version, 4);
	}

	function testFundFail() public {
		vm.expectRevert();
		fundMe.fund();
	}

	function testFundUpdates() public funded {
		uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
		assertEq(amountFunded, SEND_VLAUE);
	}

	function testGetFunder() public funded{
		address funder = fundMe.getFunder(0);
		assertEq(funder, USER);
	}

	function testWithdraw() public funded{
		vm.expectRevert();
		vm.prank(USER);
		fundMe.withdraw(); 

	}

	function testSingleFunderWithdraw() public funded {
		uint256 startingOwnerBalance = fundMe.getOwner().balance;
		uint256 startingFundMeBalance = address(fundMe).balance;

		uint256 gasStart = gasleft();
		vm.txGasPrice(GAS_PRICE);
		vm.prank(fundMe.getOwner());
		fundMe.withdraw();

		uint256 gasEnd = gasleft();
		uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

		uint256 endingOwnerBalance = fundMe.getOwner().balance;
		uint256 endingFundMeBalance = address(fundMe).balance;
		assertEq(endingFundMeBalance, 0);
		assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
	}

	function testMultiFunderWithdraw() public funded {
		uint160 numOfFunders = 10;
		uint160 startingFunderIndex = 2;

		for(uint160 i = startingFunderIndex; i < numOfFunders; i++){
			//vm.prank
			//vm.deal
			hoax(address(i), SEND_VLAUE);
			//fund the fundme
			fundMe.fund{value: SEND_VLAUE}();
		}

		uint256 startingOwnerBalance = fundMe.getOwner().balance;
		uint256 startingFundMeBalance = address(fundMe).balance;

		vm.prank(fundMe.getOwner());
		fundMe.withdraw();

		assert(address(fundMe).balance == 0);
		assert(
			startingFundMeBalance + startingOwnerBalance ==
			fundMe.getOwner().balance
		);
	}
}
















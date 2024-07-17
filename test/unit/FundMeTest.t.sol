// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // Constant variables : Users, magic numbers, gas etc.
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        // A test to check if the minimum $ is indeed 5
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // A test to check if msg.sender IS the owner
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        // A test to check if the price feed version is accurate
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }


    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();      // Cheatcode that says.. hey, revert!
        // Assert(This tx fails/reverts)
        fundMe.fund();
    }


    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);  // What this does is saying is that the next TX (transaction) will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }


    function testAddsFunderToArrayOfFunders() public {
        // A test that checks if the funders address is indeed added to the [] array
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // Checks the address at index 0 if our address is truly there
        assertEq(funder, USER);
    }


    modifier funded() {
        // Instead of writing the same code over and over .. use a modifier to make the code more elegant
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _ ;
    }


    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);     // Pranks that somebody else BUT THE OWNER is using the contract
        vm.expectRevert();  // Instead of having USER.. have somebody BUT THE USER
        fundMe.withdraw();  // Makes the 'user' try to withdraw
    }


    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }


    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank - new address
            // vm.deal - deal a new address
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the FundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance ==
            fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank - new address
            // vm.deal - deal a new address
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the FundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance ==
            fundMe.getOwner().balance
        );
    }
}

// _____________________________________________________________________
// Types of tests that can be done :

// 1. Unit
// - Testing a specific part of our code

// 2. Integration
// - Testing how our code works with other parts of our code

// 3. Forked
// - Testing our code on a simulated real environment

// 4. Staging
// - Testing our code in a real environment that is not prod
// _____________________________________________________________________
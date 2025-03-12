// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VAL = 0.1 ether; //100000000000000000 wei
    //uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //us->FuneMeTest->FundMe
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);

    }
    function testMinUSDisfive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4); 
    }
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VAL}();
        _;
    }
    function testFundUpdates() public funded{
        //The next transaction will be send by USER
        //This below fundMe.fund will be send by the USER
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VAL);
    }
    function testAddsFundertoArrayofFunders() public funded{
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }
    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithSingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act 
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("Gas used: ", gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance - startingOwnerBalance, startingFundMeBalance);
        assertEq(endingFundMeBalance, 0); //withdrawn all the money
    }
    function testWithdrawWithMultipleFunder() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundingAddress = 1;
        for (uint160 i = startingFundingAddress ; i < numberOfFunders ; i++) {
            hoax(address(i), SEND_VAL);
            fundMe.fund{value: SEND_VAL}();
        }
        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //Assert
        assertEq(startingOwnerBalance + startingFundMeBalance, fundMe.getOwner().balance);
        assertEq(address(fundMe).balance, 0);

    }
}
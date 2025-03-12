//SPDX-License-Identifier: MIT

//Fund 
//Withdraw

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe , WithdrawFundMe} from "../../script/Interactions.sol";

contract InteractionsTest is Test{
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VAL = 0.1 ether;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        // vm.prank(USER);
        // vm.deal(USER, 1e18);
        // address funder = fundMe.getFunders(0);
        assertEq(address(fundMe).balance, 0);
    }
}
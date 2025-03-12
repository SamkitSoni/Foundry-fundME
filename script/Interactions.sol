//SPDX-License-Identifier: MIT

//Fund 
//Withdraw

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script{
    uint256 constant SEND_VAL = 0.01 ether;

    function fundFundMe(address mostRecentContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentContract)).fund{value: SEND_VAL}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VAL);
    }
    function run() external {
        address mostRecentContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentContract);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentContract)).withdraw();
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentContract);
        vm.stopBroadcast();
    }
}
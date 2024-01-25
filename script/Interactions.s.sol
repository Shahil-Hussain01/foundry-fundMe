// in simple storage we interact with our contract using the command cast send... but here we will make some other contract to intereact with our contract. and cast send we need to pass the contract address of the contract that we want to intereact with, but here we are assuming that we will only interact with FundMe contract so we will pass the address of FundMe contract, and a progamatic way to get the address of FundMe contract is to use foundry devops.

// foundry devops grab the contract address of the most recently developed contract
// "forge install Cyfrin/foundry-devops --no-commit" to install foundry devops

// rpc url and fork url are different, rpc url is the actual url of the network/local network, and fork url is like faking a url, here we pretend that we are running on a network but we are actually running on a local network.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        // console.log("FundMe contract funded with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // this will look inside the broadcast folder and read the run-latest.json file to get the address of the most recently deployed contract
        fundFundMe(mostRecentlyDeployed);
    }
    // the run function will automatically run when we run the script command in the terminal, example:- forge script script/Interactions.s.sol:FundFundMe --adflaksjdflk
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        // console.log("FundMe contract funded with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // this will look inside the broadcast folder and read the run-latest.json file to get the address of the most recently deployed contract
        withdrawFundMe(mostRecentlyDeployed);
    }
}

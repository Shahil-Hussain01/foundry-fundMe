// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // makeAddr will give us a account address to us if we pass a string
    address USER2 = makeAddr("user2");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        // vm.prank(USER); // this is giving error because it can't send real tx. it's just tx simulation. but in integration test we need to send real tx.
        fundFundMe.fundFundMe(address(fundMe));
        address funder = fundMe.getFunder(0);
        // assertEq(funder, USER); // this is giving error because it can't send real tx. it's just tx simulation. but in integration test we need to send real tx.
        assertEq(funder, msg.sender);
    }

    function testUserCanWithdrawInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}

// now if we run "forge test" it will run all the test in local blockchain
// and if we run "forge test --fork-url $SEPOLIA_RPC_URL" it will pretend to run all the test in testnet
// but what if we deploy our contract to testnet? let's find out
// "forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast"
// after running this command we deploy our contract to sepolia test network and we got the contract address as 0x0B15B2335C3d6067caC191C3BB6Ff1AE14585f5a, we can check it in sepolia etherscan
// now we can run tests "forge test" it will test in the local blockchain
// "forge test --rpc-url $SEPOLIA_RPC_URL" it will actually run all the test in testnet
// now we can interact with the contract using the command "forge script script/Interactions.s.sol:FundFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast" to fund the contract and to withdraw run the command "forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast" we can see the metamask and etherscan balance of the user and the contract address
// if there is a permission issue than add this in foundry.toml file
// fs_permissions = [{ access = "read", path = "./broadcast" }]

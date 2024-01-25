// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    /*
    uint256 number = 1;

    function setUp() external{
        number = 2;
    }

    function testDemo() public{
        console.log("my number is:");
        console.log(number); // forge test -vv to show the logs
        assertEq(number, 2);
    }
    */

    FundMe fundMe;

    address USER = makeAddr("user"); // makeAddr will give us a account address to us if we pass a string
    address USER2 = makeAddr("user2");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // here we are initializing the balance of the USER to 10 ether
        vm.deal(USER2, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        // console.log("minimum dollar is:");
        // console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // assertEq(fundMe.i_owner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        // "forge test --mt testPriceFeedVersionIsAccurate" to run only this test
        // forge test -vvv to show the stack trace this will show when the test fails
        uint256 version = fundMe.getVersion();
        // console.log("price feed version is:");
        // console.log(version);
        assertEq(version, 4);
        // when we run test and don't specify the chain then foundry will automatically run the test on the anvil chain and Aggregator doesn't exist in anvil that's why we are getting error in this test //// now as we deploy the mock also this will pass

        // so how to solve this?
        // we can use --fork-url and paste our alchemy url
        // paste the alchemy url in the.env file and then run the command "source .env" to access it in the terminal
        // and now if we run the test it will pretend like it is running on the sepolia test net.
        // "forge test --mt testPriceFeedVersionIsAccurate -vvv --fork-url $SEPOLIA_RPC_URL"
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // the next transaction should revert or throw error if it runs successfully then the test will fail and if it doesn't then the test will pass
        fundMe.fund();
    }

    // function testFundUpdatesFundDataStructure() public {
    //     fundMe.fund{value: 1e18}();
    //     console.log(msg.sender);
    //     console.log(address(this));
    //     // uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender); // this is failing
    //     uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
    //     assertEq(amountFunded, 1e18);
    // }
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next transaction will be called by the account USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        vm.prank(USER2);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(funder, USER);
        assertEq(fundMe.getFunder(1), USER2);

        // before running the test it first run setUp function and then run that particular test and then setUp again and then run another test then setUp again..
    }

    /*
    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    */

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(
            endingOwnerBalance + endingFundMeBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange

        // uint256 numberOfFunders = 10;
        // uint256 startingFunderIndex = 1;
        // for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
        //     vm.prank(address(i));
        //     vm.deal(address(i), STARTING_BALANCE);
        //     fundMe.fund{value: SEND_VALUE}();
        // }
        // It is giving error because we are trying to convert uint256 value to address which is not possible in solidity. if we want to convert to address then we need to use uint160. We should not convert 0 and use it as transaction.

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i));
            // vm.deal(address(i), STARTING_BALANCE);
            hoax(address(i), STARTING_BALANCE);
            // hoax is same as doing prank and then deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // vm.prank(fundMe.getOwner());
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // here anything in between startPrank and stopPrank will be called by the address that is passed to startPrank

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingFundMeBalance + endingOwnerBalance
        );
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        // Arrange

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingFundMeBalance + endingOwnerBalance
        );
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
        assertEq(endingFundMeBalance, 0);
    }
}

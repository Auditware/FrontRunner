
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/DosAuction.sol";

contract DosAuctionTest is Test {
    DosAuction auction;
    address payable attacker;
    address payable bidder1;
    address payable bidder2;

    function setUp() public {
        auction = new DosAuction();
        attacker = payable(address(0x1));
        bidder1 = payable(address(0x2));
        bidder2 = payable(address(0x3));

        vm.deal(attacker, 10 ether);
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);
    }

    function testFrontRunningAttack() public {
        // Bidder1 places a valid bid
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        // Attacker places a higher bid with a contract that reverts on receiving ether
        vm.prank(attacker);
        auction.bid{value: 2 ether}();

        // Bidder2 attempts to outbid the attacker
        vm.prank(bidder2);
        vm.expectRevert("Refund failed, frontrunner cannot be replaced");
        auction.bid{value: 3 ether}();

        // Assert that the attacker is still the frontrunner
        assertEq(auction.currentFrontrunner(), attacker);
        assertEq(auction.currentBid(), 2 ether);
    }
}

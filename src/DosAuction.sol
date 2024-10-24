// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DosAuction {
    address payable public currentFrontrunner;
    uint public currentBid;

    // Takes in bid, refunding the frontrunner if they are outbid
    function bid() public payable {
        require(msg.value > currentBid, "Bid must be higher than the current bid");

        // Refund the previous frontrunner if there is one
        if (currentFrontrunner != address(0)) {
            // Vulnerable code: the refund could fail if the frontrunner's fallback function reverts.
            require(currentFrontrunner.send(currentBid), "Refund failed, frontrunner cannot be replaced");
        }

        // Cast msg.sender to payable to avoid type conversion error
        currentFrontrunner = payable(msg.sender);
        currentBid = msg.value;
    }
}
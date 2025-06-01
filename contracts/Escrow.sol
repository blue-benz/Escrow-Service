// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard {
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    bool public released;
    bool public disputed;
    
    event FundsDeposited(address indexed buyer, uint256 amount);
    event FundsReleased(address indexed seller, uint256 amount);
    event DisputeRaised(address indexed party);
    event DisputeResolved(address indexed winner, uint256 amount);
    
    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
    }
    
    function deposit() external payable {
        require(msg.sender == buyer, "Only buyer");
        require(amount == 0, "Already deposited");
        amount = msg.value;
        emit FundsDeposited(buyer, amount);
    }
    
    function release() external nonReentrant {
        require(msg.sender == buyer || msg.sender == arbiter, "Not authorized");
        require(!released, "Already released");
        require(!disputed, "Under dispute");
        
        released = true;
        payable(seller).transfer(amount);
        emit FundsReleased(seller, amount);
    }
    
    function raiseDispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Not authorized");
        require(!released, "Already released");
        disputed = true;
        emit DisputeRaised(msg.sender);
    }
    
    function resolveDispute(address winner) external nonReentrant {
        require(msg.sender == arbiter, "Only arbiter");
        require(disputed, "No dispute");
        require(!released, "Already released");
        
        released = true;
        payable(winner).transfer(amount);
        emit DisputeResolved(winner, amount);
    }
}

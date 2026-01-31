// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// LEVEL 4 — Personal Time-Locked PiggyBank with Penalty on Early Withdrawal

contract PiggyBankV4 {
    struct depositInfo {
        // Structure to hold deposit details
        uint256 balance;
        uint256 unlockTime;
    }
    mapping(address => depositInfo) private deposits; // Track deposits and their unlock times

    uint256 public totalDeposits; // Total amount of deposits in the piggy bank
    uint256 public penaltyRate = 10; // Penalty rate for early withdrawals (10%)

    // Event emitted on deposits
    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    // Event emitted on withdrawals
    event Withdrawn(address indexed user, uint256 amount, uint256 penalty);

    // Function to deposit Ether with a specified lock duration
    function deposit(uint256 lockDuration) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        require(lockDuration > 0, "Lock duration must be greater than zero");

        depositInfo storage user = deposits[msg.sender]; // Get user's deposit info

        user.balance += msg.value; // Update deposit amount
        user.unlockTime = block.timestamp + lockDuration; // Set unlock time

        totalDeposits += msg.value; // Update total deposits

        emit Deposited(msg.sender, msg.value, user.unlockTime); // Emit deposit event
    }

    // Function to withdraw Ether, applying penalty if withdrawn early
    function withdraw() external {
        depositInfo storage user = deposits[msg.sender]; // Get user's deposit info
        require(user.balance > 0, "No funds to withdraw"); // Ensure there are funds to withdraw

        uint256 amountToWithdraw = user.balance; // Amount to withdraw
        uint256 penalty = 0; // Initialize penalty

        //apply penalty if withdrawn before unlock time
        if (block.timestamp < user.unlockTime) {
            penalty = (amountToWithdraw * penaltyRate) / 100; // Calculate penalty
        }
        uint256 payout = amountToWithdraw - penalty; // Calculate payout after penalty

        // Effects
        user.balance = 0; // Reset user's balance
        totalDeposits -= payout; // Update total deposits

        // Interactions
        (bool success, ) = msg.sender.call{value: payout}(""); // Transfer payout to user
        require(success, "Transfer failed"); // Ensure transfer was successful

        emit Withdrawn(msg.sender, payout, penalty); // Emit withdrawal event
    }

    // View helper function to get user's deposit details
    function getMyBalance() external view returns (uint256) {
        return deposits[msg.sender].balance;
    }

    // View helper function to get user's unlock time
    function getMyUnlockTime() external view returns (uint256) {
        return deposits[msg.sender].unlockTime;
    }

    // View helper function to get time left until unlock
    function timeLeft() external view returns (uint256) {
        uint256 unlock = deposits[msg.sender].unlockTime;
        if (block.timestamp >= unlock) return 0;
        return unlock - block.timestamp;
    }

    // View helper function to get contract's total balance
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Fallback function to prevent accidental Ether transfers
    receive() external payable {
        revert("Use deposit function to add funds");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// LEVEL 2 — PiggyBank with User Balances
// What You Learn in Level 2
// mapping(address => uint256) → per-user balances
// Users deposit ETH individually
// Users can withdraw only their own ETH
// Modern .call{value:} pattern for withdrawals
// Still no time-lock or penalties (Level 3 will add that)

contract piggyBankV2 {
    // Mapping to track user balances
    mapping(address => uint256) public balances;

    // track total deposits
    uint256 public totalDeposits;

    // Events
    // events for deposits and withdrawals
    event Deposited(address indexed user, uint256 amount);
    event Withdrawl(address indexed user, uint256 amount);

    // Core Functions
    // Function to deposit ETH into the PiggyBank
    function deposit() external payable {
        _deposit();
    }

    // Internal deposit logic
    function _deposit() internal {
        require(msg.value > 0, "Send ETH to deposit");

        // Update user balance and total deposits
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        // Emit deposit event
        emit Deposited(msg.sender, msg.value);
    }

    // Function to withdraw user's ETH from the PiggyBank
    function withdraw() external {
        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "No balance to withdraw");

        // Reset user balance before transfer to prevent re-entrancy (Effects)
        balances[msg.sender] = 0;
        totalDeposits -= userBalance;

        // Transfer ETH to the user (Interactions)
        (bool success, ) = msg.sender.call{value: userBalance}("");
        require(success, "Transfer failed");

        // Emit withdrawal event
        emit Withdrawl(msg.sender, userBalance);
    }

    // check your balance
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    // check contract total balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // support receiving ETH directly
    receive() external payable {
        _deposit();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//  LEVEL 3 — Time-Locked PiggyBank
// In this level we add: “You cannot withdraw until a certain date.”

contract PiggyBankV3 {
    // storage
    mapping(address => uint256) private balances; // Mapping to track user balances
    uint256 public totalDeposits;

    uint256 public unlockTime; // Timestamp when withdrawals are allowed

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawl(address indexed user, uint256 amount);
    event UnlockTimeUpdated(uint256 newUnlockTime);

    // Constructor to set the initial unlock time
    constructor(uint256 _unlockTime) {
        require(
            _unlockTime > block.timestamp,
            "Unlock time must be in the future"
        );
        unlockTime = _unlockTime;
    }

    // Core Functions
    function deposit() public payable {
        require(msg.value > 0, "Send ETH to deposit");

        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;

        emit Deposited(msg.sender, msg.value); // Emit deposit event
    }

    // Function to withdraw user's ETH from the PiggyBank
    function withdraw() external {
        require(
            block.timestamp >= unlockTime,
            "Cannot withdraw before unlock time"
        );

        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "No balance to withdraw");

        // Reset user balance before transfer to prevent re-entrancy (Effects)
        balances[msg.sender] = 0;
        totalDeposits -= userBalance;

        // Transfer ETH to the user (Interactions)
        (bool success, ) = msg.sender.call{value: userBalance}("");
        require(success, "Transfer failed");

        emit Withdrawl(msg.sender, userBalance); // Emit withdrawal event
    }

    // View function to check user's balance and unlock time
    function getMyBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function timeLeft() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;

        return unlockTime - block.timestamp;
    }

    // Function to update the unlock time (onlyOwner can implement later)
    function extendUnlockTime(uint256 _newUnlockTime) external {
        require(
            _newUnlockTime > unlockTime,
            "New unlock time must be later than current"
        );
        unlockTime = _newUnlockTime;

        emit UnlockTimeUpdated(_newUnlockTime);
    }

    // support receiving ETH directly
    receive() external payable {
        deposit();
    }
}

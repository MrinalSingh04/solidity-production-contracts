// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PiggyBankV1 {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    //deposit function to receive Ether
    function deposit() external payable {
        require(msg.value > 0, "send ETHER to deposit");
    }

    //owner breaks the piggy bank and withdraws all Ether
    function withdrawl() external {
        require(msg.sender == owner, "Not the owner");

        uint256 amount = address(this).balance;

        //Effects
        //(no state variables to update in this simple contract)

        //Interactions
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");

        //Events
        //(no events defined in this simple contract)
    }

    //view function to check balance (ether) of the piggy bank
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //fallback function to receive Ether (allow direct eth transfers)
    receive() external payable {}
}

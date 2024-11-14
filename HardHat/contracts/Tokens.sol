// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Tokens is ERC20 {
    address private _owner;

    constructor(address _address) ERC20("VotingTokens", "III") {
        _owner = _address;
    }

    function mint(address to, uint256 amount) public  {
        require(_owner == msg.sender, "Only owner can mint tokens!");
        _mint(to, amount);
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XpToken is ERC20{
    address public owner;
    address sxpContractAddress;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Unauthorized access: Only owner can call this function."
        );
        _;
    }

    modifier onlySXPContract {
        require(msg.sender == sxpContractAddress, "Unauthorized access: Only the SXP Contract can mint XP tokens");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply * (10 ** uint256(decimals())));
        owner = msg.sender;
    }

    function addSXPContract(address _sxpContractAddress) external onlyOwner {
        // require(_sxpContractAddress == address(0), "Invalid: SXP contract has already been added.");
        sxpContractAddress = _sxpContractAddress;
    }

    function mint(uint256 _amount) external onlySXPContract {
        _mint(sxpContractAddress, _amount);
    }
}
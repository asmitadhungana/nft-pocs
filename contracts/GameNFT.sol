//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract GameNFT is ERC1155 {
    address owner;
    uint256 public Player0 = 0;
    uint256 public Player1 = 1;
    uint256 public Player2 = 2;
    
    address sxpContractAddress;

    mapping (uint256 => uint256) _xpNFT;
    mapping (uint256 => uint256) gamesWon;

    event XpUpdated(uint256 _id, uint256 _amount);
    event SXPContractAdded(address);
    event GamePlayed(uint256, bool);

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Unauthorized access: Only owner can call this function."
        );
        _;
    }

    modifier onlySXPContract{
        require(msg.sender == sxpContractAddress, "Unauthorized access: Only the SXP contract can update XPs");
        _;
    }
    

    constructor() ERC1155("https://asmitadhungana.github.io/erc1155metadata/api/token/{id}.json") {
        _mint(msg.sender, Player0, 1, "");
        _mint(msg.sender, Player1, 1, "");
        _mint(msg.sender, Player2, 1, "");
        owner = msg.sender;
    }

    fallback() external {}
    receive() external payable{}

    function addSXPContract(address _sxpContractAddress) external onlyOwner {
        require(sxpContractAddress == address(0), "Invalid: SXP contract has already been added.");
        sxpContractAddress = _sxpContractAddress;
        emit SXPContractAdded(_sxpContractAddress);
    }

    function getXp(uint _id) external view returns(uint256){
        return _xpNFT[_id];
    }

    function updateXp(uint256 _id, uint256 _amount) external onlySXPContract{
        _xpNFT[_id] = _amount;
        emit XpUpdated(_id, _amount);
    }

    function addGamesPlayed(uint256 _nftId, bool _winStatus) external onlySXPContract{
        if (_winStatus == true){
            gamesWon[_nftId] += 1;
        }
        emit GamePlayed(_nftId, _winStatus);
    }
}
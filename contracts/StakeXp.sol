//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface GameNft{
    function getXp(uint256 _id) external view returns (uint256);
    function updateXp(uint256 _id, uint256 _amount) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function addGamesPlayed(uint256 _playerId, bool _winStatus) external;
}

interface XP{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(uint256 _amount) external;
}

contract StakeXp is ERC20{
    XP public xpContract;
    GameNft public nftContract;

    address public owner;
    mapping (address => bool) isSelectedGameContract;
    address[] selectedGameContracts;
    
    // nftId => xpstaked
    mapping(uint256 => uint256) public _xpNFT;
    
    event Received(address, uint);
    event XpStaked(uint256 _id, uint256 _amount);
    event XpUnstaked(uint256 _id, uint256 _amount);
    event GameContractAdded(address);

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Unauthorized access: Only owner can call this function."
        );
        _;
    }

    modifier onlySelectedGameContracts{
        require(isSelectedGameContract[msg.sender] == true, "SXP: Only selected game contracts can update XP.");
        _;
    }

    constructor(address _xpTokenAddress, address _nftTokenAddress) ERC20("StakeToken", "SXP"){        
        xpContract = XP(_xpTokenAddress);
        nftContract = GameNft(_nftTokenAddress);
        owner = msg.sender;
    }
    
    receive() external payable{
        emit Received(msg.sender, msg.value);
    }

    function addValidGameContract(address _newGameContract) external onlyOwner {
        require(_newGameContract != address(0), "Invalid: New Game Contract cannot be Zero Address.");
        isSelectedGameContract[_newGameContract] = true;
        emit GameContractAdded(_newGameContract);
    }
    
    function stakeXpToNFT(uint256 _id, uint256 _amount) external {
        xpContract.transferFrom(msg.sender, address(this), _amount);
        uint256 _presentXp = nftContract.getXp(_id);
        uint256 _updatedXp = _presentXp + _amount;
        nftContract.updateXp(_id, _updatedXp);
        
        // _mint(msg.sender, _amount * (10 ** uint256(decimals()))); // mint equivalent SXP tokens
        _mint(msg.sender, _amount);
        emit XpStaked(_id, _amount);
    }
    
    function unstakeXpFromNFT(uint256 _id, uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount); // require sender to possess valid amount of SXP tokens
        require(nftContract.balanceOf(msg.sender, _id) == 1, "Only the NFT owner can unstake XP tokens locked in the NFT.");

        uint256 _presentXp = nftContract.getXp(_id);
        require(_presentXp >= _amount, "XP amount exceeds the total value locked in the NFT.");

        _burn(msg.sender, _amount); // burn equivalent SXP tokens 
        uint256 _updatedXp = _presentXp - _amount;

        nftContract.updateXp(_id, _updatedXp); // update the XP for the particular NFT
        
        xpContract.transfer(msg.sender, _amount); // transfer staked XP tokens back to the owner
       
        emit XpUnstaked(_id, _amount);
    }
    
    function transferXpToAnotherNFT(uint256 _fromId, uint256 _toId, uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount, "User doesn't hold enough SXP tokens for the transfer");
        require(nftContract.balanceOf(msg.sender, _fromId) == 1, "Only the NFT owner can transfer XP tokens locked in the NFT.");
        require(nftContract.balanceOf(msg.sender, _toId) == 1, "NFT owner can transfer XP tokens to his/her owned NFTs only.");
        
        uint256 _fromNftXp = nftContract.getXp(_fromId);
        require(_fromNftXp >= _amount, "XP amount exceeds the total value locked in the NFT.");
        
        uint256 _toNftXp = nftContract.getXp(_toId);

        _fromNftXp -= _amount;
        _toNftXp += _amount;

        nftContract.updateXp(_fromId, _fromNftXp);
        nftContract.updateXp(_toId, _toNftXp);
    }

    function singlePlayer_updateNftXp(uint256 _id, bool _winStatus) external onlySelectedGameContracts {
        uint256 _presentXp = nftContract.getXp(_id);
        // Require the nft to have at least 100 XP prior
        require(_presentXp >= 100, "The NFT should have at least 100 XP tokens to update the XP.");

        uint256 _newXp;
        if (_winStatus == true){
            _newXp = _presentXp + 100;
            _mint(_msgSender(), 100); 
            
        } else {
            _newXp = _presentXp + 10;
            _mint(_msgSender(), 10);
        }
        nftContract.updateXp(_id, _newXp);
        nftContract.addGamesPlayed(_id, _winStatus);
    }

    function multiPlayer_updateNftXp(uint256 _winnerId, address _winnerAddress, uint256 _loserId, address _loserAddress) external onlySelectedGameContracts {
        uint256 _winnerXp = nftContract.getXp(_winnerId);
        uint256 _loserXp = nftContract.getXp(_loserId);

        require(nftContract.balanceOf(_winnerAddress, _winnerId) == 1 && nftContract.balanceOf(_loserAddress, _loserId) == 1, "Mismatch: Addresses do not match NFT Ids.");

        nftContract.updateXp(_winnerId, _winnerXp + 100);
        nftContract.updateXp(_loserId, _loserXp + 10);

        _mint(_winnerAddress, 100);
        _mint(_loserAddress, 10);

        xpContract.mint(110);
        nftContract.addGamesPlayed(_winnerId, true);
        nftContract.addGamesPlayed(_loserId, false);
    }

}
    

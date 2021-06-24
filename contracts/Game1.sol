//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface GameNft{
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function getXp(uint _id) external view returns(uint256);
}

interface SXP{
    function singlePlayer_updateNftXp(uint256 _id, bool _winStatus) external;
    function multiPlayer_updateNftXp(uint256 _winnerId, address _winnerAddress, uint256 _loserId, address _loserAddress) external;
}

contract Game1{
    GameNft public nftContract;
    SXP public sxpContract;

    event WonGame(uint256, bool);

    constructor(address _gameNft, address _sxp){
        nftContract = GameNft(_gameNft);
        sxpContract = SXP(_sxp);
    }

    function _getRandom() private view returns (bool) {
        if (uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 2 == 0){
            return false;
        }
        return true;
    }

    function FlipCoin(uint256 _nftId) external {
        address owner = msg.sender;
        require(nftContract.balanceOf(owner, _nftId) == 1, "Invalid: You don't own the given nft");
        require(nftContract.getXp(_nftId) >= 100, "Player should have at least 100 XP points to play");
        bool gotLucky = _getRandom();
        sxpContract.singlePlayer_updateNftXp(_nftId, gotLucky);
        emit WonGame(_nftId, gotLucky);
    }

}

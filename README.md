# Crazy Defense NFT interaction

This branch contains simple tasks completed for generating a POC for future prospects.

# Components

This repo consists of 4 contracts:
**- GameNFT.sol**
> This is an ERC1155 contract that pre-mints 3 nfts with IDs: 0, 1, 2 when deployed and assigns all the NFTs to the deployer initially. This contract tracks the XP points for each NFTs via a mapping. 
> - `addSXP` function restricted to the owner of the contract to add the address of the StakeXp contract.
> - `getXp` function to get the present xp points of a NFT
> - Only the StakeXp contract is allowed  call the `updateXp` function to update the XP points for a NFT.


**- XpToken.sol**
> This is an ERC20 contract for XP tokens. XP tokens can be bought and traded on DEXes supporting ERC20 contracts. For playing games with NFTs, an user will have to stake/lock certain amount of XP tokens so as to provide equivalent XP points for that NFT, which will be eventually be tracked in the GameNFT contract.

**- StakeXp.sol**
> This is an ERC20 contract for SXP tokens. This contract handles the staking/unstaking and transfer of XP tokens for NFTs of GameNFT contract. 
> This contract acts as a bridge between all the games utilizing the GameNFT contract's NFTs and the GameNFT contract. Users will be able to update their XPs by playing games which in turn will call the StakeXp contract to update the XP points for player NFTs.
> 
**- Game1.sol**
> This is a simple game (one of many) that can utilize NFTs of GameNFT contract for letting NFT characters play certain games and earn XP points and in turn SXP tokens -> XP tokens from participation.


## Project Flow

- An user first buys a XP token from market/crowdsale.
- The user buys a GameNFT token.
- For playing any games using the NFTs, the user will have to stake at least a 100 XP tokens to his/her owned nfts.
- For staking, s/he calls the `approve` function in XP contract with the amount s/he wants to stake to the address of the StakeXp contract. 
- S/he then calls the `stakeXpToNFT` function in the StakeXp contract with the desired amount of XPs for a certain NFT id. 
- This will transfer equivalent amount of XP tokens from user's wallet to StakeXp contract and mint SXP tokens to the user's wallet for representing the staked XPs in 1:1 ratio.
- The user can then go to the **Game1** contract or any game contract that's been approved by the StakeXp contract and start collecting XP points.
- After each game, the Game contracts will call either the `singlePlayer_updateNftXp` or the `multiPlayer_updateNftXp` on StakeXp contract to update the XP points for the player NFT. 
- For each win, the XP point is increased by 100 and for each loss, by 10 with equivalent amount of SXP tokens minted to the owner's wallet. That SXP can be redeemed whenever the owner wants to unstake certain XP tokens from owned NFTs.

## RUN the TESTS
In the root directory:

    $ npm install
    $ npx hardhat test

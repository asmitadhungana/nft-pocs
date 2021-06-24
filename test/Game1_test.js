const { expect } = require("chai");

describe("GameNft contract", function() {
    let GameNFT;
    let gameNft;
    let owner;
    let addr1;
    let addr2;

    let XpToken;
    let xpToken;

    let SXPToken;
    let sxpToken;

    beforeEach(async () => {
        XpToken = await ethers.getContractFactory("XpToken");
        // deploy the XpToken contract
        xpToken = await XpToken.deploy("Xp Token", "XP", 1000000);
        await xpToken.deployed();
        // console.log(xpToken.address);
        
        GameNFT = await ethers.getContractFactory("GameNFT");
        // deploy the GameNFT contract
        gameNft = await GameNFT.deploy();
        await gameNft.deployed();
        // console.log(gameNft.address);

        SXPToken = await ethers.getContractFactory("StakeXp");
        [owner, addr1, addr2] = await ethers.getSigners();
        // deploy the StakeXp contract
        sxpToken = await SXPToken.deploy(xpToken.address, gameNft.address);
        await sxpToken.deployed();
        // console.log(sxpToken.address);

        xpToken.addSXPContract(sxpToken.address);
        gameNft.addSXPContract(sxpToken.address);

        Game1 = await ethers.getContractFactory("Game1");
        //deploy the Game1 contract
        game1 = await Game1.deploy(gameNft.address, sxpToken.address);
        await game1.deployed();
        // console.log(game1.address);

        
    })

    describe("Deployments", () => {

        it("assigns the deployer as the owner of the XpToken contract", async () => {
            let _owner = await xpToken.owner();
            console.log(owner.address)
            expect(_owner).to.equal(owner.address); // owner.address is the first signer of our test file who's deployed all the contracts
        })

        it("assigns the total supply of xp tokens to the owner of XpToken contract on deployment", async  () => {
          let totalSupply = await xpToken.totalSupply();
          expect(await xpToken.balanceOf(owner.address)).to.equal(totalSupply);
        });
    
        it("assigns one of each nft ids 0, 1, 2 to owner of the sxpToken contract on deployment", async  () => {
          let owner_balanceOf_0 = await gameNft.balanceOf(owner.address, 0 )
          let owner_balanceOf_1 = await gameNft.balanceOf(owner.address, 1 )
          let owner_balanceOf_2 = await gameNft.balanceOf(owner.address, 2 )
          
          expect(owner_balanceOf_0).to.equal(1);
          expect(owner_balanceOf_1).to.equal(1);
          expect(owner_balanceOf_2).to.equal(1);
        });
    });

    describe("StakeXp contract", () => {

        it("lets owner stake his/her XP tokens to a nft", async () => {
          const _xpAmountToStake = 100;
          const _nftId = 1;
    
          //owner first approves 100 XP tokens to sxpToken contract
          await xpToken.approve(sxpToken.address, 100);
            
          await expect(sxpToken.connect(owner).stakeXpToNFT(_nftId, _xpAmountToStake))
            .to.emit(sxpToken, "XpStaked")
            .withArgs(_nftId, _xpAmountToStake);
    
          expect( await sxpToken.balanceOf(owner.address)).to.equal(_xpAmountToStake);
        });
    
        it("lets owner unstake his/her XP tokens from a nft", async () => {
          const _xpAmountToStake = 200;
          const _xpAmountToUnstake = 100;
          const _nftId = 1;
    
          //owner first approves 200 XP tokens to sxpToken contract
          await xpToken.connect(owner).approve(sxpToken.address, 200);
    
          await sxpToken.connect(owner).stakeXpToNFT(_nftId, _xpAmountToStake);
          expect( await gameNft.getXp(_nftId)).to.equal(_xpAmountToStake);
    
          await expect(sxpToken.connect(owner).unstakeXpFromNFT(_nftId, _xpAmountToUnstake))
            .to.emit(sxpToken, "XpUnstaked")
            .withArgs(_nftId, _xpAmountToUnstake);
    
          expect( await gameNft.getXp(_nftId)).to.equal(_xpAmountToStake - _xpAmountToUnstake );
        });

        it("lets owner wallet transfer XP between two owned nfts", async () => {
            const _fromId = 0;
            const _toId = 1;
            const _xpStakedInFromId = 200;
            const _xpStakedInToId = 100;
            const _xpTransferAmount = 50;

            //owner first approves 300 XP tokens to sxpToken contract
            await xpToken.connect(owner).approve(sxpToken.address, 300);
            // Stake respective amount of XP tokens to each NFT ids: 0 and 1
            await sxpToken.connect(owner).stakeXpToNFT(_fromId, _xpStakedInFromId);
            await sxpToken.connect(owner).stakeXpToNFT(_toId, _xpStakedInToId);

            await sxpToken.connect(owner).transferXpToAnotherNFT(_fromId, _toId, _xpTransferAmount);

            expect( await gameNft.getXp(_fromId)).to.equal(_xpStakedInFromId - _xpTransferAmount );
            expect( await gameNft.getXp(_fromId)).to.equal(_xpStakedInToId + _xpTransferAmount );
        });
    });

    describe("Game Play", () => {

        it("Changes XP points of the NFT after Coin Flip", async () => {
            expect (await sxpToken.owner()).to.equal(owner.address);
            await expect(sxpToken.connect(owner).addValidGameContract(game1.address))
                .to.emit(sxpToken, "GameContractAdded")
                .withArgs(game1.address);

            _nftId = 1;

            await xpToken.connect(owner).approve(sxpToken.address, 300);
            await expect(sxpToken.connect(owner).stakeXpToNFT(1, 200)).
                to.emit(sxpToken, "XpStaked")
                .withArgs(_nftId, 200)
            
            await expect(game1.FlipCoin(_nftId)).
                to.emit(gameNft, "XpUpdated"); // check if the flipcoin function called from Game1 contract leads to emission of XpUpdated event in GameNFT contract
        });
    });
});
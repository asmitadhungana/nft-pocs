const hre = require("hardhat");

async function main() {
  const XpToken = await hre.ethers.getContractFactory("XpToken");
  const xpToken = await  XpToken.deploy("Xp Token", "XP", 1000000);

  const GameCharacter = await hre.ethers.getContractFactory("GameCharacter");
  const gameCharacter = await GameCharacter.deploy(xpToken.address);

  await gameCharacter.deployed();

  console.log("GameCharacter deployed to:", gameCharacter.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

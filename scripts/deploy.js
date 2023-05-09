const hre = require("hardhat");
const { ethers } = hre;

async function main() {
  // Deploy contract
  const UniswapInteraction = await ethers.getContractFactory(
    "UniswapInteraction"
  );
  const uniswapInteraction = await UniswapInteraction.deploy();

  console.log("UniswapInteraction deployed to:", uniswapInteraction.address);

  // Verify contract on Etherscan
  await hre.run("verify:verify", {
    address: uniswapInteraction.address,
    constructorArguments: [],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

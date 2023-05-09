const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UniswapInteraction", () => {
  let uniswapInteraction;
  beforeEach(async () => {
    const UniswapInteraction = await ethers.getContractFactory(
      "UniswapInteraction"
    );
    uniswapInteraction = await UniswapInteraction.deploy();
    await uniswapInteraction.deployed();
  });

  describe("performSwap", () => {
    it("should swap tokens successfully", async () => {
      const tokenFrom = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
      const tokenTo = "0xc944E90C64B2c07662A292be6244BDf05Cda44a7";
      const amountFrom = ethers.utils.parseEther("1000");
      const minAmountTo = ethers.utils.parseEther("1");
      const recipient = "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2";

      await uniswapInteraction.performSwap(
        tokenFrom,
        tokenTo,
        amountFrom,
        minAmountTo,
        recipient
      );
      const recipientBalance = await ethers.provider.getBalance(recipient);
      expect(recipientBalance).to.be.gt(0);
    });
  });

  describe("getMinOutputAmount", () => {
    it("should return the minimum output amount", async () => {
      const tokenFrom = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
      const tokenTo = "0xc944E90C64B2c07662A292be6244BDf05Cda44a7";
      const amountFrom = ethers.utils.parseEther("1000");

      const minAmountTo = await uniswapInteraction.getMinOutputAmount(
        tokenFrom,
        tokenTo,
        amountFrom
      );
      expect(minAmountTo).to.be.gt(0);
    });
  });
});

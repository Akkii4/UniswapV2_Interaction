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
  describe("addLiquidity", () => {
    it("should add liquidity successfully", async () => {
      const tokenA = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
      const tokenB = "0xc944E90C64B2c07662A292be6244BDf05Cda44a7";
      const amountA = ethers.utils.parseEther("1000");
      const amountB = ethers.utils.parseEther("2000");
      const deadline = Math.floor(Date.now() / 1000) + 3600;

      // Approve the tokens for the UniswapInteraction contract
      const tokenAContract = await ethers.getContractAt("IERC20", tokenA);
      const tokenBContract = await ethers.getContractAt("IERC20", tokenB);
      await tokenAContract.approve(uniswapInteraction.address, amountA);
      await tokenBContract.approve(uniswapInteraction.address, amountB);

      await uniswapInteraction.addLiquidity(
        tokenA,
        tokenB,
        amountA,
        amountB,
        deadline
      );
      const lpBalance = await uniswapInteraction.balanceOf(recipient);
      expect(lpBalance).to.be.gt(0);
    });
  });

  describe("removeLiquidity", () => {
    it("should remove liquidity successfully", async () => {
      const lpToken = "0x34e89740adF97C3A9D3f63Cc2cE4a914382c230b";
      const lpAmount = ethers.utils.parseUnits("10", 18);
      const tokenA = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
      const tokenB = "0xc944E90C64B2c07662A292be6244BDf05Cda44a7";
      const minAmountA = ethers.utils.parseEther("500");
      const minAmountB = ethers.utils.parseEther("1000");
      const deadline = Math.floor(Date.now() / 1000) + 3600;

      await uniswapInteraction.approve(lpToken, lpAmount);

      await uniswapInteraction.removeLiquidity(
        lpToken,
        lpAmount,
        tokenA,
        tokenB,
        minAmountA,
        minAmountB,
        recipient,
        deadline
      );
      const balanceA = await ethers.provider.getBalance(tokenA);
      const balanceB = await ethers.provider.getBalance(tokenB);
      expect(balanceA).to.be.gt(0);
      expect(balanceB).to.be.gt(0);
    });
  });
});

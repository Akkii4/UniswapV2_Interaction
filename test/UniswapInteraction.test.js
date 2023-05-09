const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UniswapInteraction", function () {
  let uniswapInteraction;
  let owner;
  let tokenA;
  let tokenB;
  let uniswapRouter;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    const UniswapInteraction = await ethers.getContractFactory(
      "UniswapInteraction"
    );
    uniswapInteraction = await UniswapInteraction.deploy();
    await uniswapInteraction.deployed();

    const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
    tokenA = await ERC20Mock.deploy("Token A", "TKA", 18);
    await tokenA.deployed();

    tokenB = await ERC20Mock.deploy("Token B", "TKB", 18);
    await tokenB.deployed();

    const UniswapV2RouterMock = await ethers.getContractFactory(
      "UniswapV2RouterMock"
    );
    uniswapRouter = await UniswapV2RouterMock.deploy(
      uniswapInteraction.address
    );
    await uniswapRouter.deployed();

    await tokenA.mint(owner.address, ethers.utils.parseEther("100"));
    await tokenB.mint(owner.address, ethers.utils.parseEther("100"));
    await tokenA.approve(uniswapRouter.address, ethers.utils.parseEther("100"));
    await tokenB.approve(uniswapRouter.address, ethers.utils.parseEther("100"));
  });

  describe("performSwap", function () {
    it("should swap Token A for Token B", async function () {
      await uniswapInteraction.performSwap(
        tokenA.address,
        tokenB.address,
        ethers.utils.parseEther("1"),
        ethers.utils.parseEther("0.9"),
        owner.address
      );

      const ownerBalanceA = await tokenA.balanceOf(owner.address);
      expect(ownerBalanceA).to.equal(ethers.utils.parseEther("99"));

      const ownerBalanceB = await tokenB.balanceOf(owner.address);
      expect(ownerBalanceB).to.be.closeTo(
        ethers.utils.parseEther("100.1"),
        ethers.utils.parseEther("0.0001")
      );
    });

    it("should swap Token B for Token A", async function () {
      await uniswapInteraction.performSwap(
        tokenB.address,
        tokenA.address,
        ethers.utils.parseEther("1"),
        ethers.utils.parseEther("0.9"),
        owner.address
      );

      const ownerBalanceB = await tokenB.balanceOf(owner.address);
      expect(ownerBalanceB).to.equal(ethers.utils.parseEther("99"));

      const ownerBalanceA = await tokenA.balanceOf(owner.address);
      expect(ownerBalanceA).to.be.closeTo(
        ethers.utils.parseEther("100.1"),
        ethers.utils.parseEther("0.0001")
      );
    });
  });

  describe("getMinOutputAmount", function () {
    it("should return the minimum amount of Token B to receive for 1 Token A", async function () {
      const minAmount = await uniswapInteraction.getMinOutputAmount(
        tokenA.address,
        tokenB.address,
        ethers.utils.parseEther("1")
      );

      expect(minAmount).to.be.closeTo(
        ethers.utils.parseEther("0.5"),
        ethers.utils.parseEther("0.0001")
      );
    });
  });

  describe("addLiquidity", function () {
    it("should add liquidity to the Uniswap pool", async function () {
      await uniswapInteraction.addLiquidity(
        tokenA.address,
        tokenB.address,
        ethers.utils.parseEther("10"),
        ethers.utils.parseEther("10")
      );

      const pair = await uniswapInteraction.retrievePair(
        tokenA.address,
        tokenB.address
      );
      const reserves = await uniswapRouter.getReserves(pair);
      expect(reserves[0]).to.equal(ethers.utils.parseEther("10"));
      expect(reserves[1]).to.equal(ethers.utils.parseEther("10"));
    });
  });

  describe("removeLiquidity", function () {
    it("should remove liquidity from the Uniswap pool", async function () {
      await uniswapInteraction.addLiquidity(
        tokenA.address,
        tokenB.address,
        ethers.utils.parseEther("10"),
        ethers.utils.parseEther("10")
      );
      await uniswapInteraction.removeLiquidity(tokenA.address, tokenB.address);

      const pair = await uniswapInteraction.retrievePair(
        tokenA.address,
        tokenB.address
      );
      const reserves = await uniswapRouter.getReserves(pair);
      expect(reserves[0]).to.equal(ethers.utils.parseEther("0"));
      expect(reserves[1]).to.equal(ethers.utils.parseEther("0"));
    });
  });

  describe("addOptimalLiquidity", function () {
    it("should add optimal liquidity to the Uniswap WETH pool", async function () {
      await uniswapInteraction.addOptimalLiquidity(
        tokenA.address,
        ethers.utils.parseEther("10"),
        uniswapRouter.WETH()
      );

      const pair = await uniswapInteraction.retrievePair(
        tokenA.address,
        uniswapRouter.WETH()
      );
      const reserves = await uniswapRouter.getReserves(pair);
      expect(reserves[0]).to.be.closeTo(
        ethers.utils.parseEther("10"),
        ethers.utils.parseEther("0.01")
      );
    });
  });

  describe("addSubOptimalLiquidity", function () {
    it("should add suboptimal liquidity to the Uniswap WETH pool", async function () {
      await uniswapInteraction.addSubOptimalLiquidity(
        tokenA.address,
        ethers.utils.parseEther("10"),
        uniswapRouter.WETH()
      );

      const pair = await uniswapInteraction.retrievePair(
        tokenA.address,
        uniswapRouter.WETH()
      );
      const reserves = await uniswapRouter.getReserves(pair);
      expect(reserves[0]).to.be.closeTo(
        ethers.utils.parseEther("5"),
        ethers.utils.parseEther("0.5")
      );
    });
  });
});

const { expect } = require("chai")
const { ethers } = require("hardhat")

const MTk = "0x3E5CF91eb82222F5657102C1B9Cfd0CE1D17A05D"
const CSCL = "0x6B499B6f4285585Ad6C82dCF656d1Cc6deC1dcEB"
//const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"

describe("UniSwap", () => {
  let uniSwap
  let accounts
  let weth
  let mtk
  let usdc

  before(async () => {
    accounts = await ethers.getSigners(1)

    const UniSwap = await ethers.getContractFactory("UniSwap")
    uniSwap = await UniSwap.deploy()
    await uniSwap.deployed()

    weth = await ethers.getContractAt("IWETH", CSCL)
    mtk = await ethers.getContractAt("IERC20", MTk)
  //  usdc = await ethers.getContractAt("IERC20", USDC)
  })

  it("swapExactInputSingle", async () => {
    const amountIn = 10n ** 18n

    // Deposit WETH
    await weth.deposit({ value: amountIn })
    await weth.approve(uniSwap.address, amountIn)

    // Swap
    await uniSwap.swapExactInputSingle(amountIn)

    console.log("MTK balance", await mtk.balanceOf(accounts[0].address))
  })

  it("swapExactOutputSingle", async () => {
    const wethAmountInMax = 10n ** 18n
    const mtkAmountOut = 100n * 10n ** 18n

    // Deposit WETH
    await weth.deposit({ value: wethAmountInMax })
    await weth.approve(uniSwap.address, wethAmountInMax)

    // Swap
    await uniSwap.swapExactOutputSingle(mtkAmountOut, wethAmountInMax)

    console.log("mtk balance", await mtk.balanceOf(accounts[0].address))
  })

  it("swapExactInputMultihop", async () => {
    const amountIn = 10n ** 18n

    // Deposit WETH
    await weth.deposit({ value: amountIn })
    await weth.approve(uniSwap.address, amountIn)

    // Swap
    await uniSwap.swapExactInputMultihop(amountIn)

    console.log("mtk balance", await mtk.balanceOf(accounts[0].address))
  })

  it("swapExactOutputMultihop", async () => {
    const wethAmountInMax = 10n ** 18n
    const mtkAmountOut = 100n * 10n ** 18n

    // Deposit WETH
    await weth.deposit({ value: wethAmountInMax })
    await weth.approve(uniSwap.address, wethAmountInMax)

    // Swap
    await uniSwap.swapExactOutputMultihop(mtkAmountOut, wethAmountInMax)

    console.log("mtk balance", await mtk.balanceOf(accounts[0].address))
  })
})
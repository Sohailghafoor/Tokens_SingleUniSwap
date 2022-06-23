// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';


contract UniSwap {
    // For the scope of these swap examples,
    // we will detail the design considerations when using
    // `exactInput`, `exactInputSingle`, `exactOutput`, and  `exactOutputSingle`.

    // It should be noted that for the sake of these examples, we purposefully pass in the swap router instead of inherit the swap router for simplicity.
    // More advanced example contracts will detail how to inherit the swap router safely.

    ISwapRouter public immutable swapRouter;

    // This example swaps MTK/CSCL for single path swaps and MTK/USDC/CSCL for multi path swaps.

    address public constant MTK = 0x3E5CF91eb82222F5657102C1B9Cfd0CE1D17A05D; 
    address public constant CSCL = 0x6B499B6f4285585Ad6C82dCF656d1Cc6deC1dcEB;
    //address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    /// @notice swapExactInputSingle swaps a fixed amount of MTK for a maximum possible amount of CSCL
    /// using the MTK/CSCL 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its MTK for this function to succeed.
    /// @param amountIn The exact amount of MTK that will be swapped for CSCL.
    /// @return amountOut The amount of CSCL received.
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of MTK to this contract.
        TransferHelper.safeTransferFrom(MTK, msg.sender, address(this), amountIn);

        // Approve the router to spend MTK.
        TransferHelper.safeApprove(MTK, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: MTK,
                tokenOut: CSCL,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of MTK for a fixed amount of WETH.
    /// @dev The calling address must approve this contract to spend its MTK for this function to succeed. As the amount of input MTK is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of CSCL to receive from the swap.
    /// @param amountInMaximum The amount of MTK we are willing to spend to receive the specified amount of CSCL.
    /// @return amountIn The amount of MTK actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // Transfer the specified amount of MTK to this contract.
        TransferHelper.safeTransferFrom(MTK, msg.sender, address(this), amountInMaximum);

        // Approve the router to spend the specifed `amountInMaximum` of MTK.
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        TransferHelper.safeApprove(MTK, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: MTK,
                tokenOut: CSCL,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        amountIn = swapRouter.exactOutputSingle(params);

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(MTK, address(swapRouter), 0);
            TransferHelper.safeTransfer(MTK, msg.sender, amountInMaximum - amountIn);
        }
    }
}
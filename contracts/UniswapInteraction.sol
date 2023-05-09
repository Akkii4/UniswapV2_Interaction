// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title ERC20 interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

import "./interface/IUniswapV2.sol";

contract UniswapInteraction {
    address private constant UNISWAP_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /**
     * @dev Swaps an amount of tokens for another using the Uniswap V2 router.
     * @param tokenFrom The address of the token to swap from.
     * @param tokenTo The address of the token to receive.
     * @param amountFrom The amount of tokens to swap.
     * @param minAmountTo The minimum amount of tokens to receive.
     * @param recipient The address to receive the tokens.
     */
    function performSwap(
        address tokenFrom,
        address tokenTo,
        uint256 amountFrom,
        uint256 minAmountTo,
        address recipient
    ) external {
        IERC20(tokenFrom).transferFrom(msg.sender, address(this), amountFrom);
        IERC20(tokenFrom).approve(UNISWAP_ROUTER, amountFrom);

        address[] memory path;
        if (tokenFrom == WETH || tokenTo == WETH) {
            path = new address[](2);
            path[0] = tokenFrom;
            path[1] = tokenTo;
        } else {
            path = new address[](3);
            path[0] = tokenFrom;
            path[1] = WETH;
            path[2] = tokenTo;
        }

        IUniswapV2Router(UNISWAP_ROUTER).swapExactTokensForTokens(
            amountFrom,
            minAmountTo,
            path,
            recipient,
            block.timestamp
        );
    }

    /**
     * @dev Calculates the minimum amount of output tokens that will be received for a given input amount of tokens.
     * @param tokenFrom The address of the token to swap from.
     * @param tokenTo The address of the token to receive.
     * @param amountFrom The amount of tokens to swap.
     * @return The minimum amount of tokens to receive.
     */
    function getMinOutputAmount(
        address tokenFrom,
        address tokenTo,
        uint256 amountFrom
    ) external view returns (uint256) {
        address[] memory path;
        if (tokenFrom == WETH || tokenTo == WETH) {
            path = new address[](2);
            path[0] = tokenFrom;
            path[1] = tokenTo;
        } else {
            path = new address[](3);
            path[0] = tokenFrom;
            path[1] = WETH;
            path[2] = tokenTo;
        }

        uint256[] memory outputAmounts = IUniswapV2Router(UNISWAP_ROUTER)
            .getAmountsOut(amountFrom, path);

        return outputAmounts[path.length - 1];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title ERC20 interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IUniswapV2.sol";

contract UniswapInteraction {
    address private constant UNISWAP_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant UNISWAP_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    event AddedLiquidity(
        string message,
        uint amountTokenA,
        uint amountTokenB,
        uint liquidity
    );
    event RemovedLiquidity(
        string message,
        uint amountTokenA,
        uint amountTokenB
    );

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

    /**
     * @dev Adds liquidity to the Uniswap v2 exchange.
     * @param tokenA The address of token A.
     * @param tokenB The address of token B.
     * @param amountA The amount of token A to add to the liquidity pool.
     * @param amountB The amount of token B to add to the liquidity pool.
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) external {
        // Transfer tokens to the contract address
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        // Approve the Uniswap router to spend the tokens
        IERC20(tokenA).approve(UNISWAP_ROUTER, amountA);
        IERC20(tokenB).approve(UNISWAP_ROUTER, amountB);
        // Add liquidity to the Uniswap exchange
        (
            uint amountTokenA,
            uint amountTokenB,
            uint liquidity
        ) = IUniswapV2Router(UNISWAP_ROUTER).addLiquidity(
                tokenA,
                tokenB,
                amountA,
                amountB,
                1,
                1,
                address(this),
                block.timestamp
            );
        // Emit an event indicating the success of the operation
        emit AddedLiquidity(
            "liquidity added successfully",
            amountTokenA,
            amountTokenB,
            liquidity
        );
    }

    /**
     * @dev Removes liquidity from the Uniswap v2 exchange.
     * @param tokenA The address of token A.
     * @param tokenB The address of token B.
     */
    function removeLiquidity(address tokenA, address tokenB) external {
        // Get the pair address for the tokens
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(
            tokenA,
            tokenB
        );
        // Approve the Uniswap router to spend the liquidity tokens
        uint liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(UNISWAP_ROUTER, liquidity);
        // Remove liquidity from the Uniswap exchange
        (uint amountTokenA, uint amountTokenB) = IUniswapV2Router(
            UNISWAP_ROUTER
        ).removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );
        // Emit an event indicating the success of the operation
        emit RemovedLiquidity(
            "liquidity removed successfully",
            amountTokenA,
            amountTokenB
        );
    }
}

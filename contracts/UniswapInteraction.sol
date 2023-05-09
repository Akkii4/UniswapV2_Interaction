// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title ERC20 interface
 * @dev See https://eips.ethereum.org/EIPS/eip-20
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/IUniswapV2.sol";

contract UniswapInteraction {
    using SafeMath for uint;

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

    /**
     * @dev Calculates the square root of a given number.
     * @param y The number to calculate the square root of.
     * @return z The square root of y.
     */
    function _calculateSqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Calculates the optimal swap amount of Token A for Token B based on the current reserves of the Uniswap pool.
     * @param r The reserve of Token B in the Uniswap pool.
     * @param a The amount of Token A to swap.
     * @return The optimal swap amount of Token A for Token B.
     */
    function calculateOptimalSwapAmount(
        uint r,
        uint a
    ) public pure returns (uint) {
        return
            (
                _calculateSqrt(r.mul(r.mul(3988009) + a.mul(3988000))).sub(
                    r.mul(1997)
                )
            ) / 1994;
    }

    /**
     * @dev Adds liquidity to a Uniswap pool in an optimal way.
     * @param _tokenA The address of Token A.
     * @param _amountA The amount of Token A to add to the Uniswap pool.
     * @param _tokenB The address of Token B.
     */
    function addOptimalLiquidity(
        address _tokenA,
        uint _amountA,
        address _tokenB
    ) external {
        require(
            _tokenA == WETH || _tokenB == WETH,
            "Token A or B must be WETH"
        );

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(
            _tokenA,
            _tokenB
        );
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();

        uint swapAmount;
        if (IUniswapV2Pair(pair).token0() == _tokenA) {
            swapAmount = calculateOptimalSwapAmount(reserve0, _amountA);
        } else {
            swapAmount = calculateOptimalSwapAmount(reserve1, _amountA);
        }

        _executeTokenSwap(_tokenA, _tokenB, swapAmount);
        _provideLiquidity(_tokenA, _tokenB);
    }

    /**
     * @dev Adds liquidity to a Uniswap pool in a suboptimal way.
     * @param _tokenA The address of Token A.
     * @param _amountA The amount of Token A to add to the Uniswap pool.
     * @param _tokenB The address of Token B.
     */
    function addSubOptimalLiquidity(
        address _tokenA,
        uint _amountA,
        address _tokenB
    ) external {
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        uint halfAmountA = _amountA.div(2);
        _executeTokenSwap(_tokenA, _tokenB, halfAmountA);
        _provideLiquidity(_tokenA, _tokenB);
    }

    /**
     * @dev Executes a token swap on Uniswap.
     * @param _from The address of the token to swap from.
     * @param _to The address of the token to swap to.
     * @param _amount The amount of tokens to swap.
     */
    function _executeTokenSwap(
        address _from,
        address _to,
        uint _amount
    ) internal {
        IERC20(_from).approve(UNISWAP_ROUTER, _amount);

        address[] memory path = new address[](2);
        path[0] = _from;
        path[1] = _to;

        IUniswapV2Router(UNISWAP_ROUTER).swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Provides liquidity to a Uniswap pool.
     * @param _tokenA The address of Token A.
     * @param _tokenB The address of Token B.
     */
    function _provideLiquidity(address _tokenA, address _tokenB) internal {
        uint balA = IERC20(_tokenA).balanceOf(address(this));
        uint balB = IERC20(_tokenB).balanceOf(address(this));
        IERC20(_tokenA).approve(UNISWAP_ROUTER, balA);
        IERC20(_tokenB).approve(UNISWAP_ROUTER, balB);

        IUniswapV2Router(UNISWAP_ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            balA,
            balB,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev Retrieves the pair address of Token A and Token B in the Uniswap factory.
     * @param _tokenA The address of Token A.
     * @param _tokenB The address of Token B.
     * @return The pair address of Token A and Token B.
     */
    function retrievePair(
        address _tokenA,
        address _tokenB
    ) external view returns (address) {
        return IUniswapV2Factory(UNISWAP_FACTORY).getPair(_tokenA, _tokenB);
    }
}

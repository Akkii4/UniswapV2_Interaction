# UniswapInteraction Contract

This Solidity contract provides functions for interacting with the Uniswap V2 Decentralized exchange, including functions for swapping tokens and adding/removing liquidity.

## Requirements

- Solidity compiler version 0.8.10
- Hardhat development environment
- OpenZeppelin library version 4.3.2
- UniswapV2 interface

## Usage

To use this contract, you will need to first deploy it to the Ethereum network of your choice. Once the contract is deployed, you can call its functions to interact with the Uniswap exchange.

### Swapping Tokens

The `performSwap` function can be used to swap an amount of tokens for another using the Uniswap V2 router. The function takes the following parameters:

- `tokenFrom`: The address of the token to swap from.
- `tokenTo`: The address of the token to receive.
- `amountFrom`: The amount of tokens to swap.
- `minAmountTo`: The minimum amount of tokens to receive.
- `recipient`: The address to receive the tokens.

Before calling this function, the user must first approve the contract to spend `amountFrom` tokens on their behalf.

### Adding Liquidity

The `addLiquidity` function can be used to add liquidity to the Uniswap v2 exchange. The function takes the following parameters:

- `tokenA`: The address of token A.
- `tokenB`: The address of token B.
- `amountA`: The amount of token A to add to the liquidity pool.
- `amountB`: The amount of token B to add to the liquidity pool.

Before calling this function, the user must first approve the contract to spend `amountA` and `amountB` tokens on their behalf.

### Removing Liquidity

The `removeLiquidity` function can be used to remove liquidity from the Uniswap v2 exchange. The function takes the following parameters:

- `tokenA`: The address of token A.
- `tokenB`: The address of token B.

Before calling this function, the user must have previously added liquidity to the Uniswap pool and have the resulting liquidity tokens in their account.

### Adding Liquidity Optimally

The `addOptimalLiquidity` function can be used to add liquidity to a Uniswap pool in an optimal way. The function takes the following parameters:

- `_tokenA`: The address of Token A.
- `_amountA`: The amount of Token A to add to the Uniswap pool.
- `_tokenB`: The address of Token B.

This function calculates the optimal amount of Token A to swap for Token B based on the current reserves of the Uniswap pool. The resulting Token A and Token B amounts are then used to add liquidity to the pool.

### Adding Liquidity Sub-Optimally

The `addLiquiditySubOptimal` function can be used to add liquidity to a Uniswap pool in a sub-optimal way. The function takes the following parameters:

- `_tokenA`: The address of Token A.
- `_amountA`: The amount of Token A to add to the Uniswap pool.
- `_tokenB`: The address of Token B.
- `_amountB`: The amount of Token B to add to the Uniswap pool.

This function adds liquidity to the Uniswap pool using the specified Token A and Token B amounts.

## Testing

To run the tests for this contract, run the following command:

```
npx hardhat test
```

## Deployment

To deploy this contract to the Ethereum Mainnet, run the following command:

```
npx hardhat run scripts/deploy.js --network mainnet
```

Replace `mainnet` with the name of the network you want to deploy to. You will also need to set the appropriate environment variables for your network, as specified in the `hardhat.config.js` file.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

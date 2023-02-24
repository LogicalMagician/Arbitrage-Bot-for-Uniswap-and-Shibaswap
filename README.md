The contract is deployed to the Ethereum blockchain with the Uniswap and ShibaSwap router addresses, the token path, and the gas limit as constructor parameters.

The contract owner is set to the address that deployed the contract.
The contract is funded with some ETH upon deployment.
The setGasLimit() function can be used to update the gas limit if needed.

The setOwner() function can be used to transfer ownership of the contract to a new address.

The withdrawETH() function can be used by the owner to withdraw any ETH balance from the contract.

The withdrawTokens() function can be used by the owner to withdraw any ERC-20 tokens held by the contract.

The executeArbitrage() function scans the Uniswap and ShibaSwap decentralized exchanges for an arbitrage opportunity between the two exchanges.

The function gets the current ETH-to-token exchange rate on both exchanges by calling the getAmountsOut() function on both routers with the ETH amount and token path.
The function then checks if the token can be sold for a higher amount on one exchange than the other.
If there is a profitable trade, the function swaps the ETH for the token on the exchange where the token is sold for the higher amount.
The swapExactTokensForTokens() function is called on the appropriate router with the ETH amount, minimum token amount to receive, token path, and a deadline.
The onlyOwner() modifier is used to restrict access to certain functions to the contract owner.

The receive() function is a fallback function that allows the contract to receive ETH transfers.

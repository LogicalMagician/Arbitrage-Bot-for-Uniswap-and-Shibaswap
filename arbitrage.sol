// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IShibaSwapRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract ArbitrageBot {
    address public owner;
    address public uniswapRouterAddress;
    address public shibaswapRouterAddress;
    address[] public path;
    uint public gasLimit;

    constructor(address _uniswapRouterAddress, address _shibaswapRouterAddress, address[] memory _path, uint _gasLimit) payable {
        owner = msg.sender;
        uniswapRouterAddress = _uniswapRouterAddress;
        shibaswapRouterAddress = _shibaswapRouterAddress;
        path = _path;
        gasLimit = _gasLimit;
        require(path.length == 2, "Invalid path");
    }

    function setGasLimit(uint _gasLimit) external onlyOwner {
        gasLimit = _gasLimit;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function withdrawETH() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        require(balance > 0, "Insufficient token balance");
        require(IERC20(tokenAddress).transfer(owner, balance), "Token transfer failed");
    }

    function executeArbitrage() external {
        uint amountIn = address(this).balance;
        require(amountIn > 0, "Insufficient ETH balance");

        uint[] memory amountsFromUniswap = IUniswapV2Router02(uniswapRouterAddress).getAmountsOut(amountIn, path);
        uint[] memory amountsFromShibaswap = IShibaSwapRouter(shibaswapRouterAddress).getAmountsOut(amountIn, path);

        uint uniswapAmountOut = amountsFromUniswap[1];
        uint shibaswapAmountOut = amountsFromShibaswap[1];

        if (uniswapAmountOut > shibaswapAmountOut) {
            require(uniswapAmountOut > amountsFromShibaswap[0], "Unprofitable trade");
            IUniswapV2Router02(uniswapRouterAddress).swapExactTokensForTokens(amountIn, amountsFromUniswap[1], path, address(this), block.timestamp + 60);
        } else {
            require(shibaswapAmountOut > amountsFromUniswap[0], "Unprofitable trade");
            IShibaSwapRouter(shibaswapRouterAddress).swapExactTokensForTokens(amountIn, amountsFromShibaswap[1], path, address(this), block.timestamp + 60);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    receive() external payable {}
}

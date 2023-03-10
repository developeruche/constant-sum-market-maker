// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import {IERC20} from "./interfaces/IERC20.sol";

/// @notice this is a solidity project that implements a market maket whose formula of opeartion is x+y=k
contract ConstantSumMarketMaker {

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;


    event Swap(address _tokenIn, uint256 _amountIn, uint256 _amountOut);


    constructor(IERC20 _token0, IERC20 _token1) {
        token0 = _token0;
        token1 = _token1;
    }


    function swap(address _tokenIn, uint256 _amountIn) external returns(uint256 amountOut_) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid _tokenIn");

        bool is_token_0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut) = is_token_0 ? (token0, token1) : (token1, token0);

        // Tranfer _token into this contract
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);


        // Calculate amout out including  [0.2%]
        amountOut_ = (_amountIn * 998) / 100;


        // update state variables
        if(_tokenIn == address(token0)) {
            _update(reserve0 + _amountIn, reserve1 - amountOut_);
        } else {
            _update(reserve0 - amountOut_, reserve1 - _amountIn);
        }

        // tranfer token out
        tokenOut.transfer(msg.sender, amountOut_);


        emit Swap(address(tokenIn), _amountIn, amountOut_);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns(uint256 shares_) {
        // Tranfering tokens into the pool
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);


        // Calculation shares [LP to be sent to liquidity provider]
        if(totalSupply == 0) {
            shares_ = _amount0 + _amount1;
        } else {
            shares_ = ((_amount0 + _amount1) * totalSupply) / (reserve0 + reserve1);
        }

        require(shares_ > 0, "no liquidity was added");

        _mint(msg.sender, shares_);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeLiquidity(uint256 _shares) external returns(uint256 amount0Out_, uint256 amount1Out_) {
        // Calcuating token to be sent on a given amount of shares 
        amount0Out_ = (reserve0 * _shares) / totalSupply;
        amount1Out_ = (reserve1 * _shares) / totalSupply;

        // Burning share before transfering tokens 
        _burn(msg.sender, _shares);
        _update(reserve0 - amount0Out_, reserve1 - amount1Out_);

        // Transfering tokens
        token0.transfer(msg.sender, amount0Out_);
        token1.transfer(msg.sender, amount1Out_);
    }


    // ==================================================
    // INTERNAL FUNCTIONS
    // ==================================================

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
}

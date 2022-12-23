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


    constructor(IERC20 _token0, IERC20 _token1) {
        token0 = _token0;
        token1 = _token1;
    }


    function swap(address _tokenIn, uint256 _amountIn) external returns(uint256 amountOut_) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid _tokenIn");

        // Tranfer _token into this contract
        if(_tokenIn == address(token0)) {
            token0.transferFrom(msg.sender, address(this), _amountIn);
        } else {
            token1.transferFrom(msg.sender, address(this), _amountIn);
        }

        // Calculate amout out including  [0.2%]
        amountOut_ = (_amountIn * 998) / 100;


        // update state variables
        if(_tokenIn == address(token0)) {
            _update(reserve0 + _amountIn, reserve1 - amountOut_);
        } else {
            _update(reserve0 - amountOut_, reserve1 - _amountIn);
        }

        // tranfer token out
        if(_tokenIn == address(token0)) {
            token1.transfer(msg.sender, amountOut_);
        } else {
            token1.transfer(msg.sender, amountOut_);
        }
    }

    function addLiquidity() external {

    }

    function removeLiquidity() external {

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

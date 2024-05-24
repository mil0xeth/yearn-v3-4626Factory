// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";
import {IUniswapV3Swapper} from "@periphery/swappers/interfaces/IUniswapV3Swapper.sol";

interface IStrategyInterface is IStrategy {
    function vault() external view returns (address);
    function setLossLimitRatio(uint256) external;
    function setProfitLimitRatio(uint256) external;
    function setDoHealthCheck(bool) external;
}

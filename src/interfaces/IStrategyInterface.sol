// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";

interface IStrategyInterface is IStrategy {
    function claimRewards() external view returns (bool);

    function setUniFees(uint24 _compToEth, uint24 _ethToAsset) external;

    function setMinAmountToSell(uint256 _minAmountToSell) external;

    function setClaimRewards(bool _claimRewards) external;
}

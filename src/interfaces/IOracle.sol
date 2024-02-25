// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

interface IOracle {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function latestAnswer() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Base4626Compounder, ERC20, SafeERC20, Math} from "@periphery/Bases/4626Compounder/Base4626Compounder.sol";

contract Strategy is Base4626Compounder {
    using SafeERC20 for ERC20;

    address public immutable GOV;

    constructor(address _asset, address _vault, address _GOV, string memory _name) Base4626Compounder(_asset, _name, _vault) {
        GOV = _GOV;
    }

    /**
     * @notice Sweep of non-asset & non-vault ERC20 tokens to governance (onlyGovernance)
     * @param _token The ERC20 token to sweep
     */
    function sweep(address _token) external {
        require(msg.sender == GOV, "!gov");
        require(_token != address(asset), "!asset");
        require(_token != address(vault), "!vault");
        ERC20(_token).safeTransfer(GOV, ERC20(_token).balanceOf(address(this)));
    }
}
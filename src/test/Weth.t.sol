// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {OperationTest, ERC20} from "./Operation.t.sol";
import {ShutdownTest} from "./Shutdown.t.sol";

import {IStrategyInterface} from "../interfaces/IStrategyInterface.sol";
import {CompoundV3LenderFactory, CompoundV3Lender} from "../CompoundV3LenderFactory.sol";

contract WethOperationTest is OperationTest {
    function setUp() public virtual override {
        super.setUp();

        asset = ERC20(tokenAddrs["WETH"]);

        comet = 0xA17581A9E3356d9A858b789D68B4d866e593aE94;

        // Set decimals
        decimals = asset.decimals();

        // Deploy strategy and set variables
        strategy = IStrategyInterface(
            lenderFactory.newCompoundV3Lender(
                address(asset),
                "Tokenized Strategy",
                comet,
                0x1B39Ee86Ec5979ba5C322b826B3ECb8C79991699
            )
        );

        vm.prank(management);
        strategy.acceptManagement();

        vm.prank(management);
        strategy.setUniFees(3000, 500);
    }
}

contract WethShutdownTest is ShutdownTest {
    function setUp() public virtual override {
        super.setUp();

        asset = ERC20(tokenAddrs["WETH"]);

        comet = 0xA17581A9E3356d9A858b789D68B4d866e593aE94;

        // Set decimals
        decimals = asset.decimals();

        // Deploy strategy and set variables
        strategy = IStrategyInterface(
            lenderFactory.newCompoundV3Lender(
                address(asset),
                "Tokenized Strategy",
                comet,
                0x1B39Ee86Ec5979ba5C322b826B3ECb8C79991699
            )
        );

        vm.prank(management);
        strategy.acceptManagement();

        vm.prank(management);
        strategy.setUniFees(3000, 500);
    }
}

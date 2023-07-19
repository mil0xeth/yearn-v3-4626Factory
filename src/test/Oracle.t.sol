pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {Setup} from "./utils/Setup.sol";

import {CompoundV3AprOracle} from "../periphery/CompoundV3AprOracle.sol";

contract OracleTest is Setup {
    CompoundV3AprOracle public oracle;

    function setUp() public override {
        super.setUp();
        oracle = new CompoundV3AprOracle("Test oracle", comet);
    }

    function checkOracle(address _asset, uint256 _delta) public {
        // Check set up
        // TODO: Add checks for the setup

        uint256 currentApr = oracle.aprAfterDebtChange(_asset, 0);

        // Should be greater than 0 but likely less than 100%
        assertGt(currentApr, 0, "ZERO");
        assertLt(currentApr, 1e18, "+100%");

        uint256 negativeDebtChangeApr = oracle.aprAfterDebtChange(
            _asset,
            -int256(_delta)
        );

        // The apr should go up if deposits go down
        assertLt(currentApr, negativeDebtChangeApr, "negative change");

        uint256 positiveDebtChangeApr = oracle.aprAfterDebtChange(
            _asset,
            int256(_delta)
        );

        assertGt(currentApr, positiveDebtChangeApr, "positive change");
        // TODO: Uncomment if there are setter functions to test.
        /**
        vm.expectRevert("Ownable: caller is not the owner");
        oracle.setterFunction(setterVariable, sender=user);
    
        oracle.setterFunction(setterVariable, sender=management);

        assertEq(oracle.setterVariable(), setterVariable);
        */
    }

    function test_oracle(uint256 _amount, uint16 _percentChange) public {
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);
        _percentChange = uint16(bound(uint256(_percentChange), 10, MAX_BPS));

        mintAndDepositIntoStrategy(strategy, user, _amount);

        // TODO: adjust the number to base _perfenctChange off of.
        uint256 _delta = (_amount * _percentChange) / MAX_BPS;

        checkOracle(address(asset), _delta);
    }

    // TODO: Deploy multiple strategies with differen tokens as `asset` to test against the oracle.
}

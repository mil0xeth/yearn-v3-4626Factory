pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {Setup, IStrategyInterface, ERC20} from "./utils/Setup.sol";

import {CompoundV3AprOracle} from "../periphery/CompoundV3AprOracle.sol";

contract OracleTest is Setup {
    CompoundV3AprOracle public oracle;

    function setUp() public override {
        super.setUp();
        oracle = new CompoundV3AprOracle("name", address(comet));
    }

    function checkOracle(address _strategy, uint256 _delta) public {
        uint256 currentApr = oracle.aprAfterDebtChange(_strategy, 0);
        console.log("APR ", currentApr);

        // Should be greater than 0 but likely less than 100%
        assertGt(currentApr, 0, "ZERO");
        assertLt(currentApr, 1e18, "+100%");

        // TODO: Uncomment to test the apr goes up and down based on debt changes
        uint256 negativeDebtChangeApr = oracle.aprAfterDebtChange(
            _strategy,
            -int256(_delta)
        );

        // The apr should go up if deposits go down
        assertLt(currentApr, negativeDebtChangeApr, "negative change");

        uint256 positiveDebtChangeApr = oracle.aprAfterDebtChange(
            _strategy,
            int256(_delta)
        );

        assertGt(currentApr, positiveDebtChangeApr, "positive change");
    }

    function test_oracle(uint256 _amount, uint16 _percentChange) public {
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);
        _percentChange = uint16(bound(uint256(_percentChange), 10, MAX_BPS));

        mintAndDepositIntoStrategy(strategy, user, _amount);

        // TODO: adjust the number to base _percentChange off of.
        uint256 _delta = (_amount * _percentChange) / MAX_BPS;

        checkOracle(address(strategy), _delta);
    }

    function test_wethOracle(uint256 _amount, uint16 _percentChange) public {
        vm.assume(
            _amount > minFuzzAmount * 1e8 && _amount < maxFuzzAmount * 1e8
        );
        _percentChange = uint16(bound(uint256(_percentChange), 10, MAX_BPS));

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

        oracle = new CompoundV3AprOracle("name", address(comet));

        oracle.setPriceFeeds(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5
        );

        mintAndDepositIntoStrategy(strategy, user, _amount);

        // TODO: adjust the number to base _percentChange off of.
        uint256 _delta = (_amount * _percentChange) / MAX_BPS;

        checkOracle(address(strategy), _delta);
    }
}

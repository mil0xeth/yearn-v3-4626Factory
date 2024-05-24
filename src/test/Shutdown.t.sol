pragma solidity ^0.8.18;

import "forge-std/console.sol";
import {Setup} from "./utils/Setup.sol";

contract ShutdownTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_shutdownCanWithdraw(uint256 _amount) public {
        vm.assume(_amount > minFuzzAmount && _amount < maxFuzzAmount);

        // Deposit into strategy
        mintAndDepositIntoStrategy(strategy, user, _amount);

        checkStrategyTotals(strategy, _amount, _amount, 0);

        // Earn Interest

        // Shutdown the strategy
        vm.prank(management);
        strategy.shutdownStrategy();

        vm.prank(management);
        strategy.emergencyWithdraw(_amount);

        // Make sure we can still withdraw the full amount
        uint256 balanceBefore = asset.balanceOf(user);

        require(_amount > 10, "_amount so small!");

        // Withdraw all funds
        vm.prank(user);
        strategy.redeem(_amount, user, user);

        assertGe(
            asset.balanceOf(user) + 2,
            balanceBefore + _amount,
            "!final balance"
        );
        
    }

    // TODO: Add tests for any emergency function added.
}

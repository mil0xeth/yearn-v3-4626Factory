// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";

import {Comet, CometRewards} from "../interfaces/Compound/V3/CompoundV3.sol";
import {IStrategyInterface} from "../interfaces/IStrategyInterface.sol";

contract CompoundV3AprOracle is AprOracleBase {
    Comet public immutable comet;
    address public immutable baseToken;
    // price feeds for the reward apr calculation, can be updated manually if needed
    address public rewardTokenPriceFeed;
    address public baseTokenPriceFeed;

    uint64 internal constant DAYS_PER_YEAR = 365;
    uint64 internal constant SECONDS_PER_DAY = 60 * 60 * 24;
    uint64 internal constant SECONDS_PER_YEAR = 365 days;

    uint256 internal immutable SCALER;

    constructor(
        string memory _name,
        address _comet
    ) AprOracleBase(_name, msg.sender) {
        comet = Comet(_comet);

        baseToken = Comet(_comet).baseToken();

        uint256 BASE_MANTISSA = Comet(_comet).baseScale();
        uint256 BASE_INDEX_SCALE = Comet(_comet).baseIndexScale();

        // this is needed for reward apr calculations based on decimals
        // of baseToken we scale rewards per second to the base token
        // decimals and diff between comp decimals and the index scale
        SCALER = (BASE_MANTISSA * 1e18) / BASE_INDEX_SCALE;

        // set default price feeds
        baseTokenPriceFeed = Comet(_comet).baseTokenPriceFeed();
        // default to COMP/USD
        rewardTokenPriceFeed = 0x2A8758b7257102461BC958279054e372C2b1bDE6;
    }

    function setPriceFeeds(
        address _baseTokenPriceFeed,
        address _rewardTokenPriceFeed
    ) external onlyGovernance {
        // just check the call doesn't revert. We don't care about the amount returned
        comet.getPrice(_baseTokenPriceFeed);
        comet.getPrice(_rewardTokenPriceFeed);
        baseTokenPriceFeed = _baseTokenPriceFeed;
        rewardTokenPriceFeed = _rewardTokenPriceFeed;
    }

    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view override returns (uint256) {
        require(IStrategyInterface(_strategy).asset() == baseToken, "wrong asset");

        uint256 borrows = comet.totalBorrow();
        uint256 supply = comet.totalSupply();

        uint256 newAmount = uint256(int256(supply) + _delta);

        uint256 newUtilization = (borrows * 1e18) / newAmount;

        unchecked {
            return
                getSupplyApr(newUtilization) +
                getRewardAprForSupplyBase(newAmount);
        }
    }

    function getRewardAprForSupplyBase(
        uint256 _newAmount
    ) public view returns (uint256) {
        Comet _comet = comet;
        unchecked {
            uint256 rewardToSuppliersPerDay = _comet.baseTrackingSupplySpeed() *
                SECONDS_PER_DAY *
                SCALER;
            if (rewardToSuppliersPerDay == 0) return 0;
            return
                ((_comet.getPrice(rewardTokenPriceFeed) *
                    rewardToSuppliersPerDay) /
                    (_newAmount * _comet.getPrice(baseTokenPriceFeed))) *
                DAYS_PER_YEAR;
        }
    }

    function getSupplyApr(
        uint256 _newUtilization
    ) public view returns (uint256) {
        unchecked {
            return
                comet.getSupplyRate(
                    _newUtilization // New utilization
                ) * SECONDS_PER_YEAR;
        }
    }
}

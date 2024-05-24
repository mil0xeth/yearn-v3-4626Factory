// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Strategy} from "./Strategy.sol";
import {IStrategyInterface} from "./interfaces/IStrategyInterface.sol";

contract StrategyFactory {
    /// @notice Revert message for when a strategy has already been deployed.
    error AlreadyDeployed(address _strategy);

    event NewStrategy(address indexed strategy, address indexed asset);

    address public management;
    address public performanceFeeRecipient;
    address public keeper;

    address public immutable emergencyAdmin;
    address public immutable GOV;

    mapping(address => address) public vaultToStrategy;

    constructor(
        address _management,
        address _performanceFeeRecipient,
        address _keeper,
        address _emergencyAdmin,
        address _GOV
    ) {
        require(_management != address(0), "ZERO ADDRESS");
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
        keeper = _keeper;
        emergencyAdmin = _emergencyAdmin;
        GOV = _GOV;
    }

    modifier onlyManagement() {
        require(msg.sender == management, "!management");
        _;
    }

    /**
     * @notice Deploy a new 4626Factory Strategy.
     * @dev This will set the msg.sender to all of the permissioned roles.
     * @param _asset The underlying asset for the lender to use.
     * @param _vault The vault to use.
     * @param _name The name of the strategy to use.
     * @return . The address of the new lender.
     */
    function newStrategy(address _asset, address _vault, string memory _name) external onlyManagement returns (address) {
        IStrategyInterface newStrat = IStrategyInterface(address(new Strategy(_asset, _vault, GOV, _name)));

        newStrat.setPerformanceFeeRecipient(performanceFeeRecipient);

        newStrat.setKeeper(keeper);

        newStrat.setPendingManagement(management);

        newStrat.setEmergencyAdmin(emergencyAdmin);

        emit NewStrategy(address(newStrat), _asset);

        vaultToStrategy[_vault] = address(newStrat);
        return address(newStrat);
    }

    function setAddresses(
        address _management,
        address _performanceFeeRecipient,
        address _keeper
    ) external {
        require(msg.sender == management, "!management");
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
        keeper = _keeper;
    }

    /**
     * @notice Retrieve the address of a strategy by vault address
     * @param _vault market address
     * @return strategy address
     */
    function getStrategyByVault(address _vault) external view returns (address) {
        return vaultToStrategy[_vault];
    }

    /**
     * @notice Check if a strategy has been deployed by this Factory
     * @param _strategy strategy address
     */
    function isDeployedStrategy(address _strategy) external view returns (bool) {
        address _vault = IStrategyInterface(_strategy).vault();
        return vaultToStrategy[_vault] == _strategy;
    }

    function setStrategyByVault(address _vault, address _strategy) external onlyManagement {
        vaultToStrategy[_vault] = _strategy;
    }
}
